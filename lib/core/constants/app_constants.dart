/// App-wide constants
abstract final class AppConstants {
  /// App name
  static const String appName = 'Ribal';

  /// App name in Arabic
  static const String appNameAr = 'ريبال';

  /// Default recurring task time
  static const String defaultRecurringTime = '08:00';

  /// Default task deadline time
  static const String defaultDeadlineTime = '20:00';

  /// Date format for display
  static const String dateFormat = 'yyyy/MM/dd';

  /// Time format for display
  static const String timeFormat = 'HH:mm';

  /// DateTime format for display
  static const String dateTimeFormat = 'yyyy/MM/dd HH:mm';

  /// Maximum attachment size in bytes (10 MB)
  static const int maxAttachmentSize = 10 * 1024 * 1024;

  /// Supported attachment extensions
  static const List<String> supportedAttachmentExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
  ];

  /// Pagination page size
  static const int pageSize = 20;

  /// Minimum password length
  static const int minPasswordLength = 8;

  /// Invitation code length
  static const int invitationCodeLength = 8;

  /// Debounce duration for search
  static const Duration searchDebounce = Duration(milliseconds: 500);
}
