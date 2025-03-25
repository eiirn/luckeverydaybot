import 'package:televerse/televerse.dart';

import '../../extensions/user_ext.dart';
import '../../language/en.dart';

Future<void> inviteHandler(Context ctx) async {
  final user = ctx.user;
  if (user == null) {
    await ctx.reply(en.createAccountFirst);
    return;
  }

  final lang = user.lang;
  final count = user.totalReferrals;

  final inviteLink = 'https://t.me/${ctx.me.username}?start=${user.userId}';

  final message =
      StringBuffer()
        ..writeln(lang.inviteTitle)
        ..writeln()
        ..writeln(lang.inviteDescription)
        ..writeln()
        ..writeln(lang.referralCount(count))
        ..writeln()
        ..writeln(lang.tapToCopyInviteLink);

  final board = InlineKeyboard().copyText(
    lang.linkTapCopyButtonTitle,
    copyText: inviteLink,
  );

  if (ctx.hasCallbackQuery()) {
    ctx.answerCallbackQuery().ignore();
    await ctx.editMessageText(
      message.toString(),
      parseMode: ParseMode.markdown,
      replyMarkup: board,
    );
  } else {
    await ctx.reply(
      message.toString(),
      parseMode: ParseMode.markdown,
      replyMarkup: board,
    );
  }
}
