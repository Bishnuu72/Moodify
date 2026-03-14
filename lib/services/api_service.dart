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
  
  // Clear cache for specific user
  static void clearUserCache(String userId) {
    print('🗑️ Clearing cache for user: $userId');
    _userProfileCache.remove(userId);
  }
  
  // Clear all user caches
  static void clearAllCaches() {
    print('🗑️ Clearing all user caches');
    _userProfileCache.clear();
  }

  // Register new user in MongoDB only
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String role,
    String? displayName,
  }) async {
    try {
      print('🌐 Registering user in MongoDB: $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'role': role,
          'displayName': displayName ?? '',
        }),
      );

      print('📊 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ User registered successfully in MongoDB');
        return data;
      } else {
        final errorData = json.decode(response.body);
        print('❌ Failed to register user: $errorData');
        throw Exception('Failed to register user: ${errorData['message']}');
      }
    } catch (e) {
      print('❌ Error registering user: $e');
      throw Exception('Error: $e');
    }
  }

  // Login user with MongoDB credentials
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('🌐 Logging in user: $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      print('📊 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ User logged in successfully');
        return data;
      } else {
        final errorData = json.decode(response.body);
        print('❌ Login failed: $errorData');
        throw Exception('Login failed: ${errorData['message']}');
      }
    } catch (e) {
      print('❌ Error logging in: $e');
      throw Exception('Error: $e');
    }
  }

  // Create new user (during registration) - DEPRECATED, use register() instead
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

  // Get all users (Admin)
  static Future<Map<String, dynamic>> getAllUsers({int limit = 100, int skip = 0}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users?limit=$limit&skip=$skip'),
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

  // Delete user (Admin)
  static Future<Map<String, dynamic>> deleteUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/$userId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete user');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Suspend user (Admin)
  static Future<Map<String, dynamic>> suspendUser(String userId, {
    DateTime? suspendedUntil,
    String? reason,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId/suspend'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'suspendedUntil': suspendedUntil?.toIso8601String(),
          'reason': reason,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to suspend user');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Unsuspend user (Admin)
  static Future<Map<String, dynamic>> unsuspendUser(String userId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId/unsuspend'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to unsuspend user');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get wellness activities (Public)
  static Future<Map<String, dynamic>> getWellnessActivities({String? category}) async {
    try {
      String url = '$baseUrl/wellness';
      if (category != null) {
        url += '?category=$category';
      }
      
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load wellness activities');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get single wellness activity
  static Future<Map<String, dynamic>> getWellnessActivity(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/wellness/$id'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load wellness activity');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Create wellness activity (Admin)
  static Future<Map<String, dynamic>> createWellnessActivity(Map<String, dynamic> activityData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/wellness/admin/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(activityData),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create wellness activity');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Update wellness activity (Admin)
  static Future<Map<String, dynamic>> updateWellnessActivity(String id, Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/wellness/admin/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update wellness activity');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Delete wellness activity (Admin)
  static Future<Map<String, dynamic>> deleteWellnessActivity(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/wellness/admin/$id'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete wellness activity');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get admin's wellness activities
  static Future<Map<String, dynamic>> getAdminWellnessActivities(String adminId, {String? category}) async {
    try {
      String url = '$baseUrl/wellness/admin/$adminId';
      if (category != null) {
        url += '?category=$category';
      }
      
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load admin wellness activities');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  // Submit therapist verification
  static Future<Map<String, dynamic>> submitVerification(
    String userId,
    Map<String, String> documentUrls,
  ) async {
    try {
      print('🌐 Submitting verification for user: $userId');
      
      final response = await http.post(
        Uri.parse('$baseUrl/verification/submit'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'documents': documentUrls,
        }),
      );
      
      print('📊 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ Verification submitted successfully');
        return data;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to submit verification');
      }
    } catch (e) {
      print('❌ Error submitting verification: $e');
      throw Exception('Error: $e');
    }
  }
  
  // Get pending verifications (for admin)
  static Future<Map<String, dynamic>> getPendingVerifications() async {
    try {
      print('🌐 Fetching pending verifications...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/verification/pending'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Fetched ${data['data']?.length ?? 0} pending verifications');
        return data;
      } else {
        throw Exception('Failed to load pending verifications');
      }
    } catch (e) {
      print('❌ Error fetching pending verifications: $e');
      throw Exception('Error: $e');
    }
  }
  
  // Review verification (approve/reject)
  static Future<Map<String, dynamic>> reviewVerification(
    String userId,
    bool approved,
    String? rejectionReason,
  ) async {
    try {
      print('🌐 Reviewing verification for user: $userId, approved: $approved');
      
      final response = await http.put(
        Uri.parse('$baseUrl/verification/review'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'approved': approved,
          'rejectionReason': rejectionReason,
        }),
      );
      
      print('📊 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Verification review completed');
        return data;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to review verification');
      }
    } catch (e) {
      print('❌ Error reviewing verification: $e');
      throw Exception('Error: $e');
    }
  }
  
  // Get verification status for a user
  static Future<Map<String, dynamic>> getVerificationStatus(String userId) async {
    try {
      print('🌐 Fetching verification status for user: $userId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/verification/status/$userId'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Verification status: ${data['status']}');
        return data;
      } else {
        throw Exception('Failed to load verification status');
      }
    } catch (e) {
      print('❌ Error fetching verification status: $e');
      throw Exception('Error: $e');
    }
  }
  
  // Get notifications for a user
  static Future<Map<String, dynamic>> getNotifications(String userId) async {
    try {
      print('🌐 Fetching notifications for user: $userId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/$userId'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Fetched ${data['data']?.length ?? 0} notifications');
        return data;
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      print('❌ Error fetching notifications: $e');
      throw Exception('Error: $e');
    }
  }
  
  // Send a message
  static Future<Map<String, dynamic>> sendMessage({
    required String senderId,
    required String receiverId,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages/send'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'senderId': senderId,
          'receiverId': receiverId,
          'message': message,
        }),
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Invalid message data');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to send message');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  // Get messages between two users
  static Future<Map<String, dynamic>> getMessages(String userId1, String userId2) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages/$userId1/$userId2'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 404) {
        throw Exception('Messages not found');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to load messages');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  // Get conversations for a user (therapist dashboard)
  static Future<Map<String, dynamic>> getConversations(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages/conversations/$userId'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 404) {
        throw Exception('Conversations not found');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to load conversations');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  // Mark messages as read
  static Future<Map<String, dynamic>> markAsRead(String senderId, String receiverId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/messages/read'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'senderId': senderId,
          'receiverId': receiverId,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Invalid request');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to mark messages as read');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  // Declare user as patient
  static Future<Map<String, dynamic>> declareAsPatient(String userId, String therapistId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/declare-patient'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'therapistId': therapistId,
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Invalid request');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to declare as patient');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  // Get therapist's patients
  static Future<Map<String, dynamic>> getTherapistPatients(String therapistId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/patients/$therapistId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 404) {
        throw Exception('No patients found');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch patients');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  // Create schedule/appointment
  static Future<Map<String, dynamic>> createSchedule({
    required String therapistId,
    required String patientId,
    required String patientName,
    required String patientEmail,
    String? patientPhotoUrl,
    required String appointmentType,
    required DateTime scheduledDate,
    required String scheduledTime,
    int duration = 30,
    String? notes,
  }) async {
    try {
      // Format date as YYYY-MM-DD (without timezone)
      final year = scheduledDate.year;
      final month = scheduledDate.month.toString().padLeft(2, '0');
      final day = scheduledDate.day.toString().padLeft(2, '0');
      final dateString = '$year-$month-$day';
      
      final response = await http.post(
        Uri.parse('$baseUrl/schedules'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'therapistId': therapistId,
          'patientId': patientId,
          'patientName': patientName,
          'patientEmail': patientEmail,
          'patientPhotoUrl': patientPhotoUrl,
          'appointmentType': appointmentType,
          'scheduledDate': dateString, // Send as YYYY-MM-DD string
          'scheduledTime': scheduledTime,
          'duration': duration,
          'notes': notes,
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 409) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Time slot already booked');
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Invalid request');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create schedule');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  // Get therapist schedules
  static Future<Map<String, dynamic>> getTherapistSchedules(String therapistId, {String? status}) async {
    try {
      String url = '$baseUrl/schedules/therapist/$therapistId';
      if (status != null && status.isNotEmpty) {
        url += '?status=$status';
      }
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch schedules');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  // Delete schedule
  static Future<Map<String, dynamic>> deleteSchedule(String scheduleId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/schedules/$scheduleId'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 404) {
        throw Exception('Schedule not found');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete schedule');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  // Save patient note
  static Future<Map<String, dynamic>> savePatientNote({
    required String therapistId,
    required String patientId,
    required String patientName,
    required String note,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notes'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'therapistId': therapistId,
          'patientId': patientId,
          'patientName': patientName,
          'note': note,
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Invalid request');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to save note');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  // Get patient notes
  static Future<Map<String, dynamic>> getPatientNotes(String patientId, String therapistId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notes/patient/$patientId?therapistId=$therapistId'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch notes');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: ${e.toString()}');
    }
  }
}
