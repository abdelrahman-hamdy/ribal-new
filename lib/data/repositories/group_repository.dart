import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/firebase_constants.dart';
import '../models/group_model.dart';
import '../services/firestore_service.dart';

/// Group repository for CRUD operations
@lazySingleton
class GroupRepository {
  final FirestoreService _firestoreService;

  GroupRepository(this._firestoreService);

  /// Create group
  Future<GroupModel> createGroup(GroupModel group) async {
    final docRef = await _firestoreService.createDocument(
      _firestoreService.groupsCollection,
      group.toFirestore(),
    );

    return group.copyWith(id: docRef.id);
  }

  /// Get group by ID
  Future<GroupModel?> getGroupById(String groupId) async {
    final doc = await _firestoreService.groupDoc(groupId).get();
    if (!doc.exists) return null;
    return GroupModel.fromFirestore(doc);
  }

  /// Stream group by ID
  Stream<GroupModel?> streamGroup(String groupId) {
    return _firestoreService
        .streamDocument(_firestoreService.groupDoc(groupId))
        .map((doc) => doc.exists ? GroupModel.fromFirestore(doc) : null);
  }

  /// Get all groups (limited to 30 for performance)
  Future<List<GroupModel>> getAllGroups() async {
    final snapshot = await _firestoreService.groupsCollection
        .orderBy(FirebaseConstants.groupName)
        .limit(30) // Safety limit for free tier
        .get();

    return snapshot.docs.map((doc) => GroupModel.fromFirestore(doc)).toList();
  }

  /// Stream all groups
  Stream<List<GroupModel>> streamAllGroups() {
    return _firestoreService.groupsCollection
        .orderBy(FirebaseConstants.groupName)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => GroupModel.fromFirestore(doc)).toList());
  }

  /// Get groups by IDs
  Future<List<GroupModel>> getGroupsByIds(List<String> groupIds) async {
    if (groupIds.isEmpty) return [];

    // Firestore whereIn is limited to 10 items
    final groups = <GroupModel>[];
    for (var i = 0; i < groupIds.length; i += 10) {
      final chunk = groupIds.skip(i).take(10).toList();
      final snapshot = await _firestoreService.groupsCollection
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      groups.addAll(
        snapshot.docs.map((doc) => GroupModel.fromFirestore(doc)),
      );
    }

    return groups;
  }

  /// Update group
  Future<void> updateGroup(GroupModel group) async {
    await _firestoreService.updateDocument(
      _firestoreService.groupDoc(group.id),
      group.toFirestore(),
    );
  }

  /// Delete group
  Future<void> deleteGroup(String groupId) async {
    // Note: Should also update users who belong to this group
    // This should be handled by the calling code or a Cloud Function
    await _firestoreService.deleteDocument(
      _firestoreService.groupDoc(groupId),
    );
  }

  /// Check if group name exists
  Future<bool> groupNameExists(String name, {String? excludeId}) async {
    final snapshot = await _firestoreService.groupsCollection
        .where(FirebaseConstants.groupName, isEqualTo: name)
        .get();

    if (excludeId != null) {
      return snapshot.docs.any((doc) => doc.id != excludeId);
    }
    return snapshot.docs.isNotEmpty;
  }
}
