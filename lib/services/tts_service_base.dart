import 'package:audio_service/audio_service.dart';

/// Base interface for Text-to-Speech services.
abstract class TtsServiceBase {
  Future<void> startAudiobook(String title, String text, {int resumeIndex = 0});
  Future<void> speak(String text);
  Future<void> stop();
  Future<void> pause();
  Future<void> resume();
  Future<void> setSpeed(double speed);
  
  Stream<PlaybackState> get playbackState;
  Stream<MediaItem?> get mediaItem;
  
  int get currentIndex;
  int get totalChunks;
  String get currentText;
  
  Future<void> persistState(String title, String path, int index);
  Future<Map<String, dynamic>?> getPersistedState();
}
