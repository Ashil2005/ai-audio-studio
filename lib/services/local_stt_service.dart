import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../core/utils/logger.dart';
import 'stt_service_base.dart';

/// Local implementation of STT using the speech_to_text package.
class LocalSttService implements SttServiceBase {
  final stt.SpeechToText _speech = stt.SpeechToText();

  @override
  bool get isListening => _speech.isListening;

  @override
  Future<bool> initialize({
    void Function(String)? onError,
    void Function(String)? onStatus,
  }) async {
    try {
      return await _speech.initialize(
        onError: (val) {
          AppLogger.error("STT Local Error: ${val.errorMsg}");
          if (onError != null) onError(val.errorMsg);
        },
        onStatus: (val) {
          if (onStatus != null) onStatus(val);
        },
      );
    } catch (e) {
      AppLogger.error("Failed to initialize Local STT", e);
      return false;
    }
  }

  @override
  Future<void> startListening({
    required void Function(String) onResult,
  }) async {
    await _speech.listen(
      onResult: (val) {
        if (val.finalResult) {
          onResult(val.recognizedWords);
        }
      },
    );
  }

  @override
  Future<void> stopListening() async {
    await _speech.stop();
  }
}
