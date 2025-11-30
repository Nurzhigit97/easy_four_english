class WritingAnswerModel {
  final int? id;
  final int textId;
  final String writing;
  final DateTime createdAt;

  WritingAnswerModel({
    this.id,
    required this.textId,
    required this.writing,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'textId': textId,
      'writing': writing,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WritingAnswerModel.fromMap(Map<String, dynamic> map) {
    return WritingAnswerModel(
      id: map['id'] as int?,
      textId: map['textId'] as int,
      writing: map['writing'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  WritingAnswerModel copyWith({
    int? id,
    int? textId,
    String? writing,
    DateTime? createdAt,
  }) {
    return WritingAnswerModel(
      id: id ?? this.id,
      textId: textId ?? this.textId,
      writing: writing ?? this.writing,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
