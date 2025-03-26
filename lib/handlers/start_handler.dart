import 'dart:developer';
import 'dart:io';
import 'package:televerse/televerse.dart';

import '../consts/strings.dart';
import '../database/user_methods.dart';
import '../extensions/user_ext.dart';
import '../luckeverydaybot.dart';
import 'language_handler.dart';

Future<void> startHandler(Context ctx) async {
  final welcomeImage = InputFile.fromFile(File('assets/welcome.webp'));
  int? referredBy;
  if (ctx.args.isNotEmpty) {
    referredBy = int.tryParse(ctx.args.first);
  }

  // Get the username safely
  final String username = (ctx.from?.firstName ?? 'Winner!').trim();
  var user = await ctx.user;
  if (user == null) {
    languageHandler(ctx).ignore();
    log('Creating user...');
    user = await UserMethods(supabase).createUser(
      userId: ctx.from!.id,
      name: username,
      referralId: referredBy,
      langauge: ctx.from?.languageCode,
    );
    log('User created ${user.userId}!');
    return;
  }

  // Define inline keyboard only once
  final board = InlineKeyboard()
      .add(user.lang.getStarted, CallbackQueryData.getStarted)
      .row()
      .add(user.lang.help, CallbackQueryData.help);

  try {
    // Attempt to send the message with username
    await ctx.replyWithPhoto(
      welcomeImage,
      caption: user.lang.welcomeMessage(username),
      parseMode: ParseMode.html,
      replyMarkup: board,
    );
  } catch (e) {
    // Fallback without username if an error occurs
    await ctx.replyWithPhoto(
      welcomeImage,
      caption: user.lang.welcomeMessage(),
      parseMode: ParseMode.html,
      replyMarkup: board,
    );
  }
}
