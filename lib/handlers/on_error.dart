import 'dart:developer';

import 'package:televerse/televerse.dart';

import '../consts/consts.dart';
import '../luckeverydaybot.dart';

Future<void> handleError(BotError<Context> err) async {
  try {
    await api.sendMessage(
      DebugGroup.chatId,
      'Error occurred!\n'
      'Is Middleware? ${err.sourceIsMiddleware}\n'
      'Has Context? ${err.ctx != null}\n\n'
      'Chat Info: ```\n${err.ctx?.chat?.toJson()}```\n'
      'From Info: ```\n${err.ctx?.from?.toJson()}```',
      messageThreadId: DebugGroup.threads.logs,
      parseMode: ParseMode.markdown,
    );
    await api.sendMessage(
      DebugGroup.chatId,
      '${err.error}',
      messageThreadId: DebugGroup.threads.logs,
    );
    await api.sendMessage(
      DebugGroup.chatId,
      '```\n${err.stackTrace}```',
      messageThreadId: DebugGroup.threads.logs,
      parseMode: ParseMode.markdown,
    );
  } catch (err, stack) {
    log('Error in error handler', error: err, stackTrace: stack);
  }
}
