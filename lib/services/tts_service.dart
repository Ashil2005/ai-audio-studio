import 'package:audio_service/audio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/utils/logger.dart';
import 'tts_audio_handler.dart';
import 'tts_service_base.dart';

/// Local implementation of TTS using flutter_tts and background audio handler.
class LocalTtsService implements TtsServiceBase {
  bool _isSpeaking = false;
  final TtsAudioHandler _handler;
  
  LocalTtsService(this._handler);

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  Future<void> startAudiobook(String title, String text, {int resumeIndex = 0}) async {
    if (_isSpeaking) await stop();
    _isSpeaking = true;
    try {
      await _handler.setContent(title, text);
      await _handler.setIndex(resumeIndex);
      await _handler.play();
    } catch (e) {
      _isSpeaking = false;
      AppLogger.error("Failed to start audiobook", e);
      rethrow;
    }
  }

  @override
  Future<void> pause() => _handler.pause();
  @override
  Future<void> resume() => _handler.play();
  
  @override
  Future<void> stop() async {
    _isSpeaking = false;
    await _handler.stop();
  }

  @override
  Future<void> setSpeed(double speed) => _handler.setSpeed(speed);

  @override
  Future<void> speak(String text) async {
    if (_isSpeaking) await _handler.stop();
    _isSpeaking = true;
    try {
      await _handler.setContent("Voice Chat", text);
      await _handler.play();
    } catch (e) {
      _isSpeaking = false;
      AppLogger.error("TTS Speak error", e);
    }
  }

  @override
  Stream<PlaybackState> get playbackState => _handler.playbackState;
  @override
  Stream<MediaItem?> get mediaItem => _handler.mediaItem;
  
  @override
  int get currentIndex => _handler.currentIndex;
  @override
  int get totalChunks => _handler.totalChunks;
  @override
  String get currentText => _handler.currentText;

  // Persistence helpers
  static const String _lastPathKey = 'last_audiobook_path';
  static const String _lastIndexKey = 'last_audiobook_index';
  static const String _lastTitleKey = 'last_audiobook_title';

  @override
  Future<void> persistState(String title, String path, int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastTitleKey, title);
    await prefs.setString(_lastPathKey, path);
    await prefs.setInt(_lastIndexKey, index);
  }

  @override
  Future<Map<String, dynamic>?> getPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_lastPathKey);
    if (path == null) return null;
    
    return {
      'title': prefs.getString(_lastTitleKey) ?? "Unknown",
      'path': path,
      'index': prefs.getInt(_lastIndexKey) ?? 0,
    };
  }
}
