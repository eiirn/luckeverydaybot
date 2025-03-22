import 'package:televerse/televerse.dart';

import '../models/user.dart';

extension UserExt on Context {
  BotUser? get user => middlewareStorage['user'] as BotUser?;
}
