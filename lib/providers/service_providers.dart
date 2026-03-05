import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import '../core/config/app_config.dart';
import '../services/ai_service.dart';
import '../services/ai_service_local.dart';
import '../services/ai_service_remote.dart';
import '../services/tts_service_base.dart';
import '../services/tts_service.dart';
import '../services/remote_tts_service.dart';
import '../services/stt_service_base.dart';
import '../services/local_stt_service.dart';
import '../services/remote_stt_service.dart';
import '../services/tts_audio_handler.dart';

/// Centralized AI Service provider with toggle logic.
final aiServiceProvider = Provider<AiService>((ref) {
  if (!AppConfig.enableRemoteAI) {
    return AiServiceLocal();
  }

  switch (AppConfig.aiMode) {
    case AiMode.remote:
      return AiServiceRemote();
    case AiMode.local:
    default:
      return AiServiceLocal();
  }
});

/// Global TTS Handler provider (initialized in main).
final ttsHandlerProvider = Provider<TtsAudioHandler>((ref) {
  throw UnimplementedError("Initialize in main");
});

/// Centralized TTS Service provider with toggle logic.
final ttsServiceProvider = Provider<TtsServiceBase>((ref) {
  final handler = ref.watch(ttsHandlerProvider);
  
  if (!AppConfig.enableRemoteAI) {
    return LocalTtsService(handler);
  }

  if (AppConfig.aiMode == AiMode.remote) {
    return RemoteTtsService();
  }
  
  return LocalTtsService(handler);
});

/// Centralized STT Service provider with toggle logic.
final sttServiceProvider = Provider<SttServiceBase>((ref) {
  if (!AppConfig.enableRemoteAI) {
    return LocalSttService();
  }

  if (AppConfig.aiMode == AiMode.remote) {
    return RemoteSttService();
  }

  return LocalSttService();
});
