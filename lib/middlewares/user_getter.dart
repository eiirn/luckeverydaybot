import 'package:televerse/televerse.dart';

import '../database/user_methods.dart';
import '../language/en.dart';
import '../luckeverydaybot.dart';

class UserGetter implements Middleware {
  @override
  Future<void> handle(Context ctx, NextFunction next) async {
    final from = ctx.from?.id;

    if (from == null) {
      await ctx.reply(en.noFrom);
      return;
    }

    final user = await UserMethods(supabase).getUserById(from);
    ctx.middlewareStorage['user'] = user;
    return next();
  }
}
