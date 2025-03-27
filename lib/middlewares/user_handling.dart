import 'dart:developer';

import 'package:televerse/televerse.dart';
import '../database/user_methods.dart';
import '../language/en.dart';
import '../luckeverydaybot.dart';
import '../models/user.dart';

/// This middleware requires `from` to be present, and after processing the handler, it will update the Telegram premium status.
class UserMiddleware implements Middleware {
  @override
  Future<void> handle(Context ctx, NextFunction next) async {
    final from = ctx.from?.id;

    if (from == null) {
      await ctx.reply(en.noFrom);
      return;
    }

    await next();

    final user = ctx.middlewareStorage['user'] as BotUser?;
    if (user == null) {
      return;
    }
    log('We have user here.');
    if (user.isPremium != (ctx.from!.isPremium ?? false)) {
      await UserMethods(
        supabase,
      ).updateUser(user.copyWith(isPremium: ctx.from?.isPremium ?? false));
      log('Updated Telegram premium status');
    }
  }
}
