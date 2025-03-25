import 'package:televerse/televerse.dart';

import '../extensions/user_ext.dart';
import '../language/en.dart';

Future<void> helpHandler(Context ctx) async {
  final lang = ctx.user?.lang ?? en;

  await ctx.reply(lang.helpMessage, parseMode: ParseMode.markdown);
}
