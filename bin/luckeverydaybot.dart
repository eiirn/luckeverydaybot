import 'package:luckeverydaybot/luckeverydaybot.dart';
import 'package:luckeverydaybot/methods/accept_precheck.dart';
import 'package:luckeverydaybot/methods/join_handler.dart';
import 'package:luckeverydaybot/methods/payment_handler.dart';
import 'package:luckeverydaybot/methods/start_handler.dart';
import 'package:luckeverydaybot/methods/today_handler.dart';
import 'package:luckeverydaybot/middlewares/user_getter.dart';
import 'package:luckeverydaybot/scheduled/task.dart';
import 'package:luckeverydaybot/utils/env_reader.dart';

void main(List<String> args) async {
  await EnvReader.initialize();

  // Initialize scheduler
  final scheduler = TaskScheduler(supabase: supabase);
  scheduler.initialize();

  if (args.isNotEmpty && args.first == '--select-winner') {
    await scheduler.runWinnerSelectionManually();
  }

  bot.use(UserGetter());
  bot.command('start', startHandler);
  bot.command('today', todayHandler);
  bot.command('join', joinHandler);
  bot.onPreCheckoutQuery(acceptPrecheckout);
  bot.onSuccessfulPayment(paymentHandler);
  await bot.start();
}
