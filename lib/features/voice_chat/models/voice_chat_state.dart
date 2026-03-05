class ChatMessage {
  final String sender; // "user" or persona.name
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.sender,
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class VoiceChatState {
  final List<ChatMessage> messages;
  final bool isListening;
  final bool isProcessing;
  final String? error;

  VoiceChatState({
    required this.messages,
    this.isListening = false,
    this.isProcessing = false,
    this.error,
  });

  VoiceChatState copyWith({
    List<ChatMessage>? messages,
    bool? isListening,
    bool? isProcessing,
    String? error,
  }) {
    return VoiceChatState(
      messages: messages ?? this.messages,
      isListening: isListening ?? this.isListening,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error ?? this.error,
    );
  }
}
