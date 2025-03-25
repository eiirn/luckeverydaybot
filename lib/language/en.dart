import '../utils/formatting.dart';
import 'language.dart';

/// Default English language pack.
final en = English();

class English extends Language {
  /// Singleton
  factory English() => _instance;

  const English._internal() : super('English 🌐', 'en');

  static const English _instance = English._internal();

  String get welcomeLanguagePrompt =>
      'Welcome to the Cash Splash! 🎁\n\nPlease select your preferred language:';

  @override
  String welcomeMessage([String? name]) => '''
🌟 <b>Welcome to StarLuck Draw${name != null ? ', $name' : ''}!</b> 🌟

Join our daily lucky draw by sending star payments to this bot. Here's how it works:

- Send stars to enter the daily draw
- More stars = higher chance of winning
- Daily winner selected at 12:00 UTC
- Winner receives the prize pool (minus 10-15% fee)

Send your first star payment to join today's draw! Good luck! ✨''';

  @override
  String get noAccount =>
      '🚫 You need an account to join the lucky draw! Send /start to create one.';

  @override
  String get customAmount => 'Custom Amount 💫';

  @override
  String get joinInfo =>
      '✨ *DAILY LUCKY DRAW* ✨\n\n'
      'How many stars would you like to bet today? More stars = higher '
      ' chance to win!\n\n'
      '💰 *Minimum:* 20 Stars\n'
      '💰 *Maximum:* 2500 Stars\n\n'
      'Today\'s pot is growing! Will you be the lucky winner?';

  @override
  String get joinTimedOut =>
      '⏱️ Time\'s up! The lucky draw waits for no one.\n'
      'Send /join again when you\'re ready to try your luck!';

  @override
  String get somethingWentWrong =>
      'Something went wrong. Please try again later.';

  @override
  String get somethingUnexpectedHappened =>
      '🔄 Oops! Something unexpected happened. Please try again.';

  @override
  String get customAmountPrompt =>
      '💫 Enter your custom star amount (20-2500):';

  @override
  String get timeoutStringTwo =>
      '⏱️ Time\'s up! Send /join again when you\'re ready!';

  @override
  String get nan =>
      '❌ That doesn\'t look like a number! Please send /join again and enter a valid amount.';

  @override
  String get betweenTwentyAnd2500 =>
      '❌ Your bet must be between 20 and 2500 stars!\n'
      'Send /join again to place a valid bet.';

  @override
  String excitingNews(int starCount, String potDisplay) =>
      '🌟 *EXCITING NEWS!* 🌟\n\n'
      'You\'re about to join today\'s lucky draw with '
      '*${formatStarAmount(starCount)} stars*!\n\n'
      'The pot is currently at *$potDisplay stars* and growing! 💰\n\n'
      'Complete the star transaction now to secure your chance at winning '
      'the JACKPOT! 🎰';

  @override
  String get invoiceTitle => '🎲 Lucky Draw Entry';

  @override
  String get invoiceLabel => 'Lucky Draw Entry';

  @override
  String invoiceDescription(int starCount) =>
      'Place ${formatStarAmount(starCount)} stars in today\'s lucky draw '
      'for a chance to win big!';

  @override
  String errorRegisteringTransaction(String transactionId) =>
      '⚠️ There was an issue processing your payment. Our team has been notified. Please contact support with ID: $transactionId.';

  @override
  String unknownPayment(int amount) =>
      '✅ Your payment of $amount stars has been recorded, but I\'m not sure what it was for.\n\n'
      'If this was a mistake, please use /refund to request assistance.';

  @override
  String durationTimeString(int hoursRemaining, int minutesRemaining) =>
      '$hoursRemaining hours and $minutesRemaining minutes';

  @override
  String betConfirmation(
    int amount,
    int entryAmount,
    int noOfTransactions,
    String timeString,
  ) =>
      '🎯 *Great bet!* You\'ve added $amount stars to today,\'s draw!\n\n'
      '💰 Your total contribution today: *$entryAmount stars* ($noOfTransactions transactions)\n'
      '⏱ Next draw in: *$timeString*\n\n'
      'The more stars you contribute, the higher your chances of winning! Use /join to place another bet or /today to see today\'s pool.';

  @override
  String get paymentError =>
      '⚠️ There was an issue adding your stars to today\'s draw. Don\'t worry, your payment is safe!\n\n'
      'Our team has been notified. You can try again or contact support if needed.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get help => 'Help';

  @override
  String get todayTitle => '🌟 *TODAY\'S LUCKY DRAW* 🌟\n';

  @override
  String get todayEmptyPool => '💰 *Current Prize Pool: 0 stars*';

  @override
  String get todayEmptyPeople => '👥 *Participants: 0*\n';

  // New entries for todayHandler
  @override
  String currentPrizePool(int amount) =>
      '💰 *Current Prize Pool: $amount stars*';

  @override
  String participantCount(int count) => '👥 *Participants: $count*\n';

