class WellnessTool {
  final String id;
  final String title;
  final String description;
  final String category;
  final String icon;
  final int duration; // in minutes
  final String difficulty;
  final List<String> benefits;

  WellnessTool({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.duration,
    required this.difficulty,
    this.benefits = const [],
  });

  factory WellnessTool.fromJson(Map<String, dynamic> json) {
    return WellnessTool(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      icon: json['icon'] ?? '',
      duration: json['duration'] ?? 0,
      difficulty: json['difficulty'] ?? '',
      benefits: List<String>.from(json['benefits'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'icon': icon,
      'duration': duration,
      'difficulty': difficulty,
      'benefits': benefits,
    };
  }
}