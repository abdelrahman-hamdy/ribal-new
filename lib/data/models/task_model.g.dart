// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskModelImpl _$$TaskModelImplFromJson(Map<String, dynamic> json) =>
    _$TaskModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      labelIds: (json['labelIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      attachmentUrl: json['attachmentUrl'] as String?,
      isRecurring: json['isRecurring'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      isArchived: json['isArchived'] as bool? ?? false,
      attachmentRequired: json['attachmentRequired'] as bool? ?? false,
      assigneeSelection:
          $enumDecode(_$AssigneeSelectionEnumMap, json['assigneeSelection']),
      selectedGroupIds: (json['selectedGroupIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      selectedUserIds: (json['selectedUserIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdBy: json['createdBy'] as String,
      creatorName: json['creatorName'] as String?,
      creatorEmail: json['creatorEmail'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$TaskModelImplToJson(_$TaskModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'labelIds': instance.labelIds,
      'attachmentUrl': instance.attachmentUrl,
      'isRecurring': instance.isRecurring,
      'isActive': instance.isActive,
      'isArchived': instance.isArchived,
      'attachmentRequired': instance.attachmentRequired,
      'assigneeSelection':
          _$AssigneeSelectionEnumMap[instance.assigneeSelection]!,
      'selectedGroupIds': instance.selectedGroupIds,
      'selectedUserIds': instance.selectedUserIds,
      'createdBy': instance.createdBy,
      'creatorName': instance.creatorName,
      'creatorEmail': instance.creatorEmail,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$AssigneeSelectionEnumMap = {
  AssigneeSelection.all: 'all',
  AssigneeSelection.groups: 'groups',
  AssigneeSelection.custom: 'custom',
};
