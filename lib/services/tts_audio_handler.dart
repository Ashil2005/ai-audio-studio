import 'package:audio_service/audio_service.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../core/utils/text_chunker.dart';

/// Custom AudioHandler to handle background audio tasks via TTS
class TtsAudioHandler extends BaseAudioHandler with SeekHandler {
  final FlutterTts _tts = FlutterTts();
  
  List<String> _chunks = [];
  int _currentIndex = 0;
  String _title = "Audiobook";
  
  TtsAudioHandler() {
    _initTts();
  }

  void _initTts() {
    _tts.setCompletionHandler(() {
      if (_currentIndex < _chunks.length - 1) {
        _currentIndex++;
        _playCurrentChunk();
      } else {
        stop();
      }
    });

    _tts.setErrorHandler((msg) {
      playbackState.add(playbackState.value.copyWith(
        processingState: AudioProcessingState.error,
      ));
    });

    // Default state
    playbackState.add(playbackState.value.copyWith(
      controls: [MediaControl.pause, MediaControl.stop],
      systemActions: {MediaAction.seek},
      processingState: AudioProcessingState.idle,
      playing: false,
    ));
  }

  Future<void> setContent(String title, String text) async {
    _title = title;
    _chunks = TextChunker.chunk(text);
    _currentIndex = 0;
    
    mediaItem.add(MediaItem(
      id: 'tts_audiobook',
      title: _title,
      album: 'PocketAudio Studio',
      duration: Duration(seconds: (_chunks.length * 10).toInt()), // Rough estimate
    ));
  }

  Future<void> setIndex(int index) async {
    if (index >= 0 && index < _chunks.length) {
      _currentIndex = index;
    }
  }

  Future<void> setSpeed(double speed) async {
    await _tts.setSpeechRate(speed / 2); // flutter_tts rate is 0.0 to 1.0, typically 0.5 is normal
    playbackState.add(playbackState.value.copyWith(speed: speed));
  }

  @override
  Future<void> play() async {
    playbackState.add(playbackState.value.copyWith(
      playing: true,
      controls: [MediaControl.pause, MediaControl.stop],
    ));
    _playCurrentChunk();
  }

  @override
  Future<void> pause() async {
    await _tts.stop();
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      controls: [MediaControl.play, MediaControl.stop],
    ));
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      processingState: AudioProcessingState.idle,
      controls: [],
    ));
    super.stop();
  }

  Future<void> _playCurrentChunk() async {
    if (_currentIndex < _chunks.length) {
      playbackState.add(playbackState.value.copyWith(
        processingState: AudioProcessingState.ready,
        updatePosition: Duration(seconds: _currentIndex * 10), // Dummy position
      ));
      
      // Update custom state for UI to know current chunk
      // We can use the 'queueIndex' or custom positions
      
      await _tts.speak(_chunks[_currentIndex]);
    }
  }

  int get currentIndex => _currentIndex;
  int get totalChunks => _chunks.length;
  String get currentText => _currentIndex < _chunks.length ? _chunks[_currentIndex] : "";
}
