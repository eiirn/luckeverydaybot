import 'en.dart';
import 'ru.dart';

/// Represents the language pack.
abstract class Language {
  const Language(this.name, this.code);

  factory Language.of(String code) => switch (code) {
    'en' => en,
    'ru' => ru,
    _ => en,
  };
  final String name;
  final String code;

  static List<Language> availableLanguages() => [en, ru];
  static Map<String, Language> languageMap = {
    for (final lang in availableLanguages()) lang.code: lang,
  };

  /// Welcome message
  String welcomeMessage([String? name]);

  /// You need an account to continue
  String get noAccount;

  /// Custom Amount
  String get customAmount;

  /// Daily lucky draw info
  String get joinInfo;

  /// Join timed out
  String get joinTimedOut;

  /// Something went wrong.
  String get somethingWentWrong;

  /// Something unexpected happened.
  String get somethingUnexpectedHappened;

  /// Custom Amount prompt
  String get customAmountPrompt;

  /// Another timeout string.
  String get timeoutStringTwo;

  /// Error. Not a Number.
  String get nan;

  /// Bet must be between 20-2500
  String get betweenTwentyAnd2500;

  /// Invoice title
  String get invoiceTitle;

  /// Invoice label text
  String get invoiceLabel;

  /// Invoice description generator.
  String invoiceDescription(int starCount);

  /// Error while registering transaction
  String errorRegisteringTransaction(String transactionId);

  /// When we couldn't figure out why user made a payment.
  String unknownPayment(int amount);

  /// Generates 1 hours and 10 minutes kinda text
  String durationTimeString(int hoursRemaining, int minutesRemaining);

  /// The confirmation string to be shown after payment.
  String betConfirmation(
    int amount,
    int entryAmount,
    int noOfTransactions,
    String timeString,
  );

  /// Error in payment.
  String get paymentError;

  /// Get Started
  String get getStarted;

  /// Help
  String get help;

  /// Today's title.
  String get todayTitle;

  /// Today's Empty Pool
  String get todayEmptyPool;

  /// Today's empty participants
  String get todayEmptyPeople;

  /// Current prize pool display with amount
  String currentPrizePool(int amount);

  /// Participant count display
  String participantCount(int count);

  /// Drawing countdown timer display
  String drawingInTime(int hours, int minutes);

  /// Encouragement to be the first to join today's draw
  String get beFirstToJoin;

  /// Message explaining first participant advantage
  String get firstParticipantHighestChance;

  /// Message about minimum entry amount
  String get startWithLittleAsStars;

  /// Call to action to join the draw
  String get sendJoinToBePioneer;

  /// User's current contribution display
  String yourContribution(int amount);

  /// Message encouraging user to increase their chances
  String get improveChances;

  /// Message when user hasn't joined today's draw yet
  String get notJoinedToday;

  /// Message about not missing chance to win specific amount
  String dontMissChanceToWin(int amount);

  /// Call to action to try luck today
  String get sendJoinToTryLuck;

  /// Tip about joining communities
  String get joinCommunitiesTip;

  /// Join channel button text
  String get joinChannel;

  /// Join chat button text
  String get joinChat;

  /// Error message when retrieving today's draw information fails
  String get todayErrorMessage;

  /// Prompt to change current language
  String languagePrompt(String lang);

  /// Language set to text
  String languageSetTo(String lang);

  /// Language updated to text
  String languageUpdatedTo(String lang);

  /// Your language has been updated to text
  String yourLangUpdated(String lang);

  /// Update name (in settings)
  String get updateName;

  /// Vip Status in settings
  String get vipStatus;

  /// Language button title in settings.
  String get language;

  /// Invite link button title
  String get inviteLink;

  /// Settings page title
  String get settingsTitle;

  /// Name label
  String get nameLabel;

  /// Balance label
  String get balance;

  /// Stars (currency unit)
  String get stars;

  /// Total winnings label
  String get totalWinnings;

  /// Total spent label
  String get totalSpent;

  /// Account join date label
  String get joinDate;

  /// Active status text
  String get active;

  /// Inactive status text
  String get inactive;

  /// "Since" text for dates
  String get since;

  /// Referrals label
  String get referrals;

  /// "People" text
  String get people;

  /// Instructional text to tap buttons
  String get tapButtonsBelow;

  /// Prompt for update name
  String get namePrompt;

  /// Message to be sent after updating name.
  String get nameUpdated;

  /// Invalid name
  String get invalidName;

  /// VIP Status title
  String get vipStatusTitle;

  /// Active VIP status message
  String vipStatusActive(String? date);

  /// Inactive VIP status message
  String get vipStatusInactive;

  /// Activate VIP button text
  String get activateVip;

  /// Referral status info
  String referralStatusInfo(bool hasBeenReferred);

  /// VIP status purchase invoice title
  String get vipInvoiceTitle;

  /// VIP status purchase invoice description
  String vipInvoiceDescription(bool hasBeenReferred);

  /// VIP status purchase invoice label
  String get vipInvoiceLabel;

  /// Activated VIP status
  String get activatedVip;

  /// Invite feature title
  String get inviteTitle;

  /// Invite description text
  String get inviteDescription;

  /// Referral count message
  String referralCount(int count);

  /// Tap to copy invite link message
  String get tapToCopyInviteLink;

  /// Tap to copy button title
  String get linkTapCopyButtonTitle;

  /// Privacy Policy
  String get privacyPolicy;

  /// Terms and conditions
  String get termsAndConditions;

  /// The help message
  String get helpMessage;

  /// Thanks for joining chat
  String get thanksForJoiningChat;

  /// Thanks for joining channel
  String get thanksForJoiningChannel;

  /// Retention notification message
  String getInactivityReminderMessage(bool hasPlayedBefore);

  /// Only player, refund statement
  String get onlyOnePlayer;
}
