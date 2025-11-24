import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';

/// Authentication repository
@lazySingleton
class AuthRepository {
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;

  AuthRepository(this._authService, this._firestoreService);

  /// Current user ID
  String? get currentUserId => _authService.currentUserId;

  /// Check if user is signed in
  bool get isSignedIn => _authService.isSignedIn;

  /// Check if email is verified
  bool get isEmailVerified => _authService.isEmailVerified;

  /// Auth state changes stream
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  /// Sign in with email and password
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    debugPrint('🔐 [AuthRepo] Starting signIn for: $email');

    final credential = await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    debugPrint('🔐 [AuthRepo] Firebase Auth result: ${credential.user?.uid}');

    if (credential.user == null) {
      debugPrint('🔐 [AuthRepo] ❌ credential.user is null');
      return null;
    }

    // Get user data from Firestore
    debugPrint('🔐 [AuthRepo] Fetching Firestore doc for uid: ${credential.user!.uid}');

    try {
      final doc = await _firestoreService.userDoc(credential.user!.uid).get();
      debugPrint('🔐 [AuthRepo] Doc exists: ${doc.exists}');

      if (!doc.exists) {
        debugPrint('🔐 [AuthRepo] ❌ Document does not exist in Firestore');
        return null;
      }

      debugPrint('🔐 [AuthRepo] Raw doc data: ${doc.data()}');

      final user = UserModel.fromFirestore(doc);
      debugPrint('🔐 [AuthRepo] ✅ UserModel created: ${user.fullName}, role: ${user.role}');

      return user;
    } catch (e, stackTrace) {
      debugPrint('🔐 [AuthRepo] ❌ Error parsing user: $e');
      debugPrint('🔐 [AuthRepo] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Register new user
  Future<UserModel> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
  }) async {
    // Create Firebase Auth account
    final credential = await _authService.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user == null) {
      throw Exception('Failed to create user account');
    }

    final userId = credential.user!.uid;
    final now = DateTime.now();

    // Create user document in Firestore
    final user = UserModel(
      id: userId,
      firstName: firstName,
      lastName: lastName,
      email: email.toLowerCase().trim(),
      role: role,
      createdAt: now,
      updatedAt: now,
    );

    await _firestoreService.setDocument(
      _firestoreService.userDoc(userId),
      user.toFirestore(),
    );

    // Update display name
    await _authService.updateDisplayName('$firstName $lastName');

    // Send email verification
    await _authService.sendEmailVerification();

    return user;
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    await _authService.sendEmailVerification();
  }

  /// Reload user to check email verification
  Future<bool> checkEmailVerified() async {
    await _authService.reloadUser();
    return _authService.isEmailVerified;
  }

  /// Get current user data
  Future<UserModel?> getCurrentUser() async {
    final userId = _authService.currentUserId;
    if (userId == null) return null;

    final doc = await _firestoreService.userDoc(userId).get();
    if (!doc.exists) return null;

    return UserModel.fromFirestore(doc);
  }

  /// Stream current user data
  Stream<UserModel?> streamCurrentUser() {
    final userId = _authService.currentUserId;
    if (userId == null) return Stream.value(null);

    return _firestoreService
        .streamDocument(_firestoreService.userDoc(userId))
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  /// Update FCM token
  Future<void> updateFcmToken(String token) async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    await _firestoreService.updateDocument(
      _firestoreService.userDoc(userId),
      {
        'fcmTokens': FieldValue.arrayUnion([token]),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );
  }

  /// Remove FCM token
  Future<void> removeFcmToken(String token) async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    await _firestoreService.updateDocument(
      _firestoreService.userDoc(userId),
      {
        'fcmTokens': FieldValue.arrayRemove([token]),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await _authService.signOut();
  }
}
