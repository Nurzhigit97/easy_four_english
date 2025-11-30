class DictionaryModel {
  final int? id;
  final String title;
  final DateTime createdAt;

  DictionaryModel({
    this.id,
    required this.title,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DictionaryModel.fromMap(Map<String, dynamic> map) {
    return DictionaryModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  DictionaryModel copyWith({
    int? id,
    String? title,
    DateTime? createdAt,
  }) {
    return DictionaryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

