// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assignment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AssignmentModel _$AssignmentModelFromJson(Map<String, dynamic> json) {
  return _AssignmentModel.fromJson(json);
}

/// @nodoc
mixin _$AssignmentModel {
  String get id => throw _privateConstructorUsedError;
  String get taskId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  AssignmentStatus get status => throw _privateConstructorUsedError;
  String? get apologizeMessage => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  DateTime? get apologizedAt => throw _privateConstructorUsedError;
  DateTime? get overdueAt => throw _privateConstructorUsedError;
  String? get markedDoneBy => throw _privateConstructorUsedError;
  String? get attachmentUrl => throw _privateConstructorUsedError;
  DateTime get scheduledDate => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this AssignmentModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AssignmentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssignmentModelCopyWith<AssignmentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssignmentModelCopyWith<$Res> {
  factory $AssignmentModelCopyWith(
          AssignmentModel value, $Res Function(AssignmentModel) then) =
      _$AssignmentModelCopyWithImpl<$Res, AssignmentModel>;
  @useResult
  $Res call(
      {String id,
      String taskId,
      String userId,
      AssignmentStatus status,
      String? apologizeMessage,
      DateTime? completedAt,
      DateTime? apologizedAt,
      DateTime? overdueAt,
      String? markedDoneBy,
      String? attachmentUrl,
      DateTime scheduledDate,
      DateTime createdAt});
}

/// @nodoc
class _$AssignmentModelCopyWithImpl<$Res, $Val extends AssignmentModel>
    implements $AssignmentModelCopyWith<$Res> {
  _$AssignmentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AssignmentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? userId = null,
    Object? status = null,
    Object? apologizeMessage = freezed,
    Object? completedAt = freezed,
    Object? apologizedAt = freezed,
    Object? overdueAt = freezed,
    Object? markedDoneBy = freezed,
    Object? attachmentUrl = freezed,
    Object? scheduledDate = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as AssignmentStatus,
      apologizeMessage: freezed == apologizeMessage
          ? _value.apologizeMessage
          : apologizeMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      apologizedAt: freezed == apologizedAt
          ? _value.apologizedAt
          : apologizedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      overdueAt: freezed == overdueAt
          ? _value.overdueAt
          : overdueAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      markedDoneBy: freezed == markedDoneBy
          ? _value.markedDoneBy
          : markedDoneBy // ignore: cast_nullable_to_non_nullable
              as String?,
      attachmentUrl: freezed == attachmentUrl
          ? _value.attachmentUrl
          : attachmentUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduledDate: null == scheduledDate
          ? _value.scheduledDate
          : scheduledDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AssignmentModelImplCopyWith<$Res>
    implements $AssignmentModelCopyWith<$Res> {
  factory _$$AssignmentModelImplCopyWith(_$AssignmentModelImpl value,
          $Res Function(_$AssignmentModelImpl) then) =
      __$$AssignmentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String taskId,
      String userId,
      AssignmentStatus status,
      String? apologizeMessage,
      DateTime? completedAt,
      DateTime? apologizedAt,
      DateTime? overdueAt,
      String? markedDoneBy,
      String? attachmentUrl,
      DateTime scheduledDate,
      DateTime createdAt});
}

