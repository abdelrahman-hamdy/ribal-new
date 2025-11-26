/// Utility class for formatting time strings in various formats
/// Supports both 24-hour and 12-hour formats with Arabic localization
class TimeFormatter {
  /// Converts 24-hour time format (HH:mm) to 12-hour format with localized AM/PM
  ///
  /// Examples:
  /// - "20:00" → "8 PM" (English) or "8 مساءً" (Arabic)
  /// - "08:00" → "8 AM" (English) or "8 صباحاً" (Arabic)
  /// - "00:00" → "12 AM" (English) or "12 صباحاً" (Arabic)
  /// - "12:00" → "12 PM" (English) or "12 مساءً" (Arabic)
  ///
  /// [amLabel] - Localized string for AM (e.g., "AM" or "صباحاً")
  /// [pmLabel] - Localized string for PM (e.g., "PM" or "مساءً")
  static String formatTimeArabic(String time24, {String? amLabel, String? pmLabel}) {
    try {
      final parts = time24.split(':');
      if (parts.length != 2) return time24;

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      // Determine AM/PM
      final isPm = hour >= 12;

      // Convert to 12-hour format
      final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

      // Use provided labels or fallback to Arabic defaults
      final period = isPm
          ? (pmLabel ?? 'مساءً')
          : (amLabel ?? 'صباحاً');

      // Format with minutes if not :00
      if (minute == 0) {
        return '$hour12 $period';
      } else {
        final minuteStr = minute.toString().padLeft(2, '0');
        return '$hour12:$minuteStr $period';
      }
    } catch (e) {
      // Return original string if parsing fails
      return time24;
    }
  }

  /// Converts 24-hour time format to 12-hour format (English)
  ///
  /// Examples:
  /// - "20:00" → "8:00 PM"
  /// - "08:00" → "8:00 AM"
  static String formatTime12Hour(String time24) {
    try {
      final parts = time24.split(':');
      if (parts.length != 2) return time24;

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final isPm = hour >= 12;
      final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final period = isPm ? 'PM' : 'AM';
      final minuteStr = minute.toString().padLeft(2, '0');

      return '$hour12:$minuteStr $period';
    } catch (e) {
      return time24;
    }
  }

  /// Validates if a time string is in valid HH:mm format
  static bool isValidTimeFormat(String time) {
    try {
      final parts = time.split(':');
      if (parts.length != 2) return false;

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
    } catch (e) {
      return false;
    }
  }

  /// Compares two time strings (HH:mm format)
  /// Returns:
  /// - negative if time1 < time2
  /// - zero if time1 == time2
  /// - positive if time1 > time2
  static int compareTime(String time1, String time2) {
    try {
      final parts1 = time1.split(':');
      final parts2 = time2.split(':');

      final hour1 = int.parse(parts1[0]);
      final minute1 = int.parse(parts1[1]);
      final hour2 = int.parse(parts2[0]);
      final minute2 = int.parse(parts2[1]);

      final totalMinutes1 = hour1 * 60 + minute1;
      final totalMinutes2 = hour2 * 60 + minute2;

      return totalMinutes1 - totalMinutes2;
    } catch (e) {
      return 0;
    }
  }

  /// Checks if time1 is before time2
  static bool isBefore(String time1, String time2) {
    return compareTime(time1, time2) < 0;
  }

  /// Checks if time1 is after time2
  static bool isAfter(String time1, String time2) {
    return compareTime(time1, time2) > 0;
  }
}
