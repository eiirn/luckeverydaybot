import 'package:televerse/telegram.dart';
import 'package:televerse/televerse.dart';

import '../consts/consts.dart';
import '../extensions/user_ext.dart';
import '../language/en.dart';
import '../luckeverydaybot.dart';
import '../models/user.dart';

Future<void> invoiceSender(Context ctx, {BotUser? user}) async {
  final responseText = ctx.msg!.text!;

  user ??= await ctx.user;

  if (user == null) {
    await ctx.reply(en.createAccountFirst);
    return;
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

  // Send the invoice
  await ctx.sendInvoice(
    title: user.lang.invoiceTitle,
    description: user.lang.invoiceDescription(starCount),
    payload: PayloadData.betPaylod,
    currency: CommonData.currency,
    prices: [LabeledPrice(label: user.lang.invoiceLabel, amount: starCount)],
  );
}

Future<void> customAmountHandler(Context ctx, {BotUser? user}) async {
  user ??= await ctx.user;
  if (user == null) {
    await ctx.reply(en.noAccount);
    return;
  }

  // Handle custom amount option
  await ctx.reply(user.lang.customAmountPrompt, parseMode: ParseMode.markdown);

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

  await invoiceSender(customResponse.data, user: user);
}
