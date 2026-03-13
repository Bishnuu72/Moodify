class Notification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // 'verification', 'system', 'message'
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.metadata,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'system',
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }
}
