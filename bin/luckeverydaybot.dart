import 'package:luckeverydaybot/luckeverydaybot.dart';
import 'package:luckeverydaybot/methods/start_handler.dart';
import 'package:luckeverydaybot/middlewares/user_getter.dart';
import 'package:luckeverydaybot/utils/env_reader.dart';

void main(List<String> args) async {
  await EnvReader.initialize();

  bot.use(UserGetter());
  bot.command('start', startHandler);
  await bot.start();
}
