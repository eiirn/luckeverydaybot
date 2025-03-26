import 'package:televerse/telegram.dart';
import 'package:televerse/televerse.dart';

import '../consts/strings.dart';
import '../database/pool_methods.dart';
import '../extensions/user_ext.dart';
import '../language/en.dart';
import '../luckeverydaybot.dart';
import '../models/user.dart';
import '../utils/formatting.dart';

/// Handles the /join command which allows users to enter the daily draw
Future<void> joinHandler(Context ctx) async {
  final BotUser? user = await ctx.user;

  // Check if user has an account
  if (user == null) {
    await ctx.reply(en.noAccount);
    return;
  }

  // Create quick-select keyboard with star amounts
  final keyboard =
      Keyboard()
          .texts(['20', '50', '100', '250'])
          .row()
          .texts(['500', '1000', '2000'])
          .row()
          .text(user.lang.customAmount)
          .oneTime()
          .resized();

  // Send exciting prompt message
  await ctx.reply(
    user.lang.joinInfo,
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
      await ctx.reply(user.lang.joinTimedOut);
      return;
    }

    // Handle other failure states
    await ctx.reply(user.lang.somethingWentWrong);
    return;
  }

  // Ensure we have valid conversation data
  if (response is! ConversationSuccess<Context>) {
    await ctx.reply(user.lang.somethingUnexpectedHappened);
    return;
  }

  var responseText = response.data.msg!.text!;

  // Handle custom amount option
  if (responseText == user.lang.customAmount) {
    await ctx.reply(
      user.lang.customAmountPrompt,
      parseMode: ParseMode.markdown,
    );

    // Wait for custom amount
    final customResponse = await conv.waitForTextMessage(
      chatId: ctx.id,
      config: const ConversationConfig(timeout: Duration(minutes: 2)),
    );

    // Handle timeout for custom amount
    if (customResponse is ConversationFailure) {
      await ctx.reply(user.lang.timeoutStringTwo);
      return;
    }

    if (customResponse is! ConversationSuccess<Context>) {
      await ctx.reply(user.lang.somethingWentWrong);
      return;
    }

    responseText = customResponse.data.msg!.text!;
  }

  // Parse and validate star count
  final starCount = int.tryParse(responseText);

  if (starCount == null) {
    await ctx.reply(user.lang.nan);
    return;
  }

  if (starCount < 20 || starCount > 2500) {
    await ctx.reply(user.lang.betweenTwentyAnd2500);
    return;
  }

  // Get current pot size for added excitement
  final todaysPot = await PoolMethods(supabase).getTodayPoolTotal();
  final potDisplay = formatStarAmount(
    todaysPot + starCount,
  ); // Add your stars to show potential pot

  // Send exciting confirmation and invoice
  await ctx.reply(
    user.lang.excitingNews(starCount, potDisplay),
    parseMode: ParseMode.markdown,
  );

  // Send the invoice
  await ctx.sendInvoice(
    title: user.lang.invoiceTitle,
    description: user.lang.invoiceDescription(starCount),
    payload: PayloadData.betPaylod,
    currency: CommonData.currency,
    prices: [LabeledPrice(label: user.lang.invoiceLabel, amount: starCount)],
  );
}
