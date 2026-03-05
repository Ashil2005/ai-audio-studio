class DebateMessage {
  final String speakerId;
  final String speakerName;
  final String content;
  final int round;

  const DebateMessage({
    required this.speakerId,
    required this.speakerName,
    required this.content,
    required this.round,
  });
}
