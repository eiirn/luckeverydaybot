import 'dart:developer';

import 'package:supabase/supabase.dart' hide User;
import '../models/user.dart';

class UserMethods {
  factory UserMethods(SupabaseClient supabase) =>
      _instance ??= UserMethods._internal(supabase);
  UserMethods._internal(this._supabase);
  final SupabaseClient _supabase;

  static UserMethods? _instance;

  /// Table name in Supabase
  static const String _tableName = 'users';

  /// Creates a new user in the database
  /// Returns the created User object or throws an exception if creation fails
  Future<BotUser> createUser({
    required int userId,
    required String name,
    int? referralId,
    String? langauge,
  }) async {
    try {
      // Check if user already exists
      final existingUser = await getUserById(userId);
      if (existingUser != null) {
        return existingUser;
      }

      // Create a new user instance
      final newUser = BotUser(
        userId: userId,
        name: name,
        referredBy: referralId,
        language: langauge,
      );

      // Insert the new user into the database
      final response =
          await _supabase
              .from(_tableName)
              .insert(newUser.toJson())
              .select()
              .single();

      // Return the created user
      return BotUser.fromJson(response);
    } catch (e, stack) {
      log('Error creating user.', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Retrieves a user from the database by their userId
  /// Returns null if the user does not exist
  Future<BotUser?> getUserById(int userId) async {
    try {
      final response =
          await _supabase
              .from(_tableName)
              .select()
              .eq('user_id', userId)
              .maybeSingle();

      if (response == null) {
        return null; // User not found
      }

      return BotUser.fromJson(response);
    } catch (e, stack) {
      log('Error while getting user info.', error: e, stackTrace: stack);
      return null;
    }
  }

  /// Updates an existing user in the database
  /// Returns the updated User object
  Future<BotUser> updateUser(BotUser user) async {
    try {
      final response =
          await _supabase
              .from(_tableName)
              .update(user.toJson())
              .eq('user_id', user.userId)
              .select()
              .single();

      return BotUser.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  /// Updates a specific field for a user
  /// Useful for incrementing values like winnings or totalSpends
  Future<BotUser> updateUserField(
    int userId,
    String field,
    dynamic value,
  ) async {
    try {
      final response =
          await _supabase
              .from(_tableName)
              .update({field: value})
              .eq('user_id', userId)
              .select()
              .single();

      return BotUser.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update user field: $e');
    }
  }

  /// Fetches active users who haven't been updated in 7-15 days and haven't been notified in the last 3 days
  ///
  /// Returns a list of [BotUser] objects for users who:
  /// - Are not banned
  /// - Are not blocked
  /// - Were last updated between 7 and 15 days ago
  /// - Haven't been notified in the last 3 days (or never notified)
  Future<List<BotUser>> fetchUsersForReminder() async {
    final now = DateTime.now().toUtc();
    final fifteenDaysAgo = now.subtract(const Duration(days: 15));
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final threeDaysAgo = now.subtract(const Duration(days: 3));

    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('banned', false)
          .eq('blocked', false)
          .gte('updated_at', fifteenDaysAgo.toIso8601String())
          .lt('updated_at', sevenDaysAgo.toIso8601String())
          .or(
            'last_notified.is.null,last_notified.lt.${threeDaysAgo.toIso8601String()}',
          );

      return response.map(BotUser.fromJson).toList();
    } catch (e, stack) {
      // Handle errors appropriately
      log('Error fetching users for reminder.', error: e, stackTrace: stack);
      return [];
    }
  }

  Future<void> updateLastNotified(int userId) async {
    await _supabase
        .from('users')
        .update({'last_notified': DateTime.now().toUtc().toIso8601String()})
        .eq('user_id', userId);
  }
}
