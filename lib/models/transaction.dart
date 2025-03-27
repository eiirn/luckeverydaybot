/// A model representing a transaction in the system.
///
/// This class corresponds to records in the 'transactions' table in Supabase,
/// which tracks all financial transactions between users and the bot.
class Transaction {
  /// Creates a new transaction.
  ///
  /// [transactionId] is a unique identifier for the transaction.
  /// [userId] is the ID of the user who made the transaction.
  /// [amount] is the amount of stars in the transaction.
  /// [invoicePayload] is an optional payload associated with the invoice.
  /// [type] represents the type of transaction (e.g., 'deposit', 'withdrawal').
  /// [note] is an optional note or description for the transaction.
  /// [transactionDate] is when this transaction occurred.
  Transaction({
    required this.transactionId,
    required this.userId,
    required this.amount,
    required this.type,
    this.invoicePayload,
    this.note,
    DateTime? transactionDate,
  }) : transactionDate = transactionDate ?? DateTime.now().toUtc();

  /// Creates a Transaction from a JSON map (when fetching from Supabase).
  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    transactionId: json['transaction_id'] as String,
    userId: json['user_id'] as int,
    amount: json['amount'] as int,
    invoicePayload: json['invoice_payload'] as String?,
    transactionDate:
        json['transaction_date'] != null
            ? DateTime.parse(json['transaction_date'] as String)
            : null,
    type: json['type'] as String,
    note: json['note'] as String?,
  );

  /// The unique identifier for this transaction.
  final String transactionId;

  /// The user ID associated with this transaction.
  final int userId;

  /// The amount of stars in the transaction.
  final int amount;

  /// An optional payload associated with the invoice.
  final String? invoicePayload;

  /// When this transaction occurred.
  final DateTime transactionDate;

  /// The type of transaction (e.g., 'deposit', 'withdrawal').
  final String type;

  /// An optional note or description for the transaction.
  final String? note;

  /// Converts a Transaction instance to a JSON map (for storing in Supabase).
  Map<String, dynamic> toJson() => {
    'transaction_id': transactionId,
    'user_id': userId,
    'amount': amount,
    'invoice_payload': invoicePayload,
    'transaction_date': transactionDate.toIso8601String(),
    'type': type,
    'note': note,
  };

  /// Creates a copy of this Transaction with optional updated fields.
  Transaction copyWith({
    String? transactionId,
    int? userId,
    int? amount,
    String? invoicePayload,
    DateTime? transactionDate,
    String? type,
    String? note,
  }) => Transaction(
    transactionId: transactionId ?? this.transactionId,
    userId: userId ?? this.userId,
    amount: amount ?? this.amount,
    invoicePayload: invoicePayload ?? this.invoicePayload,
    transactionDate: transactionDate ?? this.transactionDate,
    type: type ?? this.type,
    note: note ?? this.note,
  );
}
