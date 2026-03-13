import 'package:flutter/foundation.dart';
import 'api_service.dart';

// Simple user session model
class UserSession {
  final String uid;
  final Map<String, dynamic> data;
  
  UserSession(this.uid, this.data);
  
  String get email => data['email'] ?? '';
  String? get displayName => data['displayName'];
  String get role => data['role'] ?? 'user';
}

class AuthService extends ChangeNotifier {
  // Simple session management
  String? _currentUserId;
  Map<String, dynamic>? _currentUserData;

  UserSession? get currentUser => 
      _currentUserId != null && _currentUserData != null 
          ? UserSession(_currentUserId!, _currentUserData!) 
          : null;

  Future<void> signInWithEmail(String email, String password) async {
    try {
      print('🔵 Starting login for: $email');
      
      // Call backend API to authenticate user
      final response = await ApiService.login(email, password);
      
      if (response['success'] == true) {
        _currentUserId = response['data']['userId'];
        _currentUserData = response['data'];
        print('✅ Login successful for user: ${_currentUserId}');
        notifyListeners();
      } else {
        throw Exception(response['message'] ?? 'Login failed');
      }
    } catch (e) {
      print('❌ Login error: $e');
      rethrow;
    }
  }

  Future<void> signUpWithEmail(String email, String password, String role, {String? fullName}) async {
    try {
      print('🔵 Starting registration for: $email with role: $role');
      
      // Register user directly in MongoDB
      print('💾 Registering user in MongoDB...');
      final result = await ApiService.register(
        email: email,
        password: password,
        role: role,
        displayName: fullName ?? '',
      );

      if (result['success'] == true) {
        print('✅ MongoDB registration successful');
        print('✅ User created with ID: ${result['data']['userId']}');
        
        // Auto-login after registration
        _currentUserId = result['data']['userId'];
        _currentUserData = result['data'];
        notifyListeners();
      } else {
        throw Exception(result['message'] ?? 'Registration failed');
      }
    } catch (e) {
      print('❌ Registration error: $e');
      rethrow;
    }
  }

  Future<String?> getUserRole(String uid) async {
    try {
      // Get user from MongoDB
      final response = await ApiService.getUserProfile(uid);
      if (response['success'] == true && response['data'] != null) {
        return response['data']['role'] ?? 'user';
      }
      return 'user';
    } catch (e) {
      print('Error getting user role from MongoDB: $e');
      return 'user';
    }
  }

  Future<void> signOut() async {
    _currentUserId = null;
    _currentUserData = null;
    print('👋 User logged out');
    notifyListeners();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    // For now, just show a message - implement later with backend
    print('Password reset requested for: $email');
    throw UnimplementedError('Password reset not implemented yet');
  }
}
