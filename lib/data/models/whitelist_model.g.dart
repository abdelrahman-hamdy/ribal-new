// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'whitelist_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WhitelistModelImpl _$$WhitelistModelImplFromJson(Map<String, dynamic> json) =>
    _$WhitelistModelImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRegistered: json['isRegistered'] as bool? ?? false,
      registeredAt: json['registeredAt'] == null
          ? null
          : DateTime.parse(json['registeredAt'] as String),
    );

Map<String, dynamic> _$$WhitelistModelImplToJson(
        _$WhitelistModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'role': _$UserRoleEnumMap[instance.role]!,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'isRegistered': instance.isRegistered,
      'registeredAt': instance.registeredAt?.toIso8601String(),
    };

const _$UserRoleEnumMap = {
  UserRole.admin: 'admin',
  UserRole.manager: 'manager',
  UserRole.employee: 'employee',
};
