/// Date utility functions
class DateUtils {
  /// Get today's date string (YYYY-MM-DD, local timezone)
  static String getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${_padZero(now.month)}-${_padZero(now.day)}';
  }

  /// Extract date string (YYYY-MM-DD) from ISO timestamp (local timezone)
  static String? extractDateFromIsoString(String? isoString) {
    if (isoString == null || isoString.isEmpty) {
      return null;
    }

    try {
      final dateTime = DateTime.parse(isoString);
      final localTime = dateTime.toLocal();
      return '${localTime.year}-${_padZero(localTime.month)}-${_padZero(localTime.day)}';
    } catch (e) {
      return null;
    }
  }

  /// Check if ISO timestamp is today (local timezone)
  static bool isToday(String? isoString) {
    if (isoString == null) return false;
    final dateString = extractDateFromIsoString(isoString);
    return dateString == getTodayDateString();
  }

  /// Get start of today (local timezone, converted to UTC for Firestore)
  static DateTime getStartOfTodayUtc() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return startOfDay.toUtc();
  }

  /// Get end of today (local timezone, converted to UTC for Firestore)
  static DateTime getEndOfTodayUtc() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));
    return endOfDay.toUtc();
  }

  static String _padZero(int value) {
    return value.toString().padLeft(2, '0');
  }
}
