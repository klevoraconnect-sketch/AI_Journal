class JournalEntry {
  final String id;
  final String userId;
  final String? title;
  final String content;
  final String? moodTag;
  final bool isFavorite;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? sentimentScore;
  final String? aiReflection;

  JournalEntry({
    required this.id,
    required this.userId,
    this.title,
    required this.content,
    this.moodTag,
    this.isFavorite = false,
    this.imageUrls = const [],
    required this.createdAt,
    required this.updatedAt,
    this.sentimentScore,
    this.aiReflection,
  });

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      content: map['content'] ?? '',
      moodTag: map['mood_tag'],
      isFavorite: map['is_favorite'] ?? false,
      imageUrls: List<String>.from(map['image_urls'] ?? []),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      sentimentScore: map['sentiment_score'] != null
          ? (map['sentiment_score'] as num).toDouble()
          : null,
      aiReflection: map['ai_reflection'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'mood_tag': moodTag,
      'is_favorite': isFavorite,
      'image_urls': imageUrls,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sentiment_score': sentimentScore,
      'ai_reflection': aiReflection,
    };
  }

  JournalEntry copyWith({
    String? title,
    String? content,
    String? moodTag,
    bool? isFavorite,
    List<String>? imageUrls,
    DateTime? updatedAt,
    double? sentimentScore,
    String? aiReflection,
  }) {
    return JournalEntry(
      id: id,
      userId: userId,
      title: title ?? this.title,
      content: content ?? this.content,
      moodTag: moodTag ?? this.moodTag,
      isFavorite: isFavorite ?? this.isFavorite,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sentimentScore: sentimentScore ?? this.sentimentScore,
      aiReflection: aiReflection ?? this.aiReflection,
    );
  }
}
