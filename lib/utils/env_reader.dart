import 'dart:io';

/// A secure environment variable reader that only reads from system environment variables
class EnvReader {
  EnvReader._();
  static final Map<String, String> _envVars = {};
  static bool _initialized = false;

  /// Initialize the environment variables from system environment
  static void initialize() {
    if (_initialized) {
      return;
    }

    // Use system environment variables only
    _envVars.addAll(Platform.environment);
    _initialized = true;
  }

  /// Get an environment variable from system environment
  static String? get(String key) {
    if (!_initialized) {
      initialize();
    }
    return _envVars[key];
  }

  /// Get a required environment variable, throws if not found
  static String getRequired(String key) {
    final value = get(key);
    if (value == null) {
      throw Exception('Required environment variable $key not found');
    }
    return value;
  }

  /// Check if the environment variable exists
  static bool has(String key) {
    if (!_initialized) {
      initialize();
    }
    return _envVars.containsKey(key);
  }
}
