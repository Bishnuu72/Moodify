import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    notifyListeners();
  }

  Future<void> signUpWithEmail(String email, String password, String role, {String? fullName}) async {
    try {
      print('🔵 Starting registration for: $email with role: $role');
      
      // Create user with Firebase Auth only (for authentication)
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Firebase Auth created user: ${userCredential.user!.uid}');

      // Store user profile in MongoDB via API
      print('💾 Saving user to MongoDB...');
      final result = await ApiService.createUser(
        userId: userCredential.user!.uid,
        email: email,
        role: role,
        displayName: fullName ?? '',
      );

      print('✅ MongoDB save result: ${result['success']}');
      print('✅ User saved to MongoDB with ID: ${result['data']['userId']}');

      notifyListeners();
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
    await _auth.signOut();
    notifyListeners();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
