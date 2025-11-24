import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

/// Firebase Authentication service
@lazySingleton
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Current Firebase user
  User? get currentUser => _auth.currentUser;

  /// Current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  /// Check if email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  /// Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  /// Reload current user (to check email verification status)
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Update display name
  Future<void> updateDisplayName(String displayName) async {
    await _auth.currentUser?.updateDisplayName(displayName);
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Delete account
  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }

  /// Reauthenticate with credential
  Future<UserCredential?> reauthenticateWithCredential({
    required String email,
    required String password,
  }) async {
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    return await _auth.currentUser?.reauthenticateWithCredential(credential);
  }

  /// Update password
  Future<void> updatePassword(String newPassword) async {
    await _auth.currentUser?.updatePassword(newPassword);
  }

  /// Change password (re-authenticate first, then update)
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('User not authenticated');
    }

    // Re-authenticate with current password
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);

    // Update to new password
    await user.updatePassword(newPassword);
  }
}
