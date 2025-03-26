import 'package:televerse/televerse.dart';
import '../language/en.dart';

class UserGetter implements Middleware {
  @override
  Future<void> handle(Context ctx, NextFunction next) async {
    final from = ctx.from?.id;

    if (from == null) {
      await ctx.reply(en.noFrom);
      return;
    }

    return next();
  }
}
