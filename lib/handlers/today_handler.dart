import 'dart:developer';

import 'package:televerse/televerse.dart';
import '../consts/strings.dart';
import '../database/pool_methods.dart';
import '../extensions/single_where_or_null.dart';
import '../extensions/user_ext.dart';
import '../language/en.dart';
import '../luckeverydaybot.dart';
import '../models/user.dart';

Future<void> todayHandler(Context ctx) async {
  if (ctx.hasCallbackQuery()) {
    ctx.answerCallbackQuery().ignore();
  }
  ctx.replyWithChatAction(ChatAction.typing).ignore();

  final BotUser? user = await ctx.user;

  if (user == null) {
    await ctx.reply(en.noAccount);
    return;
  }

  final poolMethods = PoolMethods(supabase);

  try {
    // Get today's pool stats
    final entries = await poolMethods.getTodayEntries();
    final totalPool = entries.fold(0, (sum, entry) => sum + entry.amount);

    log("We got today's pool.");
    final participantCount = await poolMethods.getTodayUniqueUserCount();
    log("We now have today's number of users.");

    // Calculate prize after commission (15% fee)

    log('💰 Prize Amount is $totalPool');

    // Check if this user has already participated today
    final userEntry = entries.singleWhereOrNull((e) => e.userId == user.userId);
    final userContribution = userEntry?.amount ?? 0;
    log("Fetched users's entry. Contribution: $userContribution");

    // Build the message
    final messageBuilder = StringBuffer();

    // Exciting header
    messageBuilder.writeln(user.lang.todayTitle);

    // Handle empty pool case
    if (totalPool == 0 || participantCount == 0) {
      messageBuilder.writeln(user.lang.todayEmptyPool);
      messageBuilder.writeln(user.lang.todayEmptyPeople);

      // Add countdown timer info
      final now = DateTime.now().toUtc();
      final drawTime = DateTime.utc(
        now.year,
        now.month,
        now.day,
        23,
        59,
      ); // 23:59 UTC
      final targetDrawTime =
          now.hour >= 23 && now.minute >= 59
              ? drawTime.add(const Duration(days: 1))
              : drawTime;
      final timeRemaining = targetDrawTime.difference(now);
      final hoursRemaining = timeRemaining.inHours;
      final minutesRemaining = timeRemaining.inMinutes % 60;

      messageBuilder.writeln(
        user.lang.drawingInTime(hoursRemaining, minutesRemaining),
      );

      // Special enticing message for empty pool
      messageBuilder.writeln(user.lang.beFirstToJoin);
      messageBuilder.writeln(
        '${user.lang.firstParticipantHighestChance} ${user.lang.startWithLittleAsStars}',
      );
      messageBuilder.writeln(user.lang.sendJoinToBePioneer);
    } else {
      // Show current pool size in a visually appealing way
      messageBuilder.writeln(user.lang.currentPrizePool(totalPool));
      messageBuilder.writeln(user.lang.participantCount(participantCount));

      // Add countdown timer or deadline info
      final now = DateTime.now().toUtc();
      final drawTime = DateTime.utc(now.year, now.month, now.day, 12); // 12 UTC

      // If current time is past today's draw time, use tomorrow's draw time
      final targetDrawTime =
          now.isAfter(drawTime)
              ? drawTime.add(const Duration(days: 1))
              : drawTime;

      final hoursRemaining = targetDrawTime.difference(now).inHours;
      final minutesRemaining = targetDrawTime.difference(now).inMinutes % 60;

      messageBuilder.writeln(
        user.lang.drawingInTime(hoursRemaining, minutesRemaining),
      );

      // Show user's current participation status
      if (userContribution > 0) {
        messageBuilder.writeln(user.lang.yourContribution(userContribution));

        // Encourage them to increase their odds
        messageBuilder.writeln(user.lang.improveChances);
      } else {
        // Enticing message for non-participants
        messageBuilder.writeln(
          '${user.lang.notJoinedToday} ${user.lang.dontMissChanceToWin(totalPool)}',
        );
        messageBuilder.writeln(user.lang.sendJoinToTryLuck);
      }
    }
    final photo = InputFile.fromFileId(CommonData.todayPicFileId);
    final keyboard = Keyboard().text('/join').resized().oneTime();
    final msg = await ctx.replyWithPhoto(
      photo,
      caption: messageBuilder.toString(),
      parseMode: ParseMode.markdown,
      replyMarkup: user.totalSpends == 0 ? keyboard : null,
    );

    log('Photo ID: ${msg.photo?.last.fileId}');
    if (userContribution > 0 && !user.hasJoinedChannel) {
      await ctx.reply(
        user.lang.joinCommunitiesTip,
        replyMarkup: InlineKeyboard()
            .addUrl(user.lang.joinChannel, CommonData.channel)
            .row()
            .addUrl(user.lang.joinChat, CommonData.group),
      );
    }
  } catch (error, stack) {
    await ctx.reply(user.lang.todayErrorMessage);
    log('Error', error: error, stackTrace: stack, name: 'todayHandler');
  }
}
