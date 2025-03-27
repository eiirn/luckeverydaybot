import 'package:televerse/televerse.dart';

import '../database/user_methods.dart';
import '../luckeverydaybot.dart';
import '../models/user.dart';

extension UserExt on Context {
  Future<BotUser?> get user async =>
      middlewareStorage['user'] = await UserMethods(
        supabase,
      ).getUserById(from!.id);
}
