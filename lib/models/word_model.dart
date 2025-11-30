class WordModel {
  final int? id;
  final int dictionaryId;
  final String word;
  final String? translation;
  final String? context;
  final DateTime createdAt;

  WordModel({
    this.id,
    required this.dictionaryId,
    required this.word,
    this.translation,
    this.context,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dictionaryId': dictionaryId,
      'word': word,
      'translation': translation,
      'context': context,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WordModel.fromMap(Map<String, dynamic> map) {
    return WordModel(
      id: map['id'] as int?,
      dictionaryId: map['dictionaryId'] as int,
      word: map['word'] as String,
      translation: map['translation'] as String?,
      context: map['context'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  WordModel copyWith({
    int? id,
    int? dictionaryId,
    String? word,
    String? translation,
    String? context,
    DateTime? createdAt,
  }) {
    return WordModel(
      id: id ?? this.id,
      dictionaryId: dictionaryId ?? this.dictionaryId,
      word: word ?? this.word,
      translation: translation ?? this.translation,
      context: context ?? this.context,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

