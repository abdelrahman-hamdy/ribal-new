import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_model.freezed.dart';
part 'group_model.g.dart';

/// Group model for organizing employees
@freezed
class GroupModel with _$GroupModel {
  const GroupModel._();

  const factory GroupModel({
    required String id,
    required String name,
    required String createdBy,
    required DateTime createdAt,
  }) = _GroupModel;

  factory GroupModel.fromJson(Map<String, dynamic> json) =>
      _$GroupModelFromJson(json);

  /// Create from Firestore document
  factory GroupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Handle timestamps that might be null or in different formats
    DateTime parseTimestamp(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return GroupModel.fromJson({
      'id': doc.id,
      'name': data['name'] ?? '',
      'createdBy': data['createdBy'] ?? '',
      'createdAt': parseTimestamp(data['createdAt']).toIso8601String(),
    });
  }

  /// Convert to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

/// Group with member count (for display)
@freezed
class GroupWithCount with _$GroupWithCount {
  const factory GroupWithCount({
    required GroupModel group,
    required int memberCount,
  }) = _GroupWithCount;
}
