class TextModel {
  final int? id;
  final String title;
  final String description;
  final String content;
  final DateTime createdAt;

  TextModel({
    this.id,
    required this.title,
    required this.description,
    required this.content,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Map (from database)
  factory TextModel.fromMap(Map<String, dynamic> map) {
    return TextModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  // Copy with method for updates
  TextModel copyWith({
    int? id,
    String? title,
    String? description,
    String? content,
    DateTime? createdAt,
  }) {
    return TextModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

