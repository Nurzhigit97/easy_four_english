class SpeakingAnswerModel {
  final int? id;
  final int textId;
  final String answer;
  final DateTime createdAt;

  SpeakingAnswerModel({
    this.id,
    required this.textId,
    required this.answer,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'textId': textId,
      'answer': answer,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SpeakingAnswerModel.fromMap(Map<String, dynamic> map) {
    return SpeakingAnswerModel(
      id: map['id'] as int?,
      textId: map['textId'] as int,
      answer: map['answer'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  SpeakingAnswerModel copyWith({
    int? id,
    int? textId,
    String? answer,
    DateTime? createdAt,
  }) {
    return SpeakingAnswerModel(
      id: id ?? this.id,
      textId: textId ?? this.textId,
      answer: answer ?? this.answer,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
