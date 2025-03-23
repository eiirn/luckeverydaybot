import 'package:supabase/supabase.dart';
import '../models/transaction.dart';

/// Class containing methods for managing transactions in Supabase.
class TransactionMethods {
  /// Constructor that takes a Supabase client.
  TransactionMethods(this._supabase);

  /// The Supabase client instance.
  final SupabaseClient _supabase;

  /// The name of the transactions table in Supabase.
  static const String _tableName = 'transactions';

  /// Adds a new transaction to the database.
  ///
  /// [transaction] The transaction to add.
  ///
  /// Returns a [Future] that completes with the added transaction data if
  /// successful, or throws an error if the operation fails.
  Future<Transaction> addTransaction(Transaction transaction) async {
    try {
      final response =
          await _supabase
              .from(_tableName)
              .insert(transaction.toJson())
              .select()
              .single();

      return Transaction.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }
}
