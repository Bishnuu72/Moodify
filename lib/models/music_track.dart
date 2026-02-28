class MusicTrack {
  final String id;
  final String title;
  final String artist;
  final String mood;
  final String imageUrl;
  final String previewUrl;
  final int duration; // in seconds
  final List<String> tags;

  MusicTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.mood,
    required this.imageUrl,
    required this.previewUrl,
    required this.duration,
    this.tags = const [],
  });

  factory MusicTrack.fromJson(Map<String, dynamic> json) {
    return MusicTrack(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      mood: json['mood'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      previewUrl: json['previewUrl'] ?? '',
      duration: json['duration'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'mood': mood,
      'imageUrl': imageUrl,
      'previewUrl': previewUrl,
      'duration': duration,
      'tags': tags,
    };
  }
}