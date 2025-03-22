import 'dart:developer';
import 'dart:io';
import 'package:televerse/televerse.dart';

import '../database/user_methods.dart';
import '../extensions/user_ext.dart';
import '../luckeverydaybot.dart';
import '../utils/welcome.dart';

Future<void> startHandler(Context ctx) async {
  final welcomeImage = InputFile.fromFile(File('assets/welcome.webp'));
  int? referredBy;
  if (ctx.args.isNotEmpty) {
    referredBy = int.tryParse(ctx.args.first);
  }

  // Get the username safely
  final String username = (ctx.from?.firstName ?? 'there').trim();
  var user = ctx.user;
  if (user != null) {
    log('We have a user here');
  } else {
    user = await UserMethods(
      supabase,
    ).createUser(userId: ctx.from!.id, name: username, referralId: referredBy);
    log('User created');
  }

  // Define inline keyboard only once
  final board = InlineKeyboard()
      .add('Get Started', 'get-started')
      .row()
      .add('Help', 'help');

  try {
    // Attempt to send the message with username
    await ctx.replyWithPhoto(
      welcomeImage,
      caption: generateWelcomeMessage(username),
      parseMode: ParseMode.html,
      replyMarkup: board,
    );
  } catch (e) {
    // Fallback without username if an error occurs
    await ctx.replyWithPhoto(
      welcomeImage,
      caption: generateWelcomeMessage(),
      parseMode: ParseMode.html,
      replyMarkup: board,
    );
  }
}