  @override
  String drawingInTime(int hours, int minutes) =>
      '⏰ *Drawing in: ${hours}h ${minutes}m*\n';

  @override
  String get beFirstToJoin => '*🎉 Be the first to join today\'s draw! 🎉*';

  @override
  String get firstParticipantHighestChance =>
      'The first participant gets the highest chance to win!';

  @override
  String get startWithLittleAsStars =>
      'Start with as little as 10 stars and watch the pool grow.\n';

  @override
  String get sendJoinToBePioneer =>
      'Send /join to be the pioneer of today\'s lucky draw! 🚀';

  @override
  String yourContribution(int amount) => '✨ *Your contribution: $amount stars*';

  @override
  String get improveChances =>
      'Want to improve your chances? Send more stars with /join!';

  @override
  String get notJoinedToday => '*You haven\'t joined today\'s draw yet!*';

  @override
  String dontMissChanceToWin(int amount) =>
      'Don\'t miss your chance to win $amount stars! 🎁\n';

  @override
  String get sendJoinToTryLuck => 'Send /join to try your luck today!';

  @override
  String get joinCommunitiesTip =>
      'Tip: Join our communities to increase your winning chance even higher.';

  @override
  String get joinChannel => 'Join Channel';

  @override
  String get joinChat => 'Join Chat';

  @override
  String get todayErrorMessage =>
      'Sorry, there was an issue retrieving today\'s draw information. Please try again later.';

  String get noFrom =>
      'Please use me in private chats or please do not use me as anonymous admin.';

  @override
  String languagePrompt(String lang) =>
      'Your current language: $lang\n\nSelect a language:';

  @override
  String languageSetTo(String lang) => 'Language set to $lang';
  @override
  String languageUpdatedTo(String lang) => 'Language updated to $lang';

  @override
  String yourLangUpdated(String lang) =>
      'Your language has been updated to $lang!';

  String get createAccountFirst =>
      'Please use /start to create an account first.';

  @override
  String get updateName => '👤 Update Name';

  @override
  String get vipStatus => '🎖️ VIP Status';

  @override
  String get language => '🌏 Language';

  @override
  String get inviteLink => 'Invite 🔗';

  @override
  String get settingsTitle => 'User Settings';

  @override
  String get nameLabel => 'Name';

  @override
  String get balance => 'Balance';

  @override
  String get stars => 'stars';

  @override
  String get totalWinnings => 'Total Winnings';

  @override
  String get totalSpent => 'Total Spent';

  @override
  String get joinDate => 'Joined On';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get since => 'since';

  @override
  String get referrals => 'Referrals';

  @override
  String get people => 'people';

  @override
  String get tapButtonsBelow =>
      'Tap the buttons below to update your settings:';

  @override
  String get namePrompt =>
      'What can we call you? This will be set as your display name: ';

  @override
  String get nameUpdated => 'Successfully updated your display name.';

  @override
  String get invalidName =>
      'The name you entered is invalid. Please try again with a different name.';

  @override
  String get vipStatusTitle => '🎖️ *VIP STATUS* 🎖️';

  @override
  String vipStatusActive(String? date) =>
      '✅ Your VIP status is *ACTIVE*!\n'
      '${date != null ? 'Expires on: *$date*\n\n' : '\n'}'
      'Benefits:\n'
      '• Higher chance of winning lucky draws\n'
      '• No 5% cut on referral winnings\n'
      '• Special VIP emoji in winners list';

  @override
  String get vipStatusInactive =>
      '❌ You do not have VIP status yet.\n\n'
      'Benefits of VIP:\n'
      '• Higher chance of winning lucky draws\n'
      '• No 5% cut on referral winnings\n'
      '• Special VIP emoji in winners list\n\n'
      'Purchase VIP status for 399 ⭐ (lifetime membership!)';

  @override
  String get activateVip => '⭐ Activate VIP Status (399 ⭐)';

  @override
  String referralStatusInfo(bool hasBeenReferred) =>
      '${hasBeenReferred ? "ℹ️ You joined through a referral link." : ""}\n'
      '${hasBeenReferred ? "If you win, 5% of your prize goes to your referrer." : ""}';

  @override
  String get vipInvoiceTitle => '🎖️ VIP Status Activation';

  @override
  String vipInvoiceDescription(bool hasBeenReferred) {
    const x = 'Activate VIP status: Get higher winning chances';
    return hasBeenReferred
        ? '$x and no 5% referral fee on winnings!'
        : '$x in all daily lucky draws!';
  }

  @override
  String get vipInvoiceLabel => 'VIP Status (Lifetime)';

  @override
  String get activatedVip =>
      '🎖️ *Congratulations!* 🎖️\n\n'
      'Your VIP status has been successfully activated! You now enjoy:\n'
      '• Higher chances of winning in daily draws\n'
      '• No commission on referral winnings\n'
      '• VIP badge in winners list\n\n'
      'Thank you for supporting StarLuck Draw! Good luck in future draws! ✨';
}
