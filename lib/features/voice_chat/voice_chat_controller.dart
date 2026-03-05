import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/persona_model.dart';
import '../../services/ai_service.dart';
import '../../services/tts_service_base.dart';
import '../../services/stt_service_base.dart';
import '../../providers/service_providers.dart';
import '../../core/utils/logger.dart';
import 'models/voice_chat_state.dart';

final voiceChatProvider = StateNotifierProvider.family<VoiceChatController, VoiceChatState, PersonaModel>((ref, persona) {
  final aiService = ref.watch(aiServiceProvider);
  final ttsService = ref.watch(ttsServiceProvider);
  final sttService = ref.watch(sttServiceProvider);
  return VoiceChatController(aiService, ttsService, sttService, persona);
});

class VoiceChatController extends StateNotifier<VoiceChatState> {
  final AiService _aiService;
  final TtsServiceBase _ttsService;
  final SttServiceBase _sttService;
  final PersonaModel _persona;
  DateTime? _lastStartTime;

  VoiceChatController(this._aiService, this._ttsService, this._sttService, this._persona)
      : super(VoiceChatState(messages: []));

  Future<void> startListening() async {
    // 1. Processing Guard
    if (state.isListening || state.isProcessing) return;

    // 2. Debounce Guard (300ms)
    final now = DateTime.now();
    if (_lastStartTime != null && now.difference(_lastStartTime!).inMilliseconds < 300) {
      AppLogger.log("Voice Chat: Debounced start request");
      return;
    }
    _lastStartTime = now;

    try {
      bool available = await _sttService.initialize(
        onError: (val) {
          AppLogger.error("STT Refactored Error: $val");
          state = state.copyWith(isListening: false, error: 'Speech error: $val');
        },
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            state = state.copyWith(isListening: false);
          }
        },
      );

      if (available) {
        state = state.copyWith(isListening: true, error: null);
        await _sttService.startListening(
          onResult: (text) {
            _handleUserSpeech(text);
          },
        );
      } else {
        state = state.copyWith(error: "Speech recognition not available");
      }
    } catch (e) {
      AppLogger.error("Failed to initialize STT via abstraction", e);
      state = state.copyWith(error: "Speech initialization failed");
    }
  }

  void stopListening() {
    _sttService.stopListening();
    state = state.copyWith(isListening: false);
  }

  Future<void> _handleUserSpeech(String text) async {
    if (text.trim().isEmpty) return;

    // 1. Add User Message
    final userMsg = ChatMessage(
      sender: 'user',
      text: text,
      isUser: true,
    );
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isProcessing: true,
    );

    try {
      // 2. Generate AI Response
      final response = await _aiService.generatePersonaResponse(
        persona: _persona,
        userInput: text,
      );

      // 3. Add AI Message
      final aiMsg = ChatMessage(
        sender: _persona.name,
        text: response,
        isUser: false,
      );
      state = state.copyWith(
        messages: [...state.messages, aiMsg],
      );

      // 4. Speak Response
      await _ttsService.speak(response);
    } catch (e) {
      state = state.copyWith(error: "Error: $e");
    } finally {
      state = state.copyWith(isProcessing: false);
    }
  }

  void clearChat() {
    state = state.copyWith(messages: [], error: null);
  }
}
