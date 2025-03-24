import 'package:supabase/supabase.dart';

import '../luckeverydaybot.dart';
import '../models/pool_entry.dart';

/// A class that provides methods for interacting with pool entries in the
/// database.
class PoolMethods {
  /// Creates a new instance of PoolMethods.
  ///
  /// [supabase] is the Supabase client to use for database operations.
  PoolMethods(this._supabase);
  final SupabaseClient _supabase;

  /// Gets the current date in "DD-MM-YYYY" format.
  String _getCurrentDate() {
    final now = DateTime.now().toUtc();
    return '${now.day.toString().padLeft(2, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.year}';
  }

  /// Creates a new pool entry or updates an existing one.
  ///
  /// [userId] is the ID of the user participating in the pool.
  /// [amount] is the amount of stars contributed in this transaction.
  /// [transactionId] is the ID of the transaction.
  ///
  /// Returns the updated pool entry.
  Future<PoolEntry> createEntry(
    int userId,
    int amount,
    String transactionId,
  ) async {
    final date = _getCurrentDate();

    // Check if an entry already exists for this user and date
    final response =
        await _supabase
            .from('pool')
            .select()
            .eq('user_id', userId)
            .eq('date', date)
            .maybeSingle();

    // First, call the RPC function to get the updated value
    final rpcResponse = await _supabase.rpc(
      'increment_field',
      params: {
        'column_name': 'total_spends',
        'increment_by': amount,
        'user_id': userId,
      },
    );

    // Then update the users table with the new value
    await _supabase
        .from('users')
        .update({'total_spends': rpcResponse})
        .eq('user_id', userId);

    if (response != null) {
      // Update existing entry
      final existingEntry = PoolEntry.fromJson(response);
      final updatedEntry = existingEntry.copyWith(
        amount: existingEntry.amount + amount,
        transactionIds: [...existingEntry.transactionIds, transactionId],
        updatedAt: DateTime.now().toUtc(),
      );

      await _supabase
          .from('pool')
          .update(updatedEntry.toJson())
          .eq('user_id', userId)
          .eq('date', date);

      return updatedEntry;
    } else {
      // Create new entry
      final newEntry = PoolEntry(
        userId: userId,
        date: date,
        amount: amount,
        transactionIds: [transactionId],
      );

      await _supabase.from('pool').insert(newEntry.toJson());

      return newEntry;
    }
  }

  /// Retrieves all pool entries for today.
  ///
  /// Returns a list of all pool entries for the current date.
  Future<List<PoolEntry>> getTodayEntries() async {
    final date = _getCurrentDate();

    final response = await _supabase
        .from('pool')
        .select()
        .eq('date', date)
        .order('amount', ascending: false);

    return (response as List<dynamic>)
        .map((entry) => PoolEntry.fromJson(entry as Map<String, dynamic>))
        .toList();
  }

  /// Retrieves the total amount in today's pool.
  ///
  /// Returns the sum of all contributions in today's pool.
  Future<int> getTodayPoolTotal() async {
    final entries = await getTodayEntries();
    final sum = entries.fold(0, (sum, entry) => sum + entry.amount);
    return sum;
  }

  /// Retrieves the count of unique users in today's pool.
  ///
  /// Returns the number of distinct users who have placed bets today.
  Future<int> getTodayUniqueUserCount() async {
    final date = _getCurrentDate();

    final response =
        await _supabase.from('pool').select('user_id').eq('date', date).count();
    return response.count;
  }

  /// Marks a user as today's winner.
  ///
  /// [userId] is the ID of the winning user.
  ///
  /// Returns the updated pool entry for the winner.
  Future<PoolEntry?> markWinner(int userId) async {
    final date = _getCurrentDate();

    // Check if the user has an entry for today
    final response =
        await _supabase
            .from('pool')
            .select()
            .eq('user_id', userId)
            .eq('date', date)
            .maybeSingle();

    if (response != null) {
      final entry = PoolEntry.fromJson(response);
      final updatedEntry = entry.copyWith(
        isWinner: true,
        updatedAt: DateTime.now().toUtc(),
      );

      await _supabase
          .from('pool')
          .update(updatedEntry.toJson())
          .eq('user_id', userId)
          .eq('date', date);

      return updatedEntry;
    }

    return null;
  }

  /// Retrieves a user's pool entry for today.
  ///
  /// [userId] is the ID of the user whose pool entry we want to retrieve.
  ///
  /// Returns the PoolEntry object for the user for today,
  /// or null if they haven't participated.
  Future<PoolEntry?> getUserTodayPoolEntry(int userId) async {
    final date = _getCurrentDate();

    final response =
        await _supabase
            .from('pool')
            .select()
            .eq('date', date)
            .eq('user_id', userId)
            .maybeSingle();

    if (response != null) {
      return PoolEntry.fromJson(response);
    }

    return null;
  }
}
