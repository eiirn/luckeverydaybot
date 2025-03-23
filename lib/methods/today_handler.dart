import 'dart:developer';
import 'dart:io';

import 'package:televerse/televerse.dart';
import '../database/pool_methods.dart';
import '../extensions/user_ext.dart';
import '../luckeverydaybot.dart';
import '../models/user.dart';

Future<void> todayHandler(Context ctx) async {
  final BotUser? user = ctx.user;

  if (user == null) {
    await ctx.reply('Please start the bot first by sending /start');
    return;
  }

  final poolMethods = PoolMethods(supabase);

  try {
    await ctx.replyWithChatAction(ChatAction.typing);
  } finally {}

  try {
    // Get today's pool stats
    final totalPool = await poolMethods.getTodayPoolTotal();
    final participantCount = await poolMethods.getTodayUniqueUserCount();

    // Calculate prize after commission (assuming 10% fee)
    final prizeAmount = (totalPool * 0.9).toInt();

    // Check if this user has already participated today
    final userEntry = await poolMethods.getUserTodayPoolEntry(user.userId);
    final userContribution = userEntry?.amount ?? 0;

    // Build the message
    final messageBuilder = StringBuffer();

    // Exciting header
    messageBuilder.writeln('🌟 *TODAY\'S LUCKY DRAW* 🌟\n');

    // Handle empty pool case
    if (totalPool == 0 || participantCount == 0) {
      messageBuilder.writeln('💰 *Current Prize Pool: 0 stars*');
      messageBuilder.writeln('👥 *Participants: 0*\n');

      // Add countdown timer info
      final now = DateTime.now().toUtc();
      final drawTime = DateTime.utc(now.year, now.month, now.day, 12); // 12 UTC
      final targetDrawTime =
          now.hour >= 12 ? drawTime.add(const Duration(days: 1)) : drawTime;
      final hoursRemaining = targetDrawTime.difference(now).inHours;
      final minutesRemaining = targetDrawTime.difference(now).inMinutes % 60;

      messageBuilder.writeln(
        '⏰ *Drawing in: ${hoursRemaining}h ${minutesRemaining}m*\n',
      );

      // Special enticing message for empty pool
      messageBuilder.writeln('*🎉 Be the first to join today\'s draw! 🎉*');
      messageBuilder.writeln(
        'The first participant gets the highest chance to win!',
      );
      messageBuilder.writeln(
        'Start with as little as 10 stars and watch the pool grow.\n',
      );
      messageBuilder.writeln(
        'Send /join to be the pioneer of today\'s lucky draw! 🚀',
      );
    } else {
      // Show current pool size in a visually appealing way
      messageBuilder.writeln(
        '💰 *Current Prize Pool: ${prizeAmount.toString()} stars*',
      );
      messageBuilder.writeln(
        '👥 *Participants: ${participantCount.toString()}*\n',
      );

      // Add countdown timer or deadline info
      final now = DateTime.now().toUtc();
      final drawTime = DateTime.utc(now.year, now.month, now.day, 12); // 12 UTC

      // If current time is past 12 UTC, use tomorrow's date
      final targetDrawTime =
          now.hour >= 12 ? drawTime.add(const Duration(days: 1)) : drawTime;

      final hoursRemaining = targetDrawTime.difference(now).inHours;
      final minutesRemaining = targetDrawTime.difference(now).inMinutes % 60;

      messageBuilder.writeln(
        '⏰ *Drawing in: ${hoursRemaining}h ${minutesRemaining}m*\n',
      );

      // Show user's current participation status
      if (userContribution > 0) {
        messageBuilder.writeln(
          '✨ *Your contribution: ${userContribution.toString()} stars*',
        );

        // Encourage them to increase their odds
        messageBuilder.writeln(
          'Want to improve your chances? Send more stars with /join!',
        );
      } else {
        // Enticing message for non-participants
        messageBuilder.writeln('*You haven\'t joined today\'s draw yet!*');
        messageBuilder.writeln(
          'Don\'t miss your chance to win'
          ' ${prizeAmount.toString()} stars! 🎁\n',
        );
        messageBuilder.writeln('Send /join to try your luck today!');
      }
    }
    final photo = InputFile.fromFile(File('assets/today.webp'));
    await ctx.replyWithPhoto(
      photo,
      caption: messageBuilder.toString(),
      parseMode: ParseMode.markdown,
    );
    if (userContribution > 0 && !user.hasJoinedChannel) {
      await ctx.reply(
        'Tip: Join our communities to increase your winning chance even higher.',
        replyMarkup: InlineKeyboard()
            .addUrl('Join Channel', 'https://t.me/luckystareveryday')
            .row()
            .addUrl('Join Chat', 'https://t.me/+oN3UYRdvhHU5MGVh'),
      );
    }
  } catch (error, stack) {
    await ctx.reply(
      'Sorry, there was an issue retrieving today\'s draw information.'
      ' Please try again later.',
    );
    log('Error', error: error, stackTrace: stack, name: 'todayHandler');
  }
}
