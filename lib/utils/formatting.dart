/// Utility functions for consistent formatting throughout the app.
library;

/// Gets the current date in "DD-MM-YYYY" format.
String getCurrentDate() {
  final now = DateTime.now().toUtc();
  return '${now.day.toString().padLeft(2, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.year}';
}

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
