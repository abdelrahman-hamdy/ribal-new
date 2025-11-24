// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'label_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LabelModel _$LabelModelFromJson(Map<String, dynamic> json) {
  return _LabelModel.fromJson(json);
}

/// @nodoc
mixin _$LabelModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get color => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this LabelModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LabelModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LabelModelCopyWith<LabelModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabelModelCopyWith<$Res> {
  factory $LabelModelCopyWith(
          LabelModel value, $Res Function(LabelModel) then) =
      _$LabelModelCopyWithImpl<$Res, LabelModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      String color,
      bool isActive,
      String createdBy,
      DateTime createdAt});
}

/// @nodoc
class _$LabelModelCopyWithImpl<$Res, $Val extends LabelModel>
    implements $LabelModelCopyWith<$Res> {
  _$LabelModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LabelModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? color = null,
    Object? isActive = null,
    Object? createdBy = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LabelModelImplCopyWith<$Res>
    implements $LabelModelCopyWith<$Res> {
  factory _$$LabelModelImplCopyWith(
          _$LabelModelImpl value, $Res Function(_$LabelModelImpl) then) =
      __$$LabelModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String color,
      bool isActive,
      String createdBy,
      DateTime createdAt});
}

/// @nodoc
class __$$LabelModelImplCopyWithImpl<$Res>
    extends _$LabelModelCopyWithImpl<$Res, _$LabelModelImpl>
    implements _$$LabelModelImplCopyWith<$Res> {
  __$$LabelModelImplCopyWithImpl(
      _$LabelModelImpl _value, $Res Function(_$LabelModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of LabelModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? color = null,
    Object? isActive = null,
    Object? createdBy = null,
    Object? createdAt = null,
  }) {
    return _then(_$LabelModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LabelModelImpl extends _LabelModel {
  const _$LabelModelImpl(
      {required this.id,
      required this.name,
      required this.color,
      this.isActive = true,
      required this.createdBy,
      required this.createdAt})
      : super._();

  factory _$LabelModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LabelModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String color;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final String createdBy;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'LabelModel(id: $id, name: $name, color: $color, isActive: $isActive, createdBy: $createdBy, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LabelModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, color, isActive, createdBy, createdAt);

  /// Create a copy of LabelModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LabelModelImplCopyWith<_$LabelModelImpl> get copyWith =>
      __$$LabelModelImplCopyWithImpl<_$LabelModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LabelModelImplToJson(
      this,
    );
  }
}

abstract class _LabelModel extends LabelModel {
  const factory _LabelModel(
      {required final String id,
      required final String name,
      required final String color,
      final bool isActive,
      required final String createdBy,
      required final DateTime createdAt}) = _$LabelModelImpl;
  const _LabelModel._() : super._();

  factory _LabelModel.fromJson(Map<String, dynamic> json) =
      _$LabelModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get color;
  @override
  bool get isActive;
  @override
  String get createdBy;
  @override
  DateTime get createdAt;

  /// Create a copy of LabelModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LabelModelImplCopyWith<_$LabelModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
