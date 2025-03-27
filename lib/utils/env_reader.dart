import 'dart:developer';
import 'dart:io';

/// A simple environment variable reader that reads from system environment variables
/// and falls back to the .env file if not found in system environment
class EnvReader {
  EnvReader._();
  static final Map<String, String> _envVars = {};
  static bool _initialized = false;

  /// Initialize the environment variables from .env file (only if running locally)
  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    // Use system environment variables first
    _envVars.addAll(Platform.environment);

    // Try loading from .env only if it exists (for local development)
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
            // Only set if not already in system environment
            _envVars.putIfAbsent(key, () => value);
          }
        }
      }
      _initialized = true;
    } catch (e) {
      log('Error reading .env file: $e');
    }
  }

  /// Get an environment variable, first looking in system environment
  /// and then falling back to .env file if not found
  static String? get(String key) => _envVars[key];

  /// Get a required environment variable, throws if not found
  static String getRequired(String key) {
    final value = get(key);
    if (value == null) {
      throw Exception('Required environment variable $key not found');
    }
    return value;
  }
}
