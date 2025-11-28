// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) {
  return _TaskModel.fromJson(json);
}

/// @nodoc
mixin _$TaskModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<String> get labelIds => throw _privateConstructorUsedError;
  String? get attachmentUrl => throw _privateConstructorUsedError;
  bool get isRecurring => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  bool get isArchived => throw _privateConstructorUsedError;
  bool get attachmentRequired => throw _privateConstructorUsedError;
  AssigneeSelection get assigneeSelection => throw _privateConstructorUsedError;
  List<String> get selectedGroupIds => throw _privateConstructorUsedError;
  List<String> get selectedUserIds => throw _privateConstructorUsedError;
  String get createdBy =>
      throw _privateConstructorUsedError; // Denormalized fields for performance (avoid extra user fetch)
  String? get creatorName => throw _privateConstructorUsedError;
  String? get creatorEmail => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this TaskModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskModelCopyWith<TaskModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskModelCopyWith<$Res> {
  factory $TaskModelCopyWith(TaskModel value, $Res Function(TaskModel) then) =
      _$TaskModelCopyWithImpl<$Res, TaskModel>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      List<String> labelIds,
      String? attachmentUrl,
      bool isRecurring,
      bool isActive,
      bool isArchived,
      bool attachmentRequired,
      AssigneeSelection assigneeSelection,
      List<String> selectedGroupIds,
      List<String> selectedUserIds,
      String createdBy,
      String? creatorName,
      String? creatorEmail,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$TaskModelCopyWithImpl<$Res, $Val extends TaskModel>
    implements $TaskModelCopyWith<$Res> {
  _$TaskModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? labelIds = null,
    Object? attachmentUrl = freezed,
    Object? isRecurring = null,
    Object? isActive = null,
    Object? isArchived = null,
    Object? attachmentRequired = null,
    Object? assigneeSelection = null,
    Object? selectedGroupIds = null,
    Object? selectedUserIds = null,
    Object? createdBy = null,
    Object? creatorName = freezed,
    Object? creatorEmail = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      labelIds: null == labelIds
          ? _value.labelIds
          : labelIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      attachmentUrl: freezed == attachmentUrl
          ? _value.attachmentUrl
          : attachmentUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isRecurring: null == isRecurring
          ? _value.isRecurring
          : isRecurring // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isArchived: null == isArchived
          ? _value.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      attachmentRequired: null == attachmentRequired
          ? _value.attachmentRequired
          : attachmentRequired // ignore: cast_nullable_to_non_nullable
              as bool,
      assigneeSelection: null == assigneeSelection
          ? _value.assigneeSelection
          : assigneeSelection // ignore: cast_nullable_to_non_nullable
              as AssigneeSelection,
      selectedGroupIds: null == selectedGroupIds
          ? _value.selectedGroupIds
          : selectedGroupIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      selectedUserIds: null == selectedUserIds
          ? _value.selectedUserIds
          : selectedUserIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      creatorName: freezed == creatorName
          ? _value.creatorName
          : creatorName // ignore: cast_nullable_to_non_nullable
              as String?,
      creatorEmail: freezed == creatorEmail
          ? _value.creatorEmail
          : creatorEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TaskModelImplCopyWith<$Res>
    implements $TaskModelCopyWith<$Res> {
  factory _$$TaskModelImplCopyWith(
          _$TaskModelImpl value, $Res Function(_$TaskModelImpl) then) =
      __$$TaskModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      List<String> labelIds,
      String? attachmentUrl,
      bool isRecurring,
      bool isActive,
      bool isArchived,
      bool attachmentRequired,
      AssigneeSelection assigneeSelection,
      List<String> selectedGroupIds,
      List<String> selectedUserIds,
      String createdBy,
      String? creatorName,
      String? creatorEmail,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$TaskModelImplCopyWithImpl<$Res>
    extends _$TaskModelCopyWithImpl<$Res, _$TaskModelImpl>
    implements _$$TaskModelImplCopyWith<$Res> {
  __$$TaskModelImplCopyWithImpl(
      _$TaskModelImpl _value, $Res Function(_$TaskModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? labelIds = null,
    Object? attachmentUrl = freezed,
    Object? isRecurring = null,
    Object? isActive = null,
    Object? isArchived = null,
    Object? attachmentRequired = null,
    Object? assigneeSelection = null,
    Object? selectedGroupIds = null,
    Object? selectedUserIds = null,
    Object? createdBy = null,
    Object? creatorName = freezed,
    Object? creatorEmail = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$TaskModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      labelIds: null == labelIds
          ? _value._labelIds
          : labelIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      attachmentUrl: freezed == attachmentUrl
          ? _value.attachmentUrl
          : attachmentUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isRecurring: null == isRecurring
          ? _value.isRecurring
          : isRecurring // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isArchived: null == isArchived
          ? _value.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      attachmentRequired: null == attachmentRequired
          ? _value.attachmentRequired
          : attachmentRequired // ignore: cast_nullable_to_non_nullable
              as bool,
      assigneeSelection: null == assigneeSelection
          ? _value.assigneeSelection
          : assigneeSelection // ignore: cast_nullable_to_non_nullable
              as AssigneeSelection,
      selectedGroupIds: null == selectedGroupIds
          ? _value._selectedGroupIds
          : selectedGroupIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      selectedUserIds: null == selectedUserIds
          ? _value._selectedUserIds
          : selectedUserIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      creatorName: freezed == creatorName
          ? _value.creatorName
          : creatorName // ignore: cast_nullable_to_non_nullable
              as String?,
      creatorEmail: freezed == creatorEmail
          ? _value.creatorEmail
          : creatorEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TaskModelImpl extends _TaskModel {
  const _$TaskModelImpl(
      {required this.id,
      required this.title,
      required this.description,
      final List<String> labelIds = const [],
      this.attachmentUrl,
      this.isRecurring = false,
      this.isActive = true,
      this.isArchived = false,
      this.attachmentRequired = false,
      required this.assigneeSelection,
      final List<String> selectedGroupIds = const [],
      final List<String> selectedUserIds = const [],
      required this.createdBy,
      this.creatorName,
      this.creatorEmail,
      required this.createdAt,
      required this.updatedAt})
      : _labelIds = labelIds,
        _selectedGroupIds = selectedGroupIds,
        _selectedUserIds = selectedUserIds,
        super._();

  factory _$TaskModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  final List<String> _labelIds;
  @override
  @JsonKey()
  List<String> get labelIds {
    if (_labelIds is EqualUnmodifiableListView) return _labelIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_labelIds);
  }

  @override
  final String? attachmentUrl;
  @override
  @JsonKey()
  final bool isRecurring;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final bool isArchived;
  @override
  @JsonKey()
  final bool attachmentRequired;
  @override
  final AssigneeSelection assigneeSelection;
  final List<String> _selectedGroupIds;
  @override
  @JsonKey()
  List<String> get selectedGroupIds {
    if (_selectedGroupIds is EqualUnmodifiableListView)
      return _selectedGroupIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedGroupIds);
  }

  final List<String> _selectedUserIds;
  @override
  @JsonKey()
  List<String> get selectedUserIds {
    if (_selectedUserIds is EqualUnmodifiableListView) return _selectedUserIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedUserIds);
  }

  @override
  final String createdBy;
// Denormalized fields for performance (avoid extra user fetch)
  @override
  final String? creatorName;
  @override
  final String? creatorEmail;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'TaskModel(id: $id, title: $title, description: $description, labelIds: $labelIds, attachmentUrl: $attachmentUrl, isRecurring: $isRecurring, isActive: $isActive, isArchived: $isArchived, attachmentRequired: $attachmentRequired, assigneeSelection: $assigneeSelection, selectedGroupIds: $selectedGroupIds, selectedUserIds: $selectedUserIds, createdBy: $createdBy, creatorName: $creatorName, creatorEmail: $creatorEmail, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._labelIds, _labelIds) &&
            (identical(other.attachmentUrl, attachmentUrl) ||
                other.attachmentUrl == attachmentUrl) &&
            (identical(other.isRecurring, isRecurring) ||
                other.isRecurring == isRecurring) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isArchived, isArchived) ||
                other.isArchived == isArchived) &&
            (identical(other.attachmentRequired, attachmentRequired) ||
                other.attachmentRequired == attachmentRequired) &&
            (identical(other.assigneeSelection, assigneeSelection) ||
                other.assigneeSelection == assigneeSelection) &&
            const DeepCollectionEquality()
                .equals(other._selectedGroupIds, _selectedGroupIds) &&
            const DeepCollectionEquality()
                .equals(other._selectedUserIds, _selectedUserIds) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.creatorName, creatorName) ||
                other.creatorName == creatorName) &&
            (identical(other.creatorEmail, creatorEmail) ||
                other.creatorEmail == creatorEmail) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      const DeepCollectionEquality().hash(_labelIds),
      attachmentUrl,
      isRecurring,
      isActive,
      isArchived,
      attachmentRequired,
      assigneeSelection,
      const DeepCollectionEquality().hash(_selectedGroupIds),
      const DeepCollectionEquality().hash(_selectedUserIds),
      createdBy,
      creatorName,
      creatorEmail,
      createdAt,
      updatedAt);

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskModelImplCopyWith<_$TaskModelImpl> get copyWith =>
      __$$TaskModelImplCopyWithImpl<_$TaskModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskModelImplToJson(
      this,
    );
  }
}

abstract class _TaskModel extends TaskModel {
  const factory _TaskModel(
      {required final String id,
      required final String title,
      required final String description,
      final List<String> labelIds,
      final String? attachmentUrl,
      final bool isRecurring,
      final bool isActive,
      final bool isArchived,
      final bool attachmentRequired,
      required final AssigneeSelection assigneeSelection,
      final List<String> selectedGroupIds,
      final List<String> selectedUserIds,
      required final String createdBy,
      final String? creatorName,
      final String? creatorEmail,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$TaskModelImpl;
  const _TaskModel._() : super._();

  factory _TaskModel.fromJson(Map<String, dynamic> json) =
      _$TaskModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  List<String> get labelIds;
  @override
  String? get attachmentUrl;
  @override
  bool get isRecurring;
  @override
  bool get isActive;
  @override
  bool get isArchived;
  @override
  bool get attachmentRequired;
  @override
  AssigneeSelection get assigneeSelection;
  @override
  List<String> get selectedGroupIds;
  @override
  List<String> get selectedUserIds;
  @override
  String
      get createdBy; // Denormalized fields for performance (avoid extra user fetch)
  @override
  String? get creatorName;
  @override
  String? get creatorEmail;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskModelImplCopyWith<_$TaskModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
