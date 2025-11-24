// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InvitationModelImpl _$$InvitationModelImplFromJson(
        Map<String, dynamic> json) =>
    _$InvitationModelImpl(
      code: json['code'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      used: json['used'] as bool? ?? false,
      usedBy: json['usedBy'] as String?,
      usedAt: json['usedAt'] == null
          ? null
          : DateTime.parse(json['usedAt'] as String),
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$InvitationModelImplToJson(
        _$InvitationModelImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'role': _$UserRoleEnumMap[instance.role]!,
      'used': instance.used,
      'usedBy': instance.usedBy,
      'usedAt': instance.usedAt?.toIso8601String(),
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$UserRoleEnumMap = {
  UserRole.admin: 'admin',
  UserRole.manager: 'manager',
  UserRole.employee: 'employee',
};
