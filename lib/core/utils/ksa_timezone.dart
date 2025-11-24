/// KSA Timezone utilities
/// Saudi Arabia is always UTC+3 (no daylight saving time)
class KsaTimezone {
  /// KSA offset from UTC in hours
  static const int offsetHours = 3;

  /// KSA offset from UTC in minutes
  static const int offsetMinutes = offsetHours * 60;

  /// Get current time in KSA timezone
  static DateTime now() {
    final utcNow = DateTime.now().toUtc();
    return utcNow.add(const Duration(hours: offsetHours));
  }

  /// Convert a DateTime to KSA timezone
  static DateTime toKsa(DateTime dateTime) {
    final utc = dateTime.toUtc();
    return utc.add(const Duration(hours: offsetHours));
  }

  /// Get today's date at midnight in KSA timezone
  static DateTime today() {
    final ksaNow = now();
    return DateTime(ksaNow.year, ksaNow.month, ksaNow.day);
  }

  /// Get today's date at a specific time in KSA timezone
  /// [timeStr] should be in "HH:mm" format
  static DateTime todayAt(String timeStr) {
    final parts = timeStr.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    final ksaNow = now();
    return DateTime(ksaNow.year, ksaNow.month, ksaNow.day, hours, minutes);
  }

  /// Get start of today in KSA timezone (00:00:00)
  static DateTime startOfToday() {
    return today();
  }

  /// Get end of today in KSA timezone (23:59:59.999)
  static DateTime endOfToday() {
    final start = today();
    return start.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
  }

  /// Get start of a specific date in KSA timezone
  static DateTime startOfDay(DateTime date) {
    final ksaDate = toKsa(date);
    return DateTime(ksaDate.year, ksaDate.month, ksaDate.day);
  }

  /// Get end of a specific date in KSA timezone
  static DateTime endOfDay(DateTime date) {
    final start = startOfDay(date);
    return start.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
  }

  /// Check if a DateTime is today in KSA timezone
  static bool isToday(DateTime date) {
    final ksaDate = toKsa(date);
    final ksaNow = now();
    return ksaDate.year == ksaNow.year &&
        ksaDate.month == ksaNow.month &&
        ksaDate.day == ksaNow.day;
  }

  /// Get start of current week (Sunday) in KSA timezone
  static DateTime startOfWeek() {
    final ksaNow = now();
    final weekday = ksaNow.weekday == 7 ? 0 : ksaNow.weekday; // Sunday = 0
    return DateTime(ksaNow.year, ksaNow.month, ksaNow.day - weekday);
  }

  /// Get end of current week (Saturday) in KSA timezone
  static DateTime endOfWeek() {
    return startOfWeek().add(const Duration(days: 7));
  }

  /// Get start of current month in KSA timezone
  static DateTime startOfMonth() {
    final ksaNow = now();
    return DateTime(ksaNow.year, ksaNow.month, 1);
  }

  /// Get end of current month in KSA timezone
  static DateTime endOfMonth() {
    final ksaNow = now();
    return DateTime(ksaNow.year, ksaNow.month + 1, 1);
  }
}
