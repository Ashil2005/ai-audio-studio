class PodcastScript {
  final String title;
  final String intro;
  final List<String> segments;
  final String outro;
  final String format;
  final int estimatedDuration; // in minutes

  const PodcastScript({
    required this.title,
    required this.intro,
    required this.segments,
    required this.outro,
    required this.format,
    required this.estimatedDuration,
  });

  String get fullScript {
    final buffer = StringBuffer();
    buffer.writeln(intro);
    buffer.writeln();
    
    for (int i = 0; i < segments.length; i++) {
      buffer.writeln('--- Segment ${i + 1} ---');
      buffer.writeln(segments[i]);
      buffer.writeln();
    }
    
    buffer.writeln('--- Closing ---');
    buffer.writeln(outro);
    
    return buffer.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'intro': intro,
      'segments': segments,
      'outro': outro,
      'format': format,
      'estimatedDuration': estimatedDuration,
    };
  }

  factory PodcastScript.fromJson(Map<String, dynamic> json) {
    return PodcastScript(
      title: json['title'] ?? '',
      intro: json['intro'] ?? '',
      segments: List<String>.from(json['segments'] ?? []),
      outro: json['outro'] ?? '',
      format: json['format'] ?? 'solo',
      estimatedDuration: json['estimatedDuration'] ?? 10,
    );
  }
}