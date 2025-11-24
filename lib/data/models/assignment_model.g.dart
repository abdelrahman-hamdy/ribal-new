// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AssignmentModelImpl _$$AssignmentModelImplFromJson(
        Map<String, dynamic> json) =>
    _$AssignmentModelImpl(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      userId: json['userId'] as String,
      status: $enumDecode(_$AssignmentStatusEnumMap, json['status']),
      apologizeMessage: json['apologizeMessage'] as String?,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      apologizedAt: json['apologizedAt'] == null
          ? null
          : DateTime.parse(json['apologizedAt'] as String),
      markedDoneBy: json['markedDoneBy'] as String?,
      attachmentUrl: json['attachmentUrl'] as String?,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$AssignmentModelImplToJson(
        _$AssignmentModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'taskId': instance.taskId,
      'userId': instance.userId,
      'status': _$AssignmentStatusEnumMap[instance.status]!,
      'apologizeMessage': instance.apologizeMessage,
      'completedAt': instance.completedAt?.toIso8601String(),
      'apologizedAt': instance.apologizedAt?.toIso8601String(),
      'markedDoneBy': instance.markedDoneBy,
      'attachmentUrl': instance.attachmentUrl,
      'scheduledDate': instance.scheduledDate.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$AssignmentStatusEnumMap = {
  AssignmentStatus.pending: 'pending',
  AssignmentStatus.completed: 'completed',
  AssignmentStatus.apologized: 'apologized',
};
