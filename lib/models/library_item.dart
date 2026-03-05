enum LibraryItemType {
  audiobook,
  summary,
  debate,
  voiceChat,
}

class LibraryItem {
  final String id;
  final String title;
  final LibraryItemType type;
  final String content; // summary text, debate transcript, or snippet for audiobook
  final String? contentPath; // Path to local file if content is large
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  LibraryItem({
    required this.id,
    required this.title,
    required this.type,
    required this.content,
    this.contentPath,
    required this.createdAt,
    this.metadata,
  });

  factory LibraryItem.fromJson(Map<String, dynamic> json) {
    return LibraryItem(
      id: json['id'] as String,
      title: json['title'] as String,
      type: LibraryItemType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => LibraryItemType.summary,
      ),
      content: json['content'] as String,
      contentPath: json['contentPath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'content': content,
      'contentPath': contentPath,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  String get preview {
    if (content.length <= 500) return content;
    return '${content.substring(0, 500)}...';
  }
}
