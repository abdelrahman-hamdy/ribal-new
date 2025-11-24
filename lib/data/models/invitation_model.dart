import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_model.dart';

part 'invitation_model.freezed.dart';
part 'invitation_model.g.dart';

/// Invitation code model for user registration
@freezed
class InvitationModel with _$InvitationModel {
  const InvitationModel._();

  const factory InvitationModel({
    required String code,
    required UserRole role,
    @Default(false) bool used,
    String? usedBy,
    DateTime? usedAt,
    required String createdBy,
    required DateTime createdAt,
  }) = _InvitationModel;

  factory InvitationModel.fromJson(Map<String, dynamic> json) =>
      _$InvitationModelFromJson(json);

  /// Create from Firestore document
  factory InvitationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InvitationModel.fromJson({
      ...data,
      'code': doc.id,
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      if (data['usedAt'] != null)
        'usedAt': (data['usedAt'] as Timestamp).toDate().toIso8601String(),
    });
  }

  /// Is available for use
  bool get isAvailable => !used;

  /// Convert to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'code': code,
      'role': role.name,
      'used': used,
      'usedBy': usedBy,
      'usedAt': usedAt != null ? Timestamp.fromDate(usedAt!) : null,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
