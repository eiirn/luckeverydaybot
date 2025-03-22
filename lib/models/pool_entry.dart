/// A model representing an entry in the daily pool for the lucky draw game.
///
/// This class corresponds to records in the 'pool' table in Supabase, which
/// tracks user contributions to the daily prize pool and whether they've been
/// selected as winners.
class PoolEntry {
  /// Creates a new pool entry.
  ///
  /// [userId] is the ID of the user participating in the pool. [date] is the
  /// date of the pool in "DD-MM-YYYY" format. [amount] is the total amount of
  /// stars contributed by the user on this date. [transactionIds] contains the
  /// IDs of all transactions that contributed to this entry. [isWinner]
  /// indicates whether this user was selected as the winner for this date.
  /// [createdAt] is when this pool entry was first created. [updatedAt] is when
  /// this pool entry was last updated.
  PoolEntry({
    required this.userId,
    required this.date,
    this.amount = 0,
    this.transactionIds = const [],
    this.isWinner = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now().toUtc(),
       updatedAt = updatedAt ?? DateTime.now().toUtc();

  /// Creates a PoolEntry from a JSON map (when fetching from Supabase).
  factory PoolEntry.fromJson(Map<String, dynamic> json) => PoolEntry(
    userId: json['user_id'] as int,
    date: json['date'] as String,
    amount: json['amount'] as int,
    transactionIds:
        (json['transaction_ids'] as List<dynamic>)
            .map((id) => id as String)
            .toList(),
    isWinner: json['is_winner'] as bool,
    createdAt:
        json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
    updatedAt:
        json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
  );

  /// The user ID of the participant.
  final int userId;

  /// The date of this pool entry in "DD-MM-YYYY" format.
  final String date;

  /// The total amount of stars contributed by this user on this date.
  int amount;

  /// List of transaction IDs that make up this pool entry.
  List<String> transactionIds;

  /// Whether this user was selected as the winner for this date.
  bool isWinner;

  /// When this pool entry was first created.
  final DateTime createdAt;

  /// When this pool entry was last updated.
  DateTime updatedAt;

  /// Converts a PoolEntry instance to a JSON map (for storing in Supabase).
  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'date': date,
    'amount': amount,
    'transaction_ids': transactionIds,
    'is_winner': isWinner,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  /// Creates a copy of this PoolEntry with optional updated fields.
  PoolEntry copyWith({
    int? userId,
    String? date,
    int? amount,
    List<String>? transactionIds,
    bool? isWinner,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PoolEntry(
    userId: userId ?? this.userId,
    date: date ?? this.date,
    amount: amount ?? this.amount,
    transactionIds: transactionIds ?? this.transactionIds,
    isWinner: isWinner ?? this.isWinner,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
