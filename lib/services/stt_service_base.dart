/// Base interface for Speech-to-Text services.
abstract class SttServiceBase {
  Future<bool> initialize({
    void Function(String)? onError,
    void Function(String)? onStatus,
  });
  
  Future<void> startListening({
    required void Function(String) onResult,
  });
  
  Future<void> stopListening();
  
  bool get isListening;
}
