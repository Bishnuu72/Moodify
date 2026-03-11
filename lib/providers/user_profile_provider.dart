import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class UserProfileProvider extends ChangeNotifier {
  final AuthService _authService;
  
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  String? _error;

  UserProfileProvider(this._authService);

  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  String get displayName {
    return _userProfile?['displayName'] ?? 
           _authService.currentUser?.email?.split('@')[0] ?? 
           'User';
  }

  String get email {
    return _userProfile?['email'] ?? 
           _authService.currentUser?.email ?? 
           '';
  }

  String get role {
    return _userProfile?['role'] ?? 'user';
  }

  String? get photoUrl => _userProfile?['photoUrl'];
  String? get bio => _userProfile?['bio'];
  String? get specialization => _userProfile?['specialization'];
  int get moodEntriesCount => _userProfile?['moodEntriesCount'] ?? 0;
  DateTime? get createdAt {
    try {
      if (_userProfile?['createdAt'] != null) {
        return DateTime.parse(_userProfile!['createdAt']);
      }
    } catch (e) {}
    return null;
  }

  Future<void> loadUserProfile() async {
    final user = _authService.currentUser;
    if (user == null) {
      _error = 'User not logged in';
      notifyListeners();
      return;
    }

    setStateLoading(true);
    
    try {
      print('🔵 Loading user profile from MongoDB for: ${user.uid}');
      
      final response = await ApiService.getUserProfile(user.uid);
      
      print('📦 API Response structure: success=${response['success']}, hasData=${response['data'] != null}');
      
      if (response['success'] == true && response['data'] != null) {
        _userProfile = response['data'];
        _error = null;
        print('✅ User profile loaded: ${_userProfile?['displayName']}');
      } else {
        _error = 'Failed to load profile';
        print('❌ Failed to load profile: success=${response['success']}, message=${response['message']}');
      }
    } catch (e) {
      _error = 'Error: $e';
      print('❌ Error loading profile: $e');
      print('❌ Full error details: ${e.toString()}');
    } finally {
      setStateLoading(false);
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final user = _authService.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      print('💾 Updating user profile...');
      
      final response = await ApiService.updateUserProfile(user.uid, updates);
      
      if (response['success'] == true) {
        _userProfile = response['data'];
        print('✅ Profile updated successfully');
        notifyListeners();
      } else {
        throw Exception(response['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      print('❌ Error updating profile: $e');
      rethrow;
    }
  }

  void setStateLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
