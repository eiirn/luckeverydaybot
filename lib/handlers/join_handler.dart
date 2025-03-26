import 'package:televerse/televerse.dart';
import '../extensions/user_ext.dart';
import '../language/en.dart';
import '../luckeverydaybot.dart';
import '../models/user.dart';
import 'invoice_sender.dart';

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

  final responseText = response.data.msg!.text!;

  if (responseText != user.lang.customAmount) {
    await invoiceSender(response.data);
    return;
  }

  await customAmountHandler(ctx, user: user);
}
