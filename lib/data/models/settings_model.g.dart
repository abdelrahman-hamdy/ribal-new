// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SettingsModelImpl _$$SettingsModelImplFromJson(Map<String, dynamic> json) =>
    _$SettingsModelImpl(
      recurringTaskTime: json['recurringTaskTime'] as String? ??
          AppConstants.defaultRecurringTime,
      taskDeadline:
          json['taskDeadline'] as String? ?? AppConstants.defaultDeadlineTime,
    );

Map<String, dynamic> _$$SettingsModelImplToJson(_$SettingsModelImpl instance) =>
    <String, dynamic>{
      'recurringTaskTime': instance.recurringTaskTime,
      'taskDeadline': instance.taskDeadline,
    };
