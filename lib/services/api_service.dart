import 'dart:convert';
import 'package:http/http.dart' as http;

// Cache entry for user profiles
class _CachedUser {
  final Map<String, dynamic> data;
  final DateTime expiresAt;
  
  _CachedUser(this.data, this.expiresAt);
  
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class ApiService {
  // Change this to your computer's IP address when testing on real device
  // For Android emulator use: 10.0.2.2
  // For iOS simulator use: localhost
  static const String baseUrl = 'http://10.0.2.2:5001/api';
  
  // Cache for user profiles (expires after 5 minutes)
  static final Map<String, _CachedUser> _userProfileCache = {};
  static const Duration _cacheDuration = Duration(minutes: 5);

  // Create new user (during registration)
  static Future<Map<String, dynamic>> createUser({
    required String userId,
    required String email,
    required String role,
    String? displayName,
  }) async {
    try {
      print('🌐 Creating user in MongoDB: $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'email': email,
          'role': role,
          'displayName': displayName ?? '',
          'photoUrl': null,
          'bio': null,
          'specialization': null,
          'experience': null,
          'phone': null,
          'preferredMood': '',
          'interests': [],
        }),
      );

      print('📊 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ User created successfully in MongoDB');
        return data;
      } else {
        final errorData = json.decode(response.body);
        print('❌ Failed to create user: $errorData');
        throw Exception('Failed to create user: ${errorData['message']}');
      }
    } catch (e) {
      print('❌ Error creating user: $e');
      throw Exception('Error: $e');
    }
  }

  // Get user moods
  static Future<Map<String, dynamic>> getUserMoods(String userId, {int limit = 50, int skip = 0}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/moods/$userId?limit=$limit&skip=$skip'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load moods');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Create new mood
  static Future<Map<String, dynamic>> createMood({
    required String userId,
    required String mood,
    int? emotionScore,
    String? note,
    List<String>? tags,
    String? imageUrl,
    String? weather,
    String? location,
    bool? isAnonymous,
  }) async {
    try {
      print('🌐 Sending mood creation request to: $baseUrl/moods');
      print('📦 Request body: userId=$userId, mood=$mood, isAnonymous=$isAnonymous');
      
      final response = await http.post(
        Uri.parse('$baseUrl/moods'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'mood': mood,
          'emotionScore': emotionScore ?? 5,
          'note': note ?? '',
          'tags': tags ?? [],
          'imageUrl': imageUrl,
          'weather': weather,
          'location': location,
          'isAnonymous': isAnonymous ?? false,
        }),
      );

      print('📊 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 201) {
        print('✅ Mood created successfully');
        return json.decode(response.body);
      } else {
        print('❌ Failed to create mood - Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to create mood: ${response.body}');
      }
    } catch (e) {
      print('❌ Error creating mood: $e');
      throw Exception('Error: $e');
    }
  }

  // Update mood
  static Future<Map<String, dynamic>> updateMood(String id, Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/moods/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update mood');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Delete mood
  static Future<Map<String, dynamic>> deleteMood(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/moods/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to delete mood');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get mood statistics
  static Future<Map<String, dynamic>> getMoodStats(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/moods/stats/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load statistics');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get user profile (with caching)
  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      // Check cache first
      final cachedUser = _userProfileCache[userId];
      if (cachedUser != null && !cachedUser.isExpired) {
        print('💾 Returning cached profile for: $userId');
        return cachedUser.data;
      }
      
      print('🌐 Fetching user profile from: $baseUrl/users/$userId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('📊 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Cache the result
        _userProfileCache[userId] = _CachedUser(
          data,
          DateTime.now().add(_cacheDuration),
        );
        print('✅ User profile loaded and cached successfully');
        return data;
      } else if (response.statusCode == 429) {
        // Rate limit hit - try to use stale cache if available
        if (cachedUser != null) {
          print('⚠️ Rate limited but using stale cache for: $userId');
          return cachedUser.data;
        }
        print('❌ Rate limited and no cache available');
        throw Exception('Too many requests. Please wait a moment.');
      } else {
        print('❌ Failed to load profile - Status: ${response.statusCode}');
        throw Exception('Failed to load user profile: ${response.body}');
      }
    } catch (e) {
      print('❌ Error fetching user profile: $e');
      // If we have stale cache, use it even if expired
      final cachedUser = _userProfileCache[userId];
      if (cachedUser != null) {
        print('⚠️ Using stale cache due to error for: $userId');
        return cachedUser.data;
      }
      throw Exception('Error: $e');
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    try {
      print('🌐 PUT /api/users/$userId');
      print('📦 Request body: ${json.encode(updates)}');
      
      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updates),
      );

      print('📊 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Profile updated successfully on server');
        return data;
      } else {
        print('❌ Failed to update profile - Status: ${response.statusCode}');
        throw Exception('Failed to update profile: ${response.body}');
      }
    } catch (e) {
      print('❌ Error updating profile: $e');
      throw Exception('Error: $e');
    }
  }

  // Clear user profile cache
  static void clearUserProfileCache() {
    _userProfileCache.clear();
    print('🗑️ User profile cache cleared');
  }

  // Health check
  static Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get users by role
  static Future<Map<String, dynamic>> getUsersByRole(String role, {int limit = 100, int skip = 0}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users?role=$role&limit=$limit&skip=$skip'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
