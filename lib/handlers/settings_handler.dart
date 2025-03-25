import 'package:televerse/televerse.dart';

import '../consts/strings.dart';
import '../database/user_methods.dart';
import '../extensions/user_ext.dart';
import '../language/en.dart';
import '../luckeverydaybot.dart';

/// The /settings command handler
Future<void> settingsHandler(
  Context ctx, {
  bool editWithCallback = false,
}) async {
  final user = ctx.user;

  if (user == null) {
    await ctx.reply(en.createAccountFirst);
    return;
  }

  final userMethods = UserMethods(supabase);
  final count = await userMethods.getNumberOfReferredUsers(user.userId);
  final totalWinning = user.winnings;
  final totalStarsSpent = user.totalSpends;

  // Format join dates and VIP status display
  final joinDate = user.createdDate.toLocal().toString().split(' ')[0];
  final vipStatus =
      user.isVip ? '✅ ${user.lang.active}' : '❌ ${user.lang.inactive}';
  final vipDateInfo =
      user.vipDate != null
          ? '(${user.lang.since} ${user.vipDate!.toLocal().toString().split(' ')[0]})'
          : '';

  // Build settings message
  final message = '''
⚙️ *${user.lang.settingsTitle}*

*${user.lang.nameLabel}:* ${user.name} ${user.isVip ? '🎖️' : ''}

*${user.lang.balance}:* ${user.balance} ${user.lang.stars}
*${user.lang.totalWinnings}:* $totalWinning ${user.lang.stars}
*${user.lang.totalSpent}:* $totalStarsSpent ${user.lang.stars}
*${user.lang.joinDate}:* $joinDate

*${user.lang.vipStatus}:* $vipStatus $vipDateInfo

*${user.lang.referrals}:* $count ${user.lang.people}
*${user.lang.language}:* ${user.langCode.toUpperCase()}

${user.lang.tapButtonsBelow}
''';

  var keyboard =
      InlineKeyboard()
          .add(user.lang.updateName, CallbackQueryData.updateName)
          .row()
          .add(user.lang.vipStatus, CallbackQueryData.vipStatus)
          .row()
          .add(user.lang.language, CallbackQueryData.language)
          .row()
          .copyText(
            user.lang.inviteLink,
            copyText: 'https://t.me/${ctx.me.username}?start=${user.userId}',
          )
          .row();

  if (!user.hasJoinedChannel) {
    keyboard = keyboard.addUrl(user.lang.joinChannel, CommonData.channel);
  }
  if (!user.hasJoinedGroup) {
    keyboard = keyboard.addUrl(user.lang.joinChat, CommonData.group);
  }

  if (editWithCallback) {
    await ctx.editMessageText(
      message,
      parseMode: ParseMode.markdown,
      replyMarkup: keyboard,
    );
  } else {
    // Send the settings message with the inline keyboard
    await ctx.reply(
      message,
      parseMode: ParseMode.markdown,
      replyMarkup: keyboard,
    );
  }
}
