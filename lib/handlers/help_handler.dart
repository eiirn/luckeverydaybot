import 'package:televerse/televerse.dart';

import '../extensions/user_ext.dart';
import '../language/en.dart';

Future<void> helpHandler(Context ctx) async {
  if (ctx.hasCallbackQuery()) {
    ctx.answerCallbackQuery().ignore();
  }
  final lang = (await ctx.user)?.lang ?? en;

  await ctx.reply(lang.helpMessage, parseMode: ParseMode.markdown);
}
