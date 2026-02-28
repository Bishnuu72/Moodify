class MoodEntry {
  final String id;
  final String userId;
  final String mood;
  final String emoji;
  final int intensity; // 1-10
  final String? journalEntry;
  final List<String> tags;
  final DateTime createdAt;
  final String? imageUrl;

  MoodEntry({
    required this.id,
    required this.userId,
    required this.mood,
    required this.emoji,
    required this.intensity,
    this.journalEntry,
    this.tags = const [],
    required this.createdAt,
    this.imageUrl,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      mood: json['mood'] ?? '',
      emoji: json['emoji'] ?? '',
      intensity: json['intensity'] ?? 5,
      journalEntry: json['journalEntry'],
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'mood': mood,
      'emoji': emoji,
      'intensity': intensity,
      'journalEntry': journalEntry,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }
}