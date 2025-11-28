import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_model.dart';

part 'whitelist_model.freezed.dart';
part 'whitelist_model.g.dart';

/// Whitelist entry model for pre-approved emails
@freezed
class WhitelistModel with _$WhitelistModel {
  const WhitelistModel._();

  const factory WhitelistModel({
    required String id,
    required String email,
    required UserRole role,
    required String createdBy,
    required DateTime createdAt,
    @Default(false) bool isRegistered,
    DateTime? registeredAt,
  }) = _WhitelistModel;

  factory WhitelistModel.fromJson(Map<String, dynamic> json) =>
      _$WhitelistModelFromJson(json);

  /// Create from Firestore document
  factory WhitelistModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WhitelistModel.fromJson({
      'id': doc.id,
      ...data,
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      'isRegistered': data['isRegistered'] ?? false,
      'registeredAt': data['registeredAt'] != null
          ? (data['registeredAt'] as Timestamp).toDate().toIso8601String()
          : null,
    });
  }

  /// Convert to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'email': email.toLowerCase().trim(),
      'role': role.name,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRegistered': isRegistered,
      'registeredAt': registeredAt != null ? Timestamp.fromDate(registeredAt!) : null,
    };
  }
}
