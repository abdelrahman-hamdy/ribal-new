import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'assignment_model.freezed.dart';
part 'assignment_model.g.dart';

/// Assignment status enum
enum AssignmentStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('completed')
  completed,
  @JsonValue('apologized')
  apologized,
  @JsonValue('overdue')
  overdue,
}

/// Extension methods for AssignmentStatus
extension AssignmentStatusX on AssignmentStatus {
  String get name {
    switch (this) {
      case AssignmentStatus.pending:
        return 'pending';
      case AssignmentStatus.completed:
        return 'completed';
      case AssignmentStatus.apologized:
        return 'apologized';
      case AssignmentStatus.overdue:
        return 'overdue';
    }
  }

  String get displayNameAr {
    switch (this) {
      case AssignmentStatus.pending:
        return 'قيد الانتظار';
      case AssignmentStatus.completed:
        return 'مكتملة';
      case AssignmentStatus.apologized:
        return 'معتذر';
      case AssignmentStatus.overdue:
        return 'متأخر';
    }
  }

  bool get isPending => this == AssignmentStatus.pending;
  bool get isCompleted => this == AssignmentStatus.completed;
  bool get isApologized => this == AssignmentStatus.apologized;
  bool get isOverdue => this == AssignmentStatus.overdue;

  /// Whether this is a "failed" status (apologized or overdue)
  bool get isFailed => isApologized || isOverdue;
}

/// Assignment model
@freezed
class AssignmentModel with _$AssignmentModel {
  const AssignmentModel._();

  const factory AssignmentModel({
    required String id,
    required String taskId,
    required String userId,
    required AssignmentStatus status,
    String? apologizeMessage,
    DateTime? completedAt,
    DateTime? apologizedAt,
    DateTime? overdueAt,
    String? markedDoneBy,
    String? attachmentUrl,
    // Denormalized fields for performance (avoid extra fetches)
    String? taskTitle,
    String? userName,
    required DateTime scheduledDate,
    required DateTime createdAt,
  }) = _AssignmentModel;

  factory AssignmentModel.fromJson(Map<String, dynamic> json) =>
      _$AssignmentModelFromJson(json);

  /// Create fake data for skeleton loading
  factory AssignmentModel.fake() => AssignmentModel(
        id: 'fake-id',
        taskId: 'fake-task-id',
        userId: 'fake-user-id',
        status: AssignmentStatus.pending,
        scheduledDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

  /// Create from Firestore document
  factory AssignmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AssignmentModel.fromJson({
      'id': doc.id,
      ...data,
      // Denormalized fields (may be null for old documents)
      'taskTitle': data['taskTitle'],
      'userName': data['userName'],
      'scheduledDate':
          (data['scheduledDate'] as Timestamp).toDate().toIso8601String(),
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      if (data['completedAt'] != null)
        'completedAt':
            (data['completedAt'] as Timestamp).toDate().toIso8601String(),
      if (data['apologizedAt'] != null)
        'apologizedAt':
            (data['apologizedAt'] as Timestamp).toDate().toIso8601String(),
      if (data['overdueAt'] != null)
        'overdueAt':
            (data['overdueAt'] as Timestamp).toDate().toIso8601String(),
    });
  }

  /// Is completed by self
  bool get isCompletedBySelf => markedDoneBy == userId;

  /// Is completed by creator
  bool get isCompletedByCreator => markedDoneBy != null && markedDoneBy != userId;

  /// Can be reactivated (only if apologized - overdue is locked)
  bool get canReactivate => status.isApologized && !status.isOverdue;

  /// Has apologize message
  bool get hasApologizeMessage =>
      apologizeMessage != null && apologizeMessage!.isNotEmpty;

  /// Has attachment
  bool get hasAttachment => attachmentUrl != null && attachmentUrl!.isNotEmpty;

  /// Convert to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'taskId': taskId,
      'userId': userId,
      'status': status.name,
      'apologizeMessage': apologizeMessage,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'apologizedAt':
          apologizedAt != null ? Timestamp.fromDate(apologizedAt!) : null,
      'overdueAt': overdueAt != null ? Timestamp.fromDate(overdueAt!) : null,
      'markedDoneBy': markedDoneBy,
      'attachmentUrl': attachmentUrl,
      // Denormalized fields
      'taskTitle': taskTitle,
      'userName': userName,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

/// Assignment with task details (for display)
@freezed
class AssignmentWithTask with _$AssignmentWithTask {
  const factory AssignmentWithTask({
    required AssignmentModel assignment,
    required String taskTitle,
    required String taskDescription,
    required List<String> taskLabelIds,
    String? taskAttachmentUrl,
    @Default(false) bool taskAttachmentRequired,
    required String taskCreatorId,
    required String taskCreatorName,
  }) = _AssignmentWithTask;
}
