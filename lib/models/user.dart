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
    this.langCode = 'none',
    this.balance = 0,
    this.isPremium = false,
    this.language,
    this.totalReferrals = 0,
    DateTime? updatedAt,
  }) : createdDate = createdDate ?? DateTime.now().toUtc(),
       updatedAt = updatedAt ?? DateTime.now().toUtc();

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
    language: json['language'] as String?,
    totalReferrals: json['total_referrals'] as int? ?? 0,
    updatedAt:
        json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
  );

  /// The Telegram User ID of the user.
  final int userId;

  /// Name of the user.
  final String name;

  /// Whether the user has been banned to use the bot.
  bool banned;

  /// Whether the user has blocked the bot.
  bool blocked;

  /// Whether teh user has joined the channel
  bool hasJoinedChannel;

  /// Whether the user has joined the group
  bool hasJoinedGroup;

  /// The total number of star won by the user
  int winnings;

  /// Total number of star the uesr has put into daily draws
  int totalSpends;

  /// The user id of the uesr who referred this user.
  int? referredBy;

  /// The date at which the user created their account
  DateTime createdDate;

  /// Whether teh user is a VIP user.
  bool isVip;

  /// The date at which the user has enabled VIP status.
  ///
  /// When present, the VIP status will expire after 365 days after this date.
  /// If null && isVip, user has lifetime access to VIP status.
  DateTime? vipDate;

  /// In bot language code
  String langCode;

  /// Balance that we should return the user sometime
  final int balance;

  /// Whether user has Telegram Premium
  final bool isPremium;

  /// Telegram langauge code of the user (just for analytics)
  final String? language;

  /// Total referrals
  final int totalReferrals;

  /// Last updated
  final DateTime updatedAt;

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
    'language': language,
    'total_referrals': totalReferrals,
    'updated_at': updatedAt.toIso8601String(),
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
    String? language,
    int? totalReferrals,
    DateTime? updatedAt,
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
    language: language ?? this.language,
    totalReferrals: totalReferrals ?? this.totalReferrals,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  /// Get the user's language pack.
  Language get lang => Language.of(langCode);
}
