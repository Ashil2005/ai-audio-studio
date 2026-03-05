import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_studio/features/voice_chat/models/voice_chat_state.dart';
import 'package:audio_studio/features/voice_chat/voice_chat_controller.dart';
import 'package:audio_studio/models/persona_model.dart';
import 'package:audio_studio/services/ai_service.dart';
import 'package:audio_studio/services/tts_service_base.dart';
import 'package:audio_studio/services/stt_service_base.dart';

// Simple manual mock since mockito requires build_runner which might be slow
class MockAiService implements AiService {
  @override
  Future<String> generatePersonaResponse({required PersonaModel persona, required String userInput}) async {
    return "Mock Response for $userInput";
  }
  @override
  Future<String> generateSummary(String text) async => "Summary";
  @override
  Future<List<Map<String, String>>> generateDebate({required List<String> personas, required String topic, required String style, int rounds = 3}) async => [];
  @override
  Future<String> generatePodcastScript({required String text, required String format}) async => "Podcast Script";
}

class MockTtsService implements TtsServiceBase {
  @override
  Future<void> speak(String text) async {}
  @override
  Future<void> stop() async {}
  @override
  Future<void> pause() async {}
  @override
  Future<void> resume() async {}
  @override
  Future<void> setSpeed(double speed) async {}
  @override
  Future<void> startAudiobook(String title, String text, {int resumeIndex = 0}) async {}
  @override
  Future<void> persistState(String title, String path, int index) async {}
  @override
  Future<Map<String, dynamic>?> getPersistedState() async => null;
  
  @override
  bool get isSpeaking => false;
  @override
  int get currentIndex => 0;
  @override
  int get totalChunks => 0;
  @override
  String get currentText => "";
  
  @override
  Stream<PlaybackState> get playbackState => const Stream.empty();
  @override
  Stream<MediaItem?> get mediaItem => const Stream.empty();
}

class MockSttService implements SttServiceBase {
  @override
  bool get isListening => false;
  @override
  Future<bool> initialize({void Function(String)? onError, void Function(String)? onStatus}) async => true;
  @override
  Future<void> startListening({required void Function(String) onResult}) async {}
  @override
  Future<void> stopListening() async {}
}

void main() {
  late MockAiService mockAiService;
  late MockTtsService mockTtsService;
  late MockSttService mockSttService;
  late PersonaModel persona;
  late VoiceChatController controller;

  setUp(() {
    mockAiService = MockAiService();
    mockTtsService = MockTtsService();
    mockSttService = MockSttService();
    persona = const PersonaModel(
      id: 'test',
      name: 'Test Persona',
      description: 'Test',
      tone: PersonaTone.calm,
      speakingStyle: SpeakingStyle.balanced,
      prefixStyle: 'Test:',
    );
    controller = VoiceChatController(mockAiService, mockTtsService, mockSttService, persona);
  });

  group('VoiceChatController Tests', () {
    test('Initial state should be empty', () {
      expect(controller.debugState.messages, isEmpty);
      expect(controller.debugState.isListening, isFalse);
      expect(controller.debugState.isProcessing, isFalse);
    });

    test('clearChat should empty messages', () {
      controller.clearChat();
      expect(controller.debugState.messages, isEmpty);
    });
  });
}
