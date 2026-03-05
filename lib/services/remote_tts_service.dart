import 'package:audio_service/audio_service.dart';
import '../core/utils/logger.dart';
import 'tts_service_base.dart';

/// Remote TTS implementation stub (e.g., ElevenLabs).
class RemoteTtsService implements TtsServiceBase {
  @override
  Future<void> startAudiobook(String title, String text, {int resumeIndex = 0}) async {
    AppLogger.log("[Remote TTS Stub] Starting audiobook: $title");
  }

  @override
  Future<void> speak(String text) async {
    AppLogger.log("[Remote TTS Stub] Speaking: $text");
  }

  @override
  Future<void> stop() async {
    AppLogger.log("[Remote TTS Stub] Stopping audio.");
  }

  @override
  Future<void> pause() async {
    AppLogger.log("[Remote TTS Stub] Pausing audio.");
  }

  @override
  Future<void> resume() async {
    AppLogger.log("[Remote TTS Stub] Resuming audio.");
  }

  @override
  Future<void> setSpeed(double speed) async {
    AppLogger.log("[Remote TTS Stub] Setting speed to $speed.");
  }

  @override
  Stream<PlaybackState> get playbackState => Stream.value(PlaybackState());

  @override
  Stream<MediaItem?> get mediaItem => Stream.value(null);

  @override
  int get currentIndex => 0;

  @override
  int get totalChunks => 0;

  @override
  String get currentText => "";

  @override
  Future<void> persistState(String title, String path, int index) async {}

  @override
  Future<Map<String, dynamic>?> getPersistedState() async => null;
}
