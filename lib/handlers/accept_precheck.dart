import 'package:televerse/televerse.dart';

Future<void> acceptPrecheckout(Context ctx) async {
  await ctx.answerPreCheckouQuery(true);
}
