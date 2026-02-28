class UserProfile {
  final String userId;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final String? bio;
  final DateTime createdAt;
  final int moodEntriesCount;
  final String preferredMood;
  final List<String> interests;
  final String role; // 'user', 'therapist', 'admin'

  UserProfile({
    required this.userId,
    this.displayName,
    this.email,
    this.photoUrl,
    this.bio,
    required this.createdAt,
    this.moodEntriesCount = 0,
    this.preferredMood = '',
    this.interests = const [],
    this.role = 'user',
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] ?? '',
      displayName: json['displayName'],
      email: json['email'],
      photoUrl: json['photoUrl'],
      bio: json['bio'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      moodEntriesCount: json['moodEntriesCount'] ?? 0,
      preferredMood: json['preferredMood'] ?? '',
      interests: List<String>.from(json['interests'] ?? []),
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'bio': bio,
      'createdAt': createdAt.toIso8601String(),
      'moodEntriesCount': moodEntriesCount,
      'preferredMood': preferredMood,
      'interests': interests,
      'role': role,
    };
  }
}