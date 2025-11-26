// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NoteModelImpl _$$NoteModelImplFromJson(Map<String, dynamic> json) =>
    _$NoteModelImpl(
      id: json['id'] as String,
      assignmentId: json['assignmentId'] as String,
      taskId: json['taskId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      senderRole: $enumDecode(_$UserRoleEnumMap, json['senderRole']),
      message: json['message'] as String,
      isApologizeNote: json['isApologizeNote'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$NoteModelImplToJson(_$NoteModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'assignmentId': instance.assignmentId,
      'taskId': instance.taskId,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'senderRole': _$UserRoleEnumMap[instance.senderRole]!,
      'message': instance.message,
      'isApologizeNote': instance.isApologizeNote,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$UserRoleEnumMap = {
  UserRole.admin: 'admin',
  UserRole.manager: 'manager',
  UserRole.employee: 'employee',
};
