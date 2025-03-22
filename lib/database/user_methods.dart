import 'dart:developer';

import 'package:supabase/supabase.dart' hide User;
import '../models/user.dart';

class UserMethods {
  // Table name in Supabase

  UserMethods(this._supabase);
  final SupabaseClient _supabase;
  final String _tableName = 'users';

  /// Creates a new user in the database
  /// Returns the created User object or throws an exception if creation fails
  Future<BotUser> createUser({
    required int userId,
    required String name,
    int? referralId,
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
      rethrow;
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
}
