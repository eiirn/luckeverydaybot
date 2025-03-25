import 'package:luckeverydaybot/consts/strings.dart';
import 'package:luckeverydaybot/handlers/accept_precheck.dart';
import 'package:luckeverydaybot/handlers/join_handler.dart';
import 'package:luckeverydaybot/handlers/language_handler.dart';
import 'package:luckeverydaybot/handlers/payment_handler.dart';
import 'package:luckeverydaybot/handlers/settings/update_name.dart';
import 'package:luckeverydaybot/handlers/settings/vip_status_handler.dart';
import 'package:luckeverydaybot/handlers/settings_handler.dart';
import 'package:luckeverydaybot/handlers/start_handler.dart';
import 'package:luckeverydaybot/handlers/today_handler.dart';
import 'package:luckeverydaybot/luckeverydaybot.dart';
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
  bot.callbackQuery(CallbackQueryData.languageExp, setLanguageHandler);
  bot.command('start', startHandler);
  bot.command('today', todayHandler);
  bot.command('join', joinHandler);
  bot.command('language', languageHandler);
  bot.onPreCheckoutQuery(acceptPrecheckout);
  bot.onSuccessfulPayment(paymentHandler);
  bot.callbackQuery(CallbackQueryData.getStarted, todayHandler);
  bot.command('settings', settingsHandler);
  bot.callbackQuery(CallbackQueryData.updateName, updateNameHandler);
  bot.callbackQuery(CallbackQueryData.vipStatus, vipStatusHandler);
  bot.callbackQuery(CallbackQueryData.activateVip, activateVIPStatusHandler);

  await bot.start();
}
