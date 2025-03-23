import 'package:televerse/telegram.dart';
import 'package:televerse/televerse.dart';

import '../database/pool_methods.dart';
import '../extensions/user_ext.dart';
import '../luckeverydaybot.dart';
import '../models/user.dart';
import '../utils/formatting.dart';

/// Handles the /join command which allows users to enter the daily draw
Future<void> joinHandler(Context ctx) async {
  final BotUser? user = ctx.user;

  // Check if user has an account
  if (user == null) {
    await ctx.reply(
      '🚫 You need an account to join the lucky draw! Send /start to create one.',
    );
    return;
  }

  // Create quick-select keyboard with star amounts
  final keyboard =
      Keyboard()
          .texts(['20', '50', '100', '250'])
          .row()
          .texts(['500', '1000', '2000'])
          .row()
          .text('Custom Amount 💫')
          .oneTime()
          .resized();

  // Send exciting prompt message
  await ctx.reply(
    '✨ *DAILY LUCKY DRAW* ✨\n\n'
    'How many stars would you like to bet today? More stars = higher '
    ' chance to win!\n\n'
    '💰 *Minimum:* 20 Stars\n'
    '💰 *Maximum:* 2500 Stars\n\n'
    'Today\'s pot is growing! Will you be the lucky winner?',
    parseMode: ParseMode.markdown,
    replyMarkup: keyboard,
  );

  // Wait for user response
  final response = await conv.waitForTextMessage(
    chatId: ctx.id,
    config: const ConversationConfig(timeout: Duration(minutes: 2)),
  );

  // Handle conversation timeout
  if (response is ConversationFailure) {
    if (response.state == ConversationState.timedOut) {
      await ctx.reply(
        '⏱️ Time\'s up! The lucky draw waits for no one.\n'
        'Send /join again when you\'re ready to try your luck!',
      );
      return;
    }

    // Handle other failure states
    await ctx.reply('Something went wrong. Please try again later.');
    return;
  }

  // Ensure we have valid conversation data
  if (response is! ConversationSuccess<Context>) {
    await ctx.reply(
      '🔄 Oops! Something unexpected happened. Please try again.',
    );
    return;
  }

  var responseText = response.data.msg!.text!;

  // Handle custom amount option
  if (responseText == 'Custom Amount 💫') {
    await ctx.reply(
      '💫 Enter your custom star amount (20-2500):',
      parseMode: ParseMode.markdown,
    );

    // Wait for custom amount
    final customResponse = await conv.waitForTextMessage(
      chatId: ctx.id,
      config: const ConversationConfig(timeout: Duration(minutes: 2)),
    );

    // Handle timeout for custom amount
    if (customResponse is ConversationFailure) {
      await ctx.reply('⏱️ Time\'s up! Send /join again when you\'re ready!');
      return;
    }

    if (customResponse is! ConversationSuccess<Context>) {
      await ctx.reply('🔄 Something went wrong. Please try again.');
      return;
    }

    responseText = customResponse.data.msg!.text!;
  }

  // Parse and validate star count
  final starCount = int.tryParse(responseText);

  if (starCount == null) {
    await ctx.reply(
      '❌ That doesn\'t look like a number! Please send /join again and enter a valid amount.',
    );
    return;
  }

  if (starCount < 20 || starCount > 2500) {
    await ctx.reply(
      '❌ Your bet must be between 20 and 2500 stars!\n'
      'Send /join again to place a valid bet.',
    );
    return;
  }

  // Get current pot size for added excitement
  final todaysPot = await PoolMethods(supabase).getTodayPoolTotal();
  final potDisplay = formatStarAmount(
    todaysPot + starCount,
  ); // Add your stars to show potential pot

  // Send exciting confirmation and invoice
  await ctx.reply(
    '🌟 *EXCITING NEWS!* 🌟\n\n'
    'You\'re about to join today\'s lucky draw with '
    '*${formatStarAmount(starCount)} stars*!\n\n'
    'The pot is currently at *$potDisplay stars* and growing! 💰\n\n'
    'Complete the star transaction now to secure your chance at winning '
    'the JACKPOT! 🎰',
    parseMode: ParseMode.markdown,
  );

  // Generate a unique payload for this transaction
  final transactionPayload =
      'draw-bet-${user.userId}-${DateTime.now().millisecondsSinceEpoch}';

  // Send the invoice
  await ctx.sendInvoice(
    title: '🎲 Lucky Draw Entry',
    description:
        'Place ${formatStarAmount(starCount)} stars in today\'s lucky draw '
        'for a chance to win big!',
    payload: transactionPayload,
    currency: 'XTR',
    prices: [LabeledPrice(label: 'Lucky Draw Entry', amount: starCount)],
  );
}
