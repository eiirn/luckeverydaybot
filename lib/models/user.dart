import '../language/language.dart';

/// Represents the Bot's user
class BotUser {
  /// Constructs the Bot user class with the values.
  BotUser({
    required this.userId,
    required this.name,
    this.banned = false,
    this.blocked = false,
    this.hasJoinedChannel = false,
    this.hasJoinedGroup = false,
    this.winnings = 0,
    this.totalSpends = 0,
    this.referredBy,
    DateTime? createdDate,
    this.isVip = false,
    this.vipDate,
    this.langCode = 'en',
    this.balance = 0,
    this.isPremium = false,
  }) : createdDate = createdDate ?? DateTime.now().toUtc();

  /// Create a User instance from a JSON map (for when fetching from Supabase)
  factory BotUser.fromJson(Map<String, dynamic> json) => BotUser(
    userId: json['user_id'] as int,
    name: json['name'] as String,
    banned: (json['banned'] ?? false) as bool,
    blocked: (json['blocked'] ?? false) as bool,
    hasJoinedChannel: (json['has_joined_channel'] ?? false) as bool,
    hasJoinedGroup: (json['has_joined_group'] ?? false) as bool,
    winnings: (json['winnings'] ?? 0) as int,
    totalSpends: (json['total_spends'] ?? 0) as int,
    referredBy: json['referred_by'] as int?,
    createdDate:
        json['created_date'] != null
            ? DateTime.parse(json['created_date'] as String)
            : null,
    isVip: (json['is_vip'] ?? false) as bool,
    vipDate:
        json['vip_date'] != null
            ? DateTime.parse(json['vip_date'] as String)
            : null,
    langCode: json['lang_code'] as String? ?? 'en',
    balance: json['balance'] as int,
    isPremium: json['is_premium'] as bool? ?? false,
  );

  final int userId;
  final String name;
  bool banned;
  bool blocked;
  bool hasJoinedChannel;
  bool hasJoinedGroup;
  int winnings;
  int totalSpends;
  int? referredBy;
  DateTime createdDate;
  bool isVip;
  DateTime? vipDate;
  String langCode;
  final int balance;

  /// Whether user has Telegram Premium
  final bool isPremium;

  /// Convert User instance to a JSON map (for when storing in Supabase)
  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'name': name,
    'banned': banned,
    'blocked': blocked,
    'has_joined_channel': hasJoinedChannel,
    'has_joined_group': hasJoinedGroup,
    'winnings': winnings,
    'total_spends': totalSpends,
    'referred_by': referredBy,
    'created_date': createdDate.toIso8601String(),
    'is_vip': isVip,
    'vip_date': vipDate?.toIso8601String(),
    'lang_code': langCode,
    'balance': balance,
    'is_premium': isPremium,
  };

  /// Copy with method for creating a new instance with updated fields
  BotUser copyWith({
    int? userId,
    String? name,
    bool? banned,
    bool? blocked,
    bool? hasJoinedChannel,
    bool? hasJoinedGroup,
    int? winnings,
    int? totalSpends,
    int? referredBy,
    DateTime? createdDate,
    bool? isVip,
    DateTime? vipDate,
    String? langCode,
    int? balance,
    bool? isPremium,
  }) => BotUser(
    userId: userId ?? this.userId,
    name: name ?? this.name,
    banned: banned ?? this.banned,
    blocked: blocked ?? this.blocked,
    hasJoinedChannel: hasJoinedChannel ?? this.hasJoinedChannel,
    hasJoinedGroup: hasJoinedGroup ?? this.hasJoinedGroup,
    winnings: winnings ?? this.winnings,
    totalSpends: totalSpends ?? this.totalSpends,
    referredBy: referredBy ?? this.referredBy,
    createdDate: createdDate ?? this.createdDate,
    isVip: isVip ?? this.isVip,
    vipDate: vipDate ?? this.vipDate,
    langCode: langCode ?? this.langCode,
    balance: balance ?? this.balance,
    isPremium: isPremium ?? this.isPremium,
  );

  /// Get the user's language pack.
  Language get lang => Language.of(langCode);
}
