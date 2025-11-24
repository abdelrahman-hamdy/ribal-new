import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/firebase_constants.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

/// User repository for CRUD operations
@lazySingleton
class UserRepository {
  final FirestoreService _firestoreService;

  UserRepository(this._firestoreService);

  /// Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    final doc = await _firestoreService.userDoc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Stream user by ID
  Stream<UserModel?> streamUser(String userId) {
    return _firestoreService
        .streamDocument(_firestoreService.userDoc(userId))
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  /// Get all users
  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _firestoreService.usersCollection
        .orderBy(FirebaseConstants.userCreatedAt, descending: true)
        .get();

    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  /// Stream all users
  Stream<List<UserModel>> streamAllUsers() {
    return _firestoreService.usersCollection
        .orderBy(FirebaseConstants.userCreatedAt, descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  /// Get users by role
  Future<List<UserModel>> getUsersByRole(UserRole role) async {
    final snapshot = await _firestoreService.usersCollection
        .where(FirebaseConstants.userRole, isEqualTo: role.name)
        .orderBy(FirebaseConstants.userCreatedAt, descending: true)
        .get();

    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  /// Get users by group
  Future<List<UserModel>> getUsersByGroup(String groupId) async {
    final snapshot = await _firestoreService.usersCollection
        .where(FirebaseConstants.userGroupId, isEqualTo: groupId)
        .get();

    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  /// Stream users by group
  Stream<List<UserModel>> streamUsersByGroup(String groupId) {
    return _firestoreService.usersCollection
        .where(FirebaseConstants.userGroupId, isEqualTo: groupId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  /// Get employees (managers can assign tasks to)
  Future<List<UserModel>> getAssignableUsers({
    required UserModel currentUser,
  }) async {
    if (currentUser.role == UserRole.admin) {
      // Admin can assign to all managers and employees
      final snapshot = await _firestoreService.usersCollection
          .where(FirebaseConstants.userRole, whereIn: ['manager', 'employee'])
          .get();
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    }

    if (currentUser.role == UserRole.manager) {
      if (currentUser.canAssignToAll) {
        // Manager can assign to all employees
        final snapshot = await _firestoreService.usersCollection
            .where(FirebaseConstants.userRole, isEqualTo: 'employee')
            .get();
        return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
      } else {
        // Manager can only assign to specific groups
        final users = <UserModel>[];
        for (final groupId in currentUser.managedGroupIds) {
          final groupUsers = await getUsersByGroup(groupId);
          for (final user in groupUsers) {
            if (user.role == UserRole.employee &&
                !users.any((u) => u.id == user.id)) {
              users.add(user);
            }
          }
        }
        return users;
      }
    }

    return [];
  }

  /// Update user
  Future<void> updateUser(UserModel user) async {
    await _firestoreService.updateDocument(
      _firestoreService.userDoc(user.id),
      {
        ...user.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );
  }

  /// Update user role (simple update without handling scenarios)
  Future<void> updateUserRole(String userId, UserRole newRole) async {
    final updates = <String, dynamic>{
      FirebaseConstants.userRole: newRole.name,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // If changing from manager to employee, clear managed groups
    if (newRole == UserRole.employee) {
      updates[FirebaseConstants.userManagedGroupIds] = [];
      updates[FirebaseConstants.userCanAssignToAll] = false;
    }

    await _firestoreService.updateDocument(
      _firestoreService.userDoc(userId),
      updates,
    );
  }

  /// Convert user role with proper handling of all scenarios
  ///
  /// Scenarios handled:
  /// 1. Employee → Manager:
  ///    - Clear employee's groupId (managers don't belong to groups)
  ///    - Keep existing assignments (they can still track their history)
  ///
  /// 2. Manager → Employee:
  ///    - Clear managedGroupIds and canAssignToAll
  ///    - Tasks created by this manager remain active (other admins/managers can manage them)
  ///    - The user will receive assignments like any other employee
  Future<void> convertUserRole({
    required String userId,
    required UserRole newRole,
  }) async {
    final user = await getUserById(userId);
    if (user == null) {
      throw Exception('User not found');
    }

    final oldRole = user.role;

    // Don't allow conversion to/from admin
    if (oldRole == UserRole.admin || newRole == UserRole.admin) {
      throw Exception('Cannot convert admin role');
    }

    final updates = <String, dynamic>{
      FirebaseConstants.userRole: newRole.name,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (oldRole == UserRole.employee && newRole == UserRole.manager) {
      // Employee → Manager conversion
      // Clear groupId (managers don't belong to groups, they manage them)
      updates[FirebaseConstants.userGroupId] = null;
      // Initialize empty managed groups (admin will assign groups later)
      updates[FirebaseConstants.userManagedGroupIds] = [];
      updates[FirebaseConstants.userCanAssignToAll] = false;
    } else if (oldRole == UserRole.manager && newRole == UserRole.employee) {
      // Manager → Employee conversion
      // Clear manager-specific fields
      updates[FirebaseConstants.userManagedGroupIds] = [];
      updates[FirebaseConstants.userCanAssignToAll] = false;
      // Note: groupId remains null, admin can assign to a group later
      // Tasks created by this manager remain active - they're not deleted
      // Other admins/managers can still manage those tasks
    }

    await _firestoreService.updateDocument(
      _firestoreService.userDoc(userId),
      updates,
    );
  }

  /// Update user group
  Future<void> updateUserGroup(String userId, String? groupId) async {
    await _firestoreService.updateDocument(
      _firestoreService.userDoc(userId),
      {
        FirebaseConstants.userGroupId: groupId,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );
  }

  /// Update manager permissions
  Future<void> updateManagerPermissions({
    required String userId,
    required bool canAssignToAll,
    required List<String> managedGroupIds,
  }) async {
    await _firestoreService.updateDocument(
      _firestoreService.userDoc(userId),
      {
        FirebaseConstants.userCanAssignToAll: canAssignToAll,
        FirebaseConstants.userManagedGroupIds: managedGroupIds,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );
  }

  /// Count users by group
  Future<int> countUsersByGroup(String groupId) async {
    final snapshot = await _firestoreService.usersCollection
        .where(FirebaseConstants.userGroupId, isEqualTo: groupId)
        .count()
        .get();
    return snapshot.count ?? 0;
  }
}
