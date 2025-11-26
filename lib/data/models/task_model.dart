import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

/// Assignee selection type
enum AssigneeSelection {
  @JsonValue('all')
  all,
  @JsonValue('groups')
  groups,
  @JsonValue('custom')
  custom,
}

/// Extension methods for AssigneeSelection
extension AssigneeSelectionX on AssigneeSelection {
  String get name {
    switch (this) {
      case AssigneeSelection.all:
        return 'all';
      case AssigneeSelection.groups:
        return 'groups';
      case AssigneeSelection.custom:
        return 'custom';
    }
  }

  String get displayNameAr {
    switch (this) {
      case AssigneeSelection.all:
        return 'جميع المستخدمين';
      case AssigneeSelection.groups:
        return 'مجموعات محددة';
      case AssigneeSelection.custom:
        return 'مستخدمين محددين';
    }
  }
}

/// Task model
@freezed
class TaskModel with _$TaskModel {
  const TaskModel._();

  const factory TaskModel({
    required String id,
    required String title,
    required String description,
    @Default([]) List<String> labelIds,
    String? attachmentUrl,
    @Default(false) bool isRecurring,
    @Default(true) bool isActive,
    @Default(false) bool isArchived,
    @Default(false) bool attachmentRequired,
    required AssigneeSelection assigneeSelection,
    @Default([]) List<String> selectedGroupIds,
    @Default([]) List<String> selectedUserIds,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  /// Create fake data for skeleton loading
  factory TaskModel.fake() => TaskModel(
        id: 'fake-id',
        title: 'عنوان المهمة يتم تحميله',
        description: 'وصف المهمة يتم تحميله من السيرفر',
        labelIds: const ['fake-label-1', 'fake-label-2'],
        assigneeSelection: AssigneeSelection.all,
        createdBy: 'fake-creator-id',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  /// Create from Firestore document
  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Handle timestamps that might be null or in different formats
    DateTime parseTimestamp(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return TaskModel.fromJson({
      'id': doc.id,
      'title': data['title'] ?? '',
      'description': data['description'] ?? '',
      'labelIds': data['labelIds'] ?? [],
      'attachmentUrl': data['attachmentUrl'],
      'isRecurring': data['isRecurring'] ?? false,
      'isActive': data['isActive'] ?? true,
      'isArchived': data['isArchived'] ?? false,
      'attachmentRequired': data['attachmentRequired'] ?? false,
      'assigneeSelection': data['assigneeSelection'] ?? 'all',
      'selectedGroupIds': data['selectedGroupIds'] ?? [],
      'selectedUserIds': data['selectedUserIds'] ?? [],
      'createdBy': data['createdBy'] ?? '',
      'createdAt': parseTimestamp(data['createdAt']).toIso8601String(),
      'updatedAt': parseTimestamp(data['updatedAt']).toIso8601String(),
    });
  }

  /// Has attachment
  bool get hasAttachment => attachmentUrl != null && attachmentUrl!.isNotEmpty;

  /// Has labels
  bool get hasLabels => labelIds.isNotEmpty;

  /// Is paused (recurring but not active)
  bool get isPaused => isRecurring && !isActive;

  /// Convert to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'labelIds': labelIds,
      'attachmentUrl': attachmentUrl,
      'isRecurring': isRecurring,
      'isActive': isActive,
      'isArchived': isArchived,
      'attachmentRequired': attachmentRequired,
      'assigneeSelection': assigneeSelection.name,
      'selectedGroupIds': selectedGroupIds,
      'selectedUserIds': selectedUserIds,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
