import 'en.dart';

/// Represents the language pack.
abstract class Language {
  factory Language.of(String code) => switch (code) {
    'en' => English(),
    _ => English(),
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

  /// Exciting news generator
  String excitingNews(int starCount, String potDisplay);

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
}
