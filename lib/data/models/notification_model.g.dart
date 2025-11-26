// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationModelImpl _$$NotificationModelImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      title: json['title'] as String,
      body: json['body'] as String,
      iconName: json['iconName'] as String,
      iconColor: json['iconColor'] as String,
      deepLink: json['deepLink'] as String?,
      isSeen: json['isSeen'] as bool? ?? false,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$NotificationModelImplToJson(
        _$NotificationModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'title': instance.title,
      'body': instance.body,
      'iconName': instance.iconName,
      'iconColor': instance.iconColor,
      'deepLink': instance.deepLink,
      'isSeen': instance.isSeen,
      'isRead': instance.isRead,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$NotificationTypeEnumMap = {
  NotificationType.taskAssigned: 'taskAssigned',
  NotificationType.taskCompleted: 'taskCompleted',
  NotificationType.taskApologized: 'taskApologized',
  NotificationType.taskReactivated: 'taskReactivated',
  NotificationType.taskMarkedDone: 'taskMarkedDone',
  NotificationType.taskOverdue: 'taskOverdue',
  NotificationType.deadlineWarning: 'deadlineWarning',
  NotificationType.recurringScheduled: 'recurringScheduled',
  NotificationType.invitationAccepted: 'invitationAccepted',
  NotificationType.roleChanged: 'roleChanged',
  NotificationType.noteReceived: 'noteReceived',
};
