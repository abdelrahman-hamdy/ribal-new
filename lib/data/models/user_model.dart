import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// User roles enum
enum UserRole {
  @JsonValue('admin')
  admin,
  @JsonValue('manager')
  manager,
  @JsonValue('employee')
  employee,
}

/// Extension methods for UserRole
extension UserRoleX on UserRole {
  String get name {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.manager:
        return 'manager';
      case UserRole.employee:
        return 'employee';
    }
  }

  String get displayNameAr {
    switch (this) {
      case UserRole.admin:
        return 'مدير النظام';
      case UserRole.manager:
        return 'مشرف';
      case UserRole.employee:
        return 'موظف';
    }
  }

  bool get isAdmin => this == UserRole.admin;
  bool get isManager => this == UserRole.manager;
  bool get isEmployee => this == UserRole.employee;
}

/// User model
@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    required UserRole role,
    String? avatarUrl,
    String? groupId,
    @Default([]) List<String> managedGroupIds,
    @Default(false) bool canAssignToAll,
    @Default([]) List<String> fcmTokens,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Create fake data for skeleton loading
  factory UserModel.fake() => UserModel(
        id: 'fake-id',
        firstName: 'اسم المستخدم',
        lastName: 'الكامل',
        email: 'fake@example.com',
        role: UserRole.employee,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  /// Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Handle timestamps that might be null or in different formats
    DateTime parseTimestamp(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return UserModel.fromJson({
      'id': doc.id,
      // Handle both camelCase and lowercase field names
      'firstName': data['firstName'] ?? data['firstname'] ?? '',
      'lastName': data['lastName'] ?? data['lastname'] ?? '',
      'email': data['email'] ?? '',
      'role': data['role'] ?? 'employee',
      'avatarUrl': data['avatarUrl'],
      'groupId': data['groupId'],
      'managedGroupIds': data['managedGroupIds'] ?? [],
      'canAssignToAll': data['canAssignToAll'] ?? false,
      'fcmTokens': data['fcmTokens'] ?? [],
      'createdAt': parseTimestamp(data['createdAt']).toIso8601String(),
      'updatedAt': parseTimestamp(data['updatedAt']).toIso8601String(),
    });
  }

  /// Full name
  String get fullName => '$firstName $lastName';

  /// Initials for avatar
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  /// Convert to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role.name,
      'avatarUrl': avatarUrl,
      'groupId': groupId,
      'managedGroupIds': managedGroupIds,
      'canAssignToAll': canAssignToAll,
      'fcmTokens': fcmTokens,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Check if user can assign to a specific group
  bool canAssignToGroup(String groupId) {
    if (role == UserRole.admin) return true;
    if (canAssignToAll) return true;
    return managedGroupIds.contains(groupId);
  }
}
