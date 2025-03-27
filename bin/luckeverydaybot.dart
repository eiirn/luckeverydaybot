import 'dart:developer';
import 'dart:io';

import 'package:luckeverydaybot/consts/consts.dart';
import 'package:luckeverydaybot/handlers/accept_precheck.dart';
import 'package:luckeverydaybot/handlers/chat_member_handler.dart';
import 'package:luckeverydaybot/handlers/help_handler.dart';
import 'package:luckeverydaybot/handlers/invoice_sender.dart';
import 'package:luckeverydaybot/handlers/join_handler.dart';
import 'package:luckeverydaybot/handlers/language_handler.dart';
import 'package:luckeverydaybot/handlers/on_error.dart';
import 'package:luckeverydaybot/handlers/payment_handler.dart';
import 'package:luckeverydaybot/handlers/privacy_handler.dart';
import 'package:luckeverydaybot/handlers/settings/invite_handler.dart';
import 'package:luckeverydaybot/handlers/settings/update_name.dart';
import 'package:luckeverydaybot/handlers/settings/vip_status_handler.dart';
import 'package:luckeverydaybot/handlers/settings_handler.dart';
import 'package:luckeverydaybot/handlers/start_handler.dart';
import 'package:luckeverydaybot/handlers/today_handler.dart';
import 'package:luckeverydaybot/luckeverydaybot.dart';
import 'package:luckeverydaybot/middlewares/user_handling.dart';
import 'package:luckeverydaybot/scheduled/task.dart';
import 'package:luckeverydaybot/utils/env_reader.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

void main(List<String> args) async {
  await EnvReader.initialize();
  // Config and start server.
  final app = initBot();

  // Initialize scheduler
  final scheduler = TaskScheduler(supabase: supabase);
  scheduler.initialize();

  if (args.isNotEmpty && args.first == '--select-winner') {
    await scheduler.runWinnerSelectionManually();
  }

  bot.use(UserMiddleware());
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
  bot.callbackQuery(CallbackQueryData.language, languageHandler);
  bot.callbackQuery(CallbackQueryData.invite, inviteHandler);
  bot.command('privacy', privacyHandler);
  bot.command('terms', termsHandler);
  bot.command('help', helpHandler);
  bot.callbackQuery(CallbackQueryData.help, helpHandler);
  bot.onMyChatMember(myChatMemberHandler);
  bot.onChatMember(chatMemberHandler);
  bot.hears(CommonData.oneTo2500Exp, invoiceSender);
  bot.onError(handleError);
  bot.command('invite', inviteHandler);

  final pipeline = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(app.call);

  final addr = InternetAddress.anyIPv4;
  final server = await shelf_io.serve(pipeline, addr, 8081);

  log('Server running on port ${server.port}');

  await bot.start();
}
