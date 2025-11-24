import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/ksa_timezone.dart';

part 'settings_model.freezed.dart';
part 'settings_model.g.dart';

/// App settings model
@freezed
class SettingsModel with _$SettingsModel {
  const SettingsModel._();

  const factory SettingsModel({
    @Default(AppConstants.defaultRecurringTime) String recurringTaskTime,
    @Default(AppConstants.defaultDeadlineTime) String taskDeadline,
  }) = _SettingsModel;

  factory SettingsModel.fromJson(Map<String, dynamic> json) =>
      _$SettingsModelFromJson(json);

  /// Create from Firestore document
  factory SettingsModel.fromFirestore(DocumentSnapshot doc) {
    if (!doc.exists) {
      return const SettingsModel();
    }
    final data = doc.data() as Map<String, dynamic>;
    return SettingsModel.fromJson(data);
  }

  /// Default settings
  factory SettingsModel.defaults() => const SettingsModel();

  /// Parse recurring time to hours and minutes
  (int hours, int minutes) get recurringTimeParsed {
    final parts = recurringTaskTime.split(':');
    return (int.parse(parts[0]), int.parse(parts[1]));
  }

  /// Parse deadline to hours and minutes
  (int hours, int minutes) get deadlineParsed {
    final parts = taskDeadline.split(':');
    return (int.parse(parts[0]), int.parse(parts[1]));
  }

  /// Get today's deadline as DateTime (in KSA timezone)
  DateTime get todayDeadline => KsaTimezone.todayAt(taskDeadline);

  /// Get today's recurring time as DateTime (in KSA timezone)
  DateTime get todayRecurringTime => KsaTimezone.todayAt(recurringTaskTime);

  /// Check if current time is before deadline (in KSA timezone)
  bool get isBeforeDeadline => KsaTimezone.now().isBefore(todayDeadline);

  /// Check if current time is after recurring time (in KSA timezone)
  bool get isAfterRecurringTime => KsaTimezone.now().isAfter(todayRecurringTime);

  /// Check if current time is within the task window (after recurring time and before deadline)
  bool get isWithinTaskWindow => isAfterRecurringTime && isBeforeDeadline;

  /// Convert to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'recurringTaskTime': recurringTaskTime,
      'taskDeadline': taskDeadline,
    };
  }
}
