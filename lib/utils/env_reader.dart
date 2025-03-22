import 'dart:io';

/// A simple environment variable reader that reads from .env file
/// and falls back to system environment variables if not found in .env
class EnvReader {
  EnvReader._();
  static final Map<String, String> _envVars = {};
  static bool _initialized = false;

  /// Initialize the environment variables from .env file
  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    try {
      final file = File('.env');
      if (file.existsSync()) {
        final lines = await file.readAsLines();
        for (final line in lines) {
          // Skip comments and empty lines
          if (line.trim().isEmpty || line.trim().startsWith('#')) {
            continue;
          }

          // Parse key-value pairs
          final parts = line.split('=');
          if (parts.length >= 2) {
            final key = parts[0].trim();
            // Join the rest in case value contains '=' character
            final value = parts.sublist(1).join('=').trim();
            _envVars[key] = value;
          }
        }
      }
      _initialized = true;
    } catch (e) {
      print('Error reading .env file: $e');
    }
  }

  /// Get an environment variable, first looking in the .env file
  /// and then falling back to system environment variables
  static String? get(String key) {
    // Check if initialized, initialize synchronously if not
    if (!_initialized) {
      final file = File('.env');
      if (file.existsSync()) {
        final lines = file.readAsLinesSync();
        for (final line in lines) {
          if (line.trim().isEmpty || line.trim().startsWith('#')) {
            continue;
          }

          final parts = line.split('=');
          if (parts.length >= 2) {
            final key = parts[0].trim();
            final value = parts.sublist(1).join('=').trim();
            _envVars[key] = value;
          }
        }
      }
      _initialized = true;
    }

    // Return from .env file or system environment
    return _envVars[key] ?? Platform.environment[key];
  }

  /// Get a required environment variable, throws if not found
  static String getRequired(String key) {
    final value = get(key);
    if (value == null) {
      throw Exception('Required environment variable $key not found');
    }
    return value;
  }

  /// Get an integer value from environment
  static int getInt(String key, {int defaultValue = 0}) {
    final value = get(key);
    if (value == null) {
      return defaultValue;
    }
    return int.tryParse(value) ?? defaultValue;
  }

  /// Get a boolean value from environment
  static bool getBool(String key, {bool defaultValue = false}) {
    final value = get(key);
    if (value == null) {
      return defaultValue;
    }
    return value.toLowerCase() == 'true';
  }

  /// Get a list of values (comma separated) from environment
  static List<String> getList(String key, {String separator = ','}) {
    final value = get(key);
    if (value == null) {
      return [];
    }
    return value.split(separator).map((e) => e.trim()).toList();
  }

  /// Get a list of integers from environment
  static List<int> getIntList(String key, {String separator = ','}) {
    final list = getList(key, separator: separator);
    return list.map((e) => int.tryParse(e) ?? 0).toList();
  }
}
