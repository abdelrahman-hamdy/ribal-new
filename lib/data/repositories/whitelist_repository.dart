import 'package:injectable/injectable.dart';

import '../../core/constants/firebase_constants.dart';
import '../models/user_model.dart';
import '../models/whitelist_model.dart';
import '../services/firestore_service.dart';

/// Whitelist repository for CRUD operations
@lazySingleton
class WhitelistRepository {
  final FirestoreService _firestoreService;

  WhitelistRepository(this._firestoreService);

  /// Create whitelist entry
  Future<WhitelistModel> createWhitelistEntry(WhitelistModel entry) async {
    final docRef = await _firestoreService.createDocument(
      _firestoreService.whitelistCollection,
      entry.toFirestore(),
    );

    return entry.copyWith(id: docRef.id);
  }

  /// Get whitelist entry by email
  Future<WhitelistModel?> getWhitelistEntryByEmail(String email) async {
    final normalizedEmail = email.toLowerCase().trim();
    final snapshot = await _firestoreService.whitelistCollection
        .where(FirebaseConstants.whitelistEmail, isEqualTo: normalizedEmail)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return WhitelistModel.fromFirestore(snapshot.docs.first);
  }

  /// Check if email is whitelisted
  Future<bool> isEmailWhitelisted(String email) async {
    final entry = await getWhitelistEntryByEmail(email);
    return entry != null;
  }

  /// Get role for whitelisted email
  Future<UserRole?> getRoleForEmail(String email) async {
    final entry = await getWhitelistEntryByEmail(email);
    return entry?.role;
  }

  /// Get all whitelist entries
  Future<List<WhitelistModel>> getAllWhitelistEntries() async {
    final snapshot = await _firestoreService.whitelistCollection
        .orderBy(FirebaseConstants.whitelistCreatedAt, descending: true)
        .get();

    return snapshot.docs
        .map((doc) => WhitelistModel.fromFirestore(doc))
        .toList();
  }

  /// Stream all whitelist entries
  Stream<List<WhitelistModel>> streamAllWhitelistEntries() {
    return _firestoreService.whitelistCollection
        .orderBy(FirebaseConstants.whitelistCreatedAt, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WhitelistModel.fromFirestore(doc))
            .toList());
  }

  /// Delete whitelist entry
  Future<void> deleteWhitelistEntry(String id) async {
    await _firestoreService.deleteDocument(
      _firestoreService.whitelistDoc(id),
    );
  }

  /// Delete whitelist entry by email
  Future<void> deleteWhitelistEntryByEmail(String email) async {
    final normalizedEmail = email.toLowerCase().trim();
    final snapshot = await _firestoreService.whitelistCollection
        .where(FirebaseConstants.whitelistEmail, isEqualTo: normalizedEmail)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
