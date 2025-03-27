import 'package:televerse/televerse.dart';

import '../extensions/user_ext.dart';
import '../language/en.dart';

Future<void> privacyHandler(Context ctx) async {
  final lang = (await ctx.user)?.lang ?? en;

  await ctx.reply(lang.privacyPolicy, parseMode: ParseMode.html);
}

Future<void> termsHandler(Context ctx) async {
  final lang = (await ctx.user)?.lang ?? en;

  await ctx.reply(lang.termsAndConditions, parseMode: ParseMode.html);
}
