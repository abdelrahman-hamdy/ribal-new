import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/firebase_constants.dart';
import '../models/invitation_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

/// Invitation repository for CRUD operations
@lazySingleton
class InvitationRepository {
  final FirestoreService _firestoreService;
  final _random = Random.secure();

  InvitationRepository(this._firestoreService);

  /// Generate unique invitation code
  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
      AppConstants.invitationCodeLength,
      (_) => chars[_random.nextInt(chars.length)],
    ).join();
  }

  /// Create invitation
  Future<InvitationModel> createInvitation({
    required UserRole role,
    required String createdBy,
  }) async {
    String code;
    bool exists;

    // Generate unique code
    do {
      code = _generateCode();
      final doc = await _firestoreService.invitationDoc(code).get();
      exists = doc.exists;
    } while (exists);

    final invitation = InvitationModel(
      code: code,
      role: role,
      createdBy: createdBy,
      createdAt: DateTime.now(),
    );

    await _firestoreService.setDocument(
      _firestoreService.invitationDoc(code),
      invitation.toFirestore(),
    );

    return invitation;
  }

  /// Get invitation by code
  Future<InvitationModel?> getInvitationByCode(String code) async {
    final normalizedCode = code.toUpperCase().trim();
    final doc = await _firestoreService.invitationDoc(normalizedCode).get();
    if (!doc.exists) return null;
    return InvitationModel.fromFirestore(doc);
  }

  /// Validate invitation code
  Future<InvitationModel?> validateInvitationCode(String code) async {
    final invitation = await getInvitationByCode(code);
    if (invitation == null || invitation.used) return null;
    return invitation;
  }

  /// Use invitation (mark as used)
  Future<void> useInvitation({
    required String code,
    required String userId,
  }) async {
    final normalizedCode = code.toUpperCase().trim();
    await _firestoreService.updateDocument(
      _firestoreService.invitationDoc(normalizedCode),
      {
        FirebaseConstants.invitationUsed: true,
        FirebaseConstants.invitationUsedBy: userId,
        FirebaseConstants.invitationUsedAt: FieldValue.serverTimestamp(),
      },
    );
  }

  /// Get all invitations
  Future<List<InvitationModel>> getAllInvitations() async {
    final snapshot = await _firestoreService.invitationsCollection
        .orderBy(FirebaseConstants.invitationCreatedAt, descending: true)
        .get();

    return snapshot.docs
        .map((doc) => InvitationModel.fromFirestore(doc))
        .toList();
  }

  /// Stream all invitations
  Stream<List<InvitationModel>> streamAllInvitations() {
    return _firestoreService.invitationsCollection
        .orderBy(FirebaseConstants.invitationCreatedAt, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InvitationModel.fromFirestore(doc))
            .toList());
  }

  /// Get unused invitations
  Future<List<InvitationModel>> getUnusedInvitations() async {
    final snapshot = await _firestoreService.invitationsCollection
        .where(FirebaseConstants.invitationUsed, isEqualTo: false)
        .orderBy(FirebaseConstants.invitationCreatedAt, descending: true)
        .get();

    return snapshot.docs
        .map((doc) => InvitationModel.fromFirestore(doc))
        .toList();
  }

  /// Delete invitation
  Future<void> deleteInvitation(String code) async {
    final normalizedCode = code.toUpperCase().trim();
    await _firestoreService.deleteDocument(
      _firestoreService.invitationDoc(normalizedCode),
    );
  }

  /// Get invitations count by status
  Future<Map<String, int>> getInvitationsCount() async {
    final allInvitations = await getAllInvitations();
    final used = allInvitations.where((i) => i.used).length;
    final unused = allInvitations.where((i) => !i.used).length;

    return {
      'total': allInvitations.length,
      'used': used,
      'unused': unused,
    };
  }
}