/// @nodoc
class __$$AssignmentModelImplCopyWithImpl<$Res>
    extends _$AssignmentModelCopyWithImpl<$Res, _$AssignmentModelImpl>
    implements _$$AssignmentModelImplCopyWith<$Res> {
  __$$AssignmentModelImplCopyWithImpl(
      _$AssignmentModelImpl _value, $Res Function(_$AssignmentModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of AssignmentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? userId = null,
    Object? status = null,
    Object? apologizeMessage = freezed,
    Object? completedAt = freezed,
    Object? apologizedAt = freezed,
    Object? overdueAt = freezed,
    Object? markedDoneBy = freezed,
    Object? attachmentUrl = freezed,
    Object? scheduledDate = null,
    Object? createdAt = null,
  }) {
    return _then(_$AssignmentModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as AssignmentStatus,
      apologizeMessage: freezed == apologizeMessage
          ? _value.apologizeMessage
          : apologizeMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      apologizedAt: freezed == apologizedAt
          ? _value.apologizedAt
          : apologizedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      overdueAt: freezed == overdueAt
          ? _value.overdueAt
          : overdueAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      markedDoneBy: freezed == markedDoneBy
          ? _value.markedDoneBy
          : markedDoneBy // ignore: cast_nullable_to_non_nullable
              as String?,
      attachmentUrl: freezed == attachmentUrl
          ? _value.attachmentUrl
          : attachmentUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduledDate: null == scheduledDate
          ? _value.scheduledDate
          : scheduledDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AssignmentModelImpl extends _AssignmentModel {
  const _$AssignmentModelImpl(
      {required this.id,
      required this.taskId,
      required this.userId,
      required this.status,
      this.apologizeMessage,
      this.completedAt,
      this.apologizedAt,
      this.overdueAt,
      this.markedDoneBy,
      this.attachmentUrl,
      required this.scheduledDate,
      required this.createdAt})
      : super._();

  factory _$AssignmentModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssignmentModelImplFromJson(json);

  @override
  final String id;
  @override
  final String taskId;
  @override
  final String userId;
  @override
  final AssignmentStatus status;
  @override
  final String? apologizeMessage;
  @override
  final DateTime? completedAt;
  @override
  final DateTime? apologizedAt;
  @override
  final DateTime? overdueAt;
  @override
  final String? markedDoneBy;
  @override
  final String? attachmentUrl;
  @override
  final DateTime scheduledDate;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'AssignmentModel(id: $id, taskId: $taskId, userId: $userId, status: $status, apologizeMessage: $apologizeMessage, completedAt: $completedAt, apologizedAt: $apologizedAt, overdueAt: $overdueAt, markedDoneBy: $markedDoneBy, attachmentUrl: $attachmentUrl, scheduledDate: $scheduledDate, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssignmentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.apologizeMessage, apologizeMessage) ||
                other.apologizeMessage == apologizeMessage) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.apologizedAt, apologizedAt) ||
                other.apologizedAt == apologizedAt) &&
            (identical(other.overdueAt, overdueAt) ||
                other.overdueAt == overdueAt) &&
            (identical(other.markedDoneBy, markedDoneBy) ||
                other.markedDoneBy == markedDoneBy) &&
            (identical(other.attachmentUrl, attachmentUrl) ||
                other.attachmentUrl == attachmentUrl) &&
            (identical(other.scheduledDate, scheduledDate) ||
                other.scheduledDate == scheduledDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      taskId,
      userId,
      status,
      apologizeMessage,
      completedAt,
      apologizedAt,
      overdueAt,
      markedDoneBy,
      attachmentUrl,
      scheduledDate,
      createdAt);

  /// Create a copy of AssignmentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssignmentModelImplCopyWith<_$AssignmentModelImpl> get copyWith =>
      __$$AssignmentModelImplCopyWithImpl<_$AssignmentModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AssignmentModelImplToJson(
      this,
    );
  }
}

abstract class _AssignmentModel extends AssignmentModel {
  const factory _AssignmentModel(
      {required final String id,
      required final String taskId,
      required final String userId,
      required final AssignmentStatus status,
      final String? apologizeMessage,
      final DateTime? completedAt,
      final DateTime? apologizedAt,
      final DateTime? overdueAt,
      final String? markedDoneBy,
      final String? attachmentUrl,
      required final DateTime scheduledDate,
      required final DateTime createdAt}) = _$AssignmentModelImpl;
  const _AssignmentModel._() : super._();

  factory _AssignmentModel.fromJson(Map<String, dynamic> json) =
      _$AssignmentModelImpl.fromJson;

  @override
  String get id;
  @override
  String get taskId;
  @override
  String get userId;
  @override
  AssignmentStatus get status;
  @override
  String? get apologizeMessage;
  @override
  DateTime? get completedAt;
  @override
  DateTime? get apologizedAt;
  @override
  DateTime? get overdueAt;
  @override
  String? get markedDoneBy;
  @override
  String? get attachmentUrl;
  @override
  DateTime get scheduledDate;
  @override
  DateTime get createdAt;

  /// Create a copy of AssignmentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssignmentModelImplCopyWith<_$AssignmentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AssignmentWithTask {
  AssignmentModel get assignment => throw _privateConstructorUsedError;
  String get taskTitle => throw _privateConstructorUsedError;
  String get taskDescription => throw _privateConstructorUsedError;
  List<String> get taskLabelIds => throw _privateConstructorUsedError;
  String? get taskAttachmentUrl => throw _privateConstructorUsedError;
  bool get taskAttachmentRequired => throw _privateConstructorUsedError;
  String get taskCreatorId => throw _privateConstructorUsedError;
  String get taskCreatorName => throw _privateConstructorUsedError;

