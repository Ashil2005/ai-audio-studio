import '../core/utils/logger.dart';
import 'stt_service_base.dart';

/// Remote STT implementation stub (e.g., Deepgram or Google Cloud STT).
class RemoteSttService implements SttServiceBase {
  bool _isListening = false;

  @override
  bool get isListening => _isListening;

  @override
  Future<bool> initialize({
    void Function(String)? onError,
    void Function(String)? onStatus,
  }) async {
    AppLogger.log("[Remote STT Stub] Initializing remote STT.");
    return true;
  }

  @override
  Future<void> startListening({
    required void Function(String) onResult,
  }) async {
    _isListening = true;
    AppLogger.log("[Remote STT Stub] Listening...");
    // Future: Simulate a response for testing? 
    // For now just logs as requested.
  }

  @override
  Future<void> stopListening() async {
    _isListening = false;
    AppLogger.log("[Remote STT Stub] Stopped listening.");
  }
}
