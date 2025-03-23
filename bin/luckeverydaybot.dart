import 'package:luckeverydaybot/luckeverydaybot.dart';
import 'package:luckeverydaybot/methods/join_handler.dart';
import 'package:luckeverydaybot/methods/start_handler.dart';
import 'package:luckeverydaybot/methods/today_handler.dart';
import 'package:luckeverydaybot/middlewares/user_getter.dart';
import 'package:luckeverydaybot/utils/env_reader.dart';

void main(List<String> args) async {
  await EnvReader.initialize();

  bot.use(UserGetter());
  bot.command('start', startHandler);
  bot.command('today', todayHandler);
  bot.command('join', joinHandler);
  await bot.start();
}