  /// Create a copy of AssignmentWithTask
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssignmentWithTaskCopyWith<AssignmentWithTask> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssignmentWithTaskCopyWith<$Res> {
  factory $AssignmentWithTaskCopyWith(
          AssignmentWithTask value, $Res Function(AssignmentWithTask) then) =
      _$AssignmentWithTaskCopyWithImpl<$Res, AssignmentWithTask>;
  @useResult
  $Res call(
      {AssignmentModel assignment,
      String taskTitle,
      String taskDescription,
      List<String> taskLabelIds,
      String? taskAttachmentUrl,
      bool taskAttachmentRequired,
      String taskCreatorId,
      String taskCreatorName});

  $AssignmentModelCopyWith<$Res> get assignment;
}

/// @nodoc
class _$AssignmentWithTaskCopyWithImpl<$Res, $Val extends AssignmentWithTask>
    implements $AssignmentWithTaskCopyWith<$Res> {
  _$AssignmentWithTaskCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AssignmentWithTask
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? assignment = null,
    Object? taskTitle = null,
    Object? taskDescription = null,
    Object? taskLabelIds = null,
    Object? taskAttachmentUrl = freezed,
    Object? taskAttachmentRequired = null,
    Object? taskCreatorId = null,
    Object? taskCreatorName = null,
  }) {
    return _then(_value.copyWith(
      assignment: null == assignment
          ? _value.assignment
          : assignment // ignore: cast_nullable_to_non_nullable
              as AssignmentModel,
      taskTitle: null == taskTitle
          ? _value.taskTitle
          : taskTitle // ignore: cast_nullable_to_non_nullable
              as String,
      taskDescription: null == taskDescription
          ? _value.taskDescription
          : taskDescription // ignore: cast_nullable_to_non_nullable
              as String,
      taskLabelIds: null == taskLabelIds
          ? _value.taskLabelIds
          : taskLabelIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      taskAttachmentUrl: freezed == taskAttachmentUrl
          ? _value.taskAttachmentUrl
          : taskAttachmentUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      taskAttachmentRequired: null == taskAttachmentRequired
          ? _value.taskAttachmentRequired
          : taskAttachmentRequired // ignore: cast_nullable_to_non_nullable
              as bool,
      taskCreatorId: null == taskCreatorId
          ? _value.taskCreatorId
          : taskCreatorId // ignore: cast_nullable_to_non_nullable
              as String,
      taskCreatorName: null == taskCreatorName
          ? _value.taskCreatorName
          : taskCreatorName // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }

  /// Create a copy of AssignmentWithTask
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AssignmentModelCopyWith<$Res> get assignment {
    return $AssignmentModelCopyWith<$Res>(_value.assignment, (value) {
      return _then(_value.copyWith(assignment: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AssignmentWithTaskImplCopyWith<$Res>
    implements $AssignmentWithTaskCopyWith<$Res> {
  factory _$$AssignmentWithTaskImplCopyWith(_$AssignmentWithTaskImpl value,
          $Res Function(_$AssignmentWithTaskImpl) then) =
      __$$AssignmentWithTaskImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {AssignmentModel assignment,
      String taskTitle,
      String taskDescription,
      List<String> taskLabelIds,
      String? taskAttachmentUrl,
      bool taskAttachmentRequired,
      String taskCreatorId,
      String taskCreatorName});

  @override
  $AssignmentModelCopyWith<$Res> get assignment;
}

/// @nodoc
class __$$AssignmentWithTaskImplCopyWithImpl<$Res>
    extends _$AssignmentWithTaskCopyWithImpl<$Res, _$AssignmentWithTaskImpl>
    implements _$$AssignmentWithTaskImplCopyWith<$Res> {
  __$$AssignmentWithTaskImplCopyWithImpl(_$AssignmentWithTaskImpl _value,
      $Res Function(_$AssignmentWithTaskImpl) _then)
      : super(_value, _then);

  /// Create a copy of AssignmentWithTask
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? assignment = null,
    Object? taskTitle = null,
    Object? taskDescription = null,
    Object? taskLabelIds = null,
    Object? taskAttachmentUrl = freezed,
    Object? taskAttachmentRequired = null,
    Object? taskCreatorId = null,
    Object? taskCreatorName = null,
  }) {
    return _then(_$AssignmentWithTaskImpl(
      assignment: null == assignment
          ? _value.assignment
          : assignment // ignore: cast_nullable_to_non_nullable
              as AssignmentModel,
      taskTitle: null == taskTitle
          ? _value.taskTitle
          : taskTitle // ignore: cast_nullable_to_non_nullable
              as String,
      taskDescription: null == taskDescription
          ? _value.taskDescription
          : taskDescription // ignore: cast_nullable_to_non_nullable
              as String,
      taskLabelIds: null == taskLabelIds
          ? _value._taskLabelIds
          : taskLabelIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      taskAttachmentUrl: freezed == taskAttachmentUrl
          ? _value.taskAttachmentUrl
          : taskAttachmentUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      taskAttachmentRequired: null == taskAttachmentRequired
          ? _value.taskAttachmentRequired
          : taskAttachmentRequired // ignore: cast_nullable_to_non_nullable
              as bool,
      taskCreatorId: null == taskCreatorId
          ? _value.taskCreatorId
          : taskCreatorId // ignore: cast_nullable_to_non_nullable
              as String,
      taskCreatorName: null == taskCreatorName
          ? _value.taskCreatorName
          : taskCreatorName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$AssignmentWithTaskImpl implements _AssignmentWithTask {
  const _$AssignmentWithTaskImpl(
      {required this.assignment,
      required this.taskTitle,
      required this.taskDescription,
      required final List<String> taskLabelIds,
      this.taskAttachmentUrl,
      this.taskAttachmentRequired = false,
      required this.taskCreatorId,
      required this.taskCreatorName})
      : _taskLabelIds = taskLabelIds;

  @override
  final AssignmentModel assignment;
  @override
  final String taskTitle;
  @override
  final String taskDescription;
  final List<String> _taskLabelIds;
  @override
  List<String> get taskLabelIds {
    if (_taskLabelIds is EqualUnmodifiableListView) return _taskLabelIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_taskLabelIds);
  }

  @override
  final String? taskAttachmentUrl;
  @override
  @JsonKey()
  final bool taskAttachmentRequired;
  @override
  final String taskCreatorId;
  @override
  final String taskCreatorName;

  @override
  String toString() {
    return 'AssignmentWithTask(assignment: $assignment, taskTitle: $taskTitle, taskDescription: $taskDescription, taskLabelIds: $taskLabelIds, taskAttachmentUrl: $taskAttachmentUrl, taskAttachmentRequired: $taskAttachmentRequired, taskCreatorId: $taskCreatorId, taskCreatorName: $taskCreatorName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssignmentWithTaskImpl &&
            (identical(other.assignment, assignment) ||
                other.assignment == assignment) &&
            (identical(other.taskTitle, taskTitle) ||
                other.taskTitle == taskTitle) &&
            (identical(other.taskDescription, taskDescription) ||
                other.taskDescription == taskDescription) &&
            const DeepCollectionEquality()
                .equals(other._taskLabelIds, _taskLabelIds) &&
            (identical(other.taskAttachmentUrl, taskAttachmentUrl) ||
                other.taskAttachmentUrl == taskAttachmentUrl) &&
            (identical(other.taskAttachmentRequired, taskAttachmentRequired) ||
                other.taskAttachmentRequired == taskAttachmentRequired) &&
            (identical(other.taskCreatorId, taskCreatorId) ||
                other.taskCreatorId == taskCreatorId) &&
            (identical(other.taskCreatorName, taskCreatorName) ||
                other.taskCreatorName == taskCreatorName));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      assignment,
      taskTitle,
      taskDescription,
      const DeepCollectionEquality().hash(_taskLabelIds),
      taskAttachmentUrl,
      taskAttachmentRequired,
      taskCreatorId,
      taskCreatorName);

  /// Create a copy of AssignmentWithTask
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssignmentWithTaskImplCopyWith<_$AssignmentWithTaskImpl> get copyWith =>
      __$$AssignmentWithTaskImplCopyWithImpl<_$AssignmentWithTaskImpl>(
          this, _$identity);
}

abstract class _AssignmentWithTask implements AssignmentWithTask {
  const factory _AssignmentWithTask(
      {required final AssignmentModel assignment,
      required final String taskTitle,
      required final String taskDescription,
      required final List<String> taskLabelIds,
      final String? taskAttachmentUrl,
      final bool taskAttachmentRequired,
      required final String taskCreatorId,
      required final String taskCreatorName}) = _$AssignmentWithTaskImpl;

  @override
  AssignmentModel get assignment;
  @override
  String get taskTitle;
  @override
  String get taskDescription;
  @override
  List<String> get taskLabelIds;
  @override
  String? get taskAttachmentUrl;
  @override
  bool get taskAttachmentRequired;
  @override
  String get taskCreatorId;
  @override
  String get taskCreatorName;

  /// Create a copy of AssignmentWithTask
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssignmentWithTaskImplCopyWith<_$AssignmentWithTaskImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
