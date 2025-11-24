// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'whitelist_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WhitelistModel _$WhitelistModelFromJson(Map<String, dynamic> json) {
  return _WhitelistModel.fromJson(json);
}

/// @nodoc
mixin _$WhitelistModel {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  UserRole get role => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this WhitelistModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WhitelistModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WhitelistModelCopyWith<WhitelistModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WhitelistModelCopyWith<$Res> {
  factory $WhitelistModelCopyWith(
          WhitelistModel value, $Res Function(WhitelistModel) then) =
      _$WhitelistModelCopyWithImpl<$Res, WhitelistModel>;
  @useResult
  $Res call(
      {String id,
      String email,
      UserRole role,
      String createdBy,
      DateTime createdAt});
}

/// @nodoc
class _$WhitelistModelCopyWithImpl<$Res, $Val extends WhitelistModel>
    implements $WhitelistModelCopyWith<$Res> {
  _$WhitelistModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WhitelistModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? role = null,
    Object? createdBy = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
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
abstract class _$$WhitelistModelImplCopyWith<$Res>
    implements $WhitelistModelCopyWith<$Res> {
  factory _$$WhitelistModelImplCopyWith(_$WhitelistModelImpl value,
          $Res Function(_$WhitelistModelImpl) then) =
      __$$WhitelistModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String email,
      UserRole role,
      String createdBy,
      DateTime createdAt});
}

/// @nodoc
class __$$WhitelistModelImplCopyWithImpl<$Res>
    extends _$WhitelistModelCopyWithImpl<$Res, _$WhitelistModelImpl>
    implements _$$WhitelistModelImplCopyWith<$Res> {
  __$$WhitelistModelImplCopyWithImpl(
      _$WhitelistModelImpl _value, $Res Function(_$WhitelistModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of WhitelistModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? role = null,
    Object? createdBy = null,
    Object? createdAt = null,
  }) {
    return _then(_$WhitelistModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
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
class _$WhitelistModelImpl extends _WhitelistModel {
  const _$WhitelistModelImpl(
      {required this.id,
      required this.email,
      required this.role,
      required this.createdBy,
      required this.createdAt})
      : super._();

  factory _$WhitelistModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$WhitelistModelImplFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  final UserRole role;
  @override
  final String createdBy;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'WhitelistModel(id: $id, email: $email, role: $role, createdBy: $createdBy, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WhitelistModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, email, role, createdBy, createdAt);

  /// Create a copy of WhitelistModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WhitelistModelImplCopyWith<_$WhitelistModelImpl> get copyWith =>
      __$$WhitelistModelImplCopyWithImpl<_$WhitelistModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WhitelistModelImplToJson(
      this,
    );
  }
}

abstract class _WhitelistModel extends WhitelistModel {
  const factory _WhitelistModel(
      {required final String id,
      required final String email,
      required final UserRole role,
      required final String createdBy,
      required final DateTime createdAt}) = _$WhitelistModelImpl;
  const _WhitelistModel._() : super._();

  factory _WhitelistModel.fromJson(Map<String, dynamic> json) =
      _$WhitelistModelImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override
  UserRole get role;
  @override
  String get createdBy;
  @override
  DateTime get createdAt;

  /// Create a copy of WhitelistModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WhitelistModelImplCopyWith<_$WhitelistModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
