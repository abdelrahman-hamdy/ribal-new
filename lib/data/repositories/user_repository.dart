import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/firebase_constants.dart';
import '../../core/services/hive_cache_service.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

/// User repository for CRUD operations with V2 caching
/// Strategy: Firebase cache + Hive TTL metadata
@lazySingleton
class UserRepository {
  final FirestoreService _firestoreService;
  final HiveCacheService _cacheService;

  UserRepository(this._firestoreService, this._cacheService);

  /// Get user by ID (V2: Firebase cache + Hive TTL)
  Future<UserModel?> getUserById(String userId) async {
    final cacheKey = 'user_${userId}_timestamp';

    // Check if Firebase cache is fresh
    final isFresh = await _cacheService.isCacheFresh(
      boxName: HiveCacheService.boxUsers,
      key: cacheKey,
      ttl: HiveCacheService.ttlMedium,
    );

    if (isFresh) {
      // Use Firebase CACHE (instant)
      try {
        final doc = await _firestoreService.userDoc(userId)
            .get(const GetOptions(source: Source.cache));

        if (!doc.exists) return null;
        return UserModel.fromFirestore(doc);
      } catch (e) {
        debugPrint('[UserRepository] Firebase cache read failed for user $userId: $e');
      }
    }

    // Fetch from server
    final doc = await _firestoreService.userDoc(userId)
        .get(const GetOptions(source: Source.server));

    if (!doc.exists) return null;

    final user = UserModel.fromFirestore(doc);

    // Mark cache as fresh
    await _cacheService.put(
      boxName: HiveCacheService.boxUsers,
      key: cacheKey,
      value: {'cached': true},
    );

    return user;
  }

  /// Batch get users by IDs (optimized for multiple users) with V2 caching
  /// Uses individual cache checks for maximum cache hit rate
  Future<Map<String, UserModel>> getUsersByIds(List<String> userIds) async {
    if (userIds.isEmpty) return {};

    final overallStart = DateTime.now();
    debugPrint('[UserRepository] 👥 getUsersByIds() V2 started - ${userIds.length} users');

    final users = <String, UserModel>{};
    final cachedUserIds = <String>[];
    final staleUserIds = <String>[];

    // Check which users have fresh individual cache timestamps
    for (final userId in userIds) {
      final cacheKey = 'user_${userId}_timestamp';
      final isFresh = await _cacheService.isCacheFresh(
        boxName: HiveCacheService.boxUsers,
        key: cacheKey,
        ttl: HiveCacheService.ttlMedium,
      );

      if (isFresh) {
        cachedUserIds.add(userId);
      } else {
        staleUserIds.add(userId);
      }
    }

    debugPrint('[UserRepository] Cache status: ${cachedUserIds.length} fresh, ${staleUserIds.length} stale');

    // Read cached users from Firebase cache (instant!)
    if (cachedUserIds.isNotEmpty) {
      final cacheReadStart = DateTime.now();
      debugPrint('[UserRepository] 📖 Reading ${cachedUserIds.length} users from Firebase CACHE');

      try {
        for (var i = 0; i < cachedUserIds.length; i += 10) {
          final batch = cachedUserIds.skip(i).take(10).toList();
          final snapshot = await _firestoreService.usersCollection
              .where(FieldPath.documentId, whereIn: batch)
              .get(const GetOptions(source: Source.cache)); // 🔥 CACHE-ONLY

          for (final doc in snapshot.docs) {
            users[doc.id] = UserModel.fromFirestore(doc);
          }
        }

        final duration = DateTime.now().difference(cacheReadStart);
        debugPrint('[UserRepository] ✅ Loaded ${users.length} users from Firebase CACHE in ${duration.inMilliseconds}ms');
      } catch (e) {
        debugPrint('[UserRepository] ⚠️ Firebase cache read failed: $e');
        // Add failed IDs back to stale list
        staleUserIds.addAll(cachedUserIds);
      }
    }

    // Fetch stale users from server
    if (staleUserIds.isNotEmpty) {
      final serverFetchStart = DateTime.now();
      debugPrint('[UserRepository] 🌐 Fetching ${staleUserIds.length} users from Firebase SERVER');

      for (var i = 0; i < staleUserIds.length; i += 10) {
        final batch = staleUserIds.skip(i).take(10).toList();
        final snapshot = await _firestoreService.usersCollection
            .where(FieldPath.documentId, whereIn: batch)
            .get(const GetOptions(source: Source.server)); // 🌐 SERVER FETCH

        for (final doc in snapshot.docs) {
          users[doc.id] = UserModel.fromFirestore(doc);

          // Mark individual user as fresh
          await _cacheService.put(
            boxName: HiveCacheService.boxUsers,
            key: 'user_${doc.id}_timestamp',
            value: {'cached': true},
          );
        }
      }

      final duration = DateTime.now().difference(serverFetchStart);
      debugPrint('[UserRepository] ✅ Fetched ${staleUserIds.length} users from SERVER in ${duration.inMilliseconds}ms');
    }

    final totalDuration = DateTime.now().difference(overallStart);
    debugPrint('[UserRepository] 🎯 Total: Loaded ${users.length} users in ${totalDuration.inMilliseconds}ms (${cachedUserIds.length} cached, ${staleUserIds.length} fetched)');

    return users;
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
    await _invalidateUserCaches();
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
    await _invalidateUserCaches();
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
    await _invalidateUserCaches();
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
    await _invalidateUserCaches();
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
    await _invalidateUserCaches();
  }

  /// Count users by group
  Future<int> countUsersByGroup(String groupId) async {
    final snapshot = await _firestoreService.usersCollection
        .where(FirebaseConstants.userGroupId, isEqualTo: groupId)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  // ===========================================
  // CACHE INVALIDATION
  // ===========================================

  /// Invalidate user caches (only timestamps, data stays in Firebase cache)
  Future<void> _invalidateUserCaches() async {
    debugPrint('[UserRepository] 🗑️  Invalidating user caches...');

    // Clear all user batch cache keys
    // Since we can't enumerate all possible batch combinations,
    // we clear the entire users box (only timestamps, data stays in Firebase)
    await _cacheService.clearBox(HiveCacheService.boxUsers);

    debugPrint('[UserRepository] ✅ User caches invalidated');
  }
}
