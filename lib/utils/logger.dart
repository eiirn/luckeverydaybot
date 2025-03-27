import 'dart:developer' as dev;
import 'package:televerse/televerse.dart';

import '../consts/consts.dart';
import '../luckeverydaybot.dart';

class BotLogger {
  const BotLogger._();
  static Future<void> log(
    Object? obj, {
    Object? error,
    StackTrace? stackTrace,
    int? thread,
    InlineKeyboard? board,
  }) async {
    dev.log('$obj', error: error, stackTrace: stackTrace);
    try {
      await api.sendMessage(
        DebugGroup.chatId,
        '$obj',
        parseMode: ParseMode.markdown,
        messageThreadId: thread ?? DebugGroup.threads.logs,
        replyMarkup: board,
      );
      if (error != null) {
        await api.sendMessage(
          DebugGroup.chatId,
          '$error',
          parseMode: ParseMode.markdown,
          messageThreadId: thread ?? DebugGroup.threads.logs,
        );
      }
      if (stackTrace != null) {
        await api.sendMessage(
          DebugGroup.chatId,
          '```\n$stackTrace```',
          parseMode: ParseMode.markdown,
          messageThreadId: thread ?? DebugGroup.threads.logs,
        );
      }
    } catch (_) {}
  }
}
