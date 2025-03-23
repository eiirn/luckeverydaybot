/// Utility functions for consistent formatting throughout the app.
library;

/// Formats a star amount for display, adding commas as thousand separators
/// and the star emoji for better readability and visual appeal.
///
/// Examples:
/// - formatStarAmount(1000) => "1,000 ⭐"
/// - formatStarAmount(1500000) => "1,500,000 ⭐"
/// - formatStarAmount(25) => "25 ⭐"
String formatStarAmount(int amount) {
  // Format with thousand separators
  final formattedNumber = _addThousandSeparators(amount);

  // Return with star emoji
  return '$formattedNumber ⭐';
}

/// Formats a star amount without the emoji, just with thousand separators.
/// Useful for cases where the emoji is not needed or appropriate.
String formatStarAmountPlain(int amount) => _addThousandSeparators(amount);

/// Private helper function to add thousand separators to numbers
String _addThousandSeparators(int number) {
  // Convert to string
  final String numStr = number.toString();

  // Add commas for thousand separators
  final result = StringBuffer();
  final length = numStr.length;

  for (int i = 0; i < length; i++) {
    // Add comma every 3 digits from the right
    if (i > 0 && (length - i) % 3 == 0) {
      result.write(',');
    }
    result.write(numStr[i]);
  }

  return result.toString();
}

/// Formats a percentage value for display, ensuring it has proper
/// decimal places and the % symbol.
///
/// Examples:
/// - formatPercentage(75.5) => "75.5%"
/// - formatPercentage(100) => "100%"
String formatPercentage(double percentage, {int decimalPlaces = 1}) =>
    '${percentage.toStringAsFixed(decimalPlaces)}%';

/// Formats a date in a user-friendly format.
///
/// Example:
/// - formatDate(DateTime.now()) => "23 Mar 2025"
String formatDate(DateTime date) {
  final months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

/// Formats a timestamp in a user-friendly format with time.
///
/// Example:
/// - formatTimestamp(DateTime.now()) => "23 Mar, 12:30 PM"
String formatTimestamp(DateTime timestamp) {
  final months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  // Format hour in 12-hour format
  final int hour =
      timestamp.hour > 12
          ? timestamp.hour - 12
          : timestamp.hour == 0
          ? 12
          : timestamp.hour;
  final String period = timestamp.hour >= 12 ? 'PM' : 'AM';

  // Format minute with leading zero if needed
  final String minute = timestamp.minute.toString().padLeft(2, '0');

  return '${timestamp.day} ${months[timestamp.month - 1]}, '
      '$hour:$minute $period';
}

/// Formats a duration in a user-friendly way.
///
/// Examples:
/// - formatDuration(Duration(hours: 2, minutes: 30)) => "2h 30m"
/// - formatDuration(Duration(minutes: 45)) => "45m"
String formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;

  if (hours > 0) {
    return '${hours}h ${minutes}m';
  } else {
    return '${minutes}m';
  }
}
