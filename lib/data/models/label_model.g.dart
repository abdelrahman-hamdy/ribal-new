// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'label_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LabelModelImpl _$$LabelModelImplFromJson(Map<String, dynamic> json) =>
    _$LabelModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      isActive: json['isActive'] as bool? ?? true,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$LabelModelImplToJson(_$LabelModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'color': instance.color,
      'isActive': instance.isActive,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
    };
