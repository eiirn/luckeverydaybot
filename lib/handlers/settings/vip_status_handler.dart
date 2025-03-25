import 'package:intl/intl.dart';
import 'package:televerse/telegram.dart';
import 'package:televerse/televerse.dart';

import '../../consts/strings.dart';
import '../../extensions/user_ext.dart';
import '../../language/en.dart';

/// Handles displaying the user's VIP status information
Future<void> vipStatusHandler(Context ctx) async {
  final user = ctx.user;

  if (user == null) {
    if (ctx.hasCallbackQuery()) {
      await ctx.answerCallbackQuery();
    }
    await ctx.reply(en.createAccountFirst);
    return;
  }

  final lang = user.lang;
  final hasBeenReferred = user.referredBy != null;
  final isVip = user.isVip;
  final vipDate = user.vipDate;

  // Format VIP activation date if it exists
  final formattedDate =
      vipDate != null
          ? DateFormat(
            'dd MMM yyyy',
          ).format(vipDate.add(const Duration(days: 365)))
          : null;

  // Create message based on VIP status
  final message =
      StringBuffer()
        ..writeln(lang.vipStatusTitle)
        ..writeln()
        ..writeln(
          isVip ? lang.vipStatusActive(formattedDate) : lang.vipStatusInactive,
        )
        ..writeln()
        ..writeln(lang.referralStatusInfo(hasBeenReferred));

  // Only add the purchase button if user is not VIP
  final replyMarkup =
      isVip
          ? null
          : InlineKeyboard().add(
            lang.activateVip,
            CallbackQueryData.activateVip,
          );

  // Answer callback query if this was triggered by callback
  if (ctx.hasCallbackQuery()) {
    await ctx.answerCallbackQuery(text: '🎖️');
    await ctx.editMessageText(
      message.toString(),
      parseMode: ParseMode.markdown,
      replyMarkup: replyMarkup,
    );
  } else {
    await ctx.reply(
      message.toString(),
      parseMode: ParseMode.markdown,
      replyMarkup: replyMarkup,
    );
  }
}

/// Handles the activation of VIP status by sending an invoice
Future<void> activateVIPStatusHandler(Context ctx) async {
  final user = ctx.user;

  if (user == null) {
    if (ctx.hasCallbackQuery()) {
      await ctx.answerCallbackQuery();
    }
    await ctx.reply(en.createAccountFirst);
    return;
  }

  final lang = user.lang;

  // Answer the callback query to acknowledge the button press
  if (ctx.hasCallbackQuery()) {
    ctx.answerCallbackQuery().ignore();
    ctx.deleteMessage().ignore();
  }

  // Send the invoice for VIP status
  await ctx.sendInvoice(
    title: lang.vipInvoiceTitle,
    description: lang.vipInvoiceDescription(user.referredBy != null),
    payload: PayloadData.vipPayload,
    currency: CommonData.currency,
    prices: [LabeledPrice(label: lang.vipInvoiceLabel, amount: 10)],
  );
}
