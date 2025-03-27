import 'dart:developer';

import 'package:televerse/televerse.dart';

import '../../database/user_methods.dart';
import '../../extensions/user_ext.dart';
import '../../language/en.dart';
import '../../luckeverydaybot.dart';
import '../settings_handler.dart';

/// Handles the process of updating a user's name.
///
/// This method is triggered when a user wants to change their name in the bot.
/// It prompts the user for a new name, validates it, and updates it in the database.
Future<void> updateNameHandler(Context ctx) async {
  // Get the user from middleware storage or create a new one
  final user = await ctx.user;
  if (user == null) {
    await ctx.answerCallbackQuery();
    await ctx.reply(en.createAccountFirst);
    return;
  }

  // Confirm callback received
  await ctx.answerCallbackQuery(text: '👍');

  // Edit the message to prompt for a new name
  await ctx.editMessageText(user.lang.namePrompt);

  // Wait for the user's response with the new name
  final response = await conv.waitForTextMessage(
    chatId: ctx.id,
    config: const ConversationConfig(timeout: Duration(minutes: 2)),
  );

  // Handle conversation timeout
  if (response is ConversationFailure) {
    if (response.state == ConversationState.timedOut) {
      await ctx.reply(user.lang.timeoutStringTwo);
      await settingsHandler(ctx, editWithCallback: true);
      return;
    }
  }

  // Handle unexpected conversation failure
  if (response is! ConversationSuccess<Context>) {
    await ctx.reply(user.lang.somethingUnexpectedHappened);
    return;
  }

  // Get the new name from the message
  final text = response.data.msg!.text!.trim();

  // Basic name validation
  if (text.isEmpty || text.length > 50) {
    await ctx.reply(user.lang.invalidName);
    await settingsHandler(ctx);
    return;
  }

  try {
    // Create updated user object with new name
    final updated = user.copyWith(name: text);

    // Update user in the database
    final methods = UserMethods(supabase);
    await methods.updateUser(updated);

    // Update user in middleware storage for subsequent handlers
    ctx.middlewareStorage['user'] = updated;

    // Confirm successful update to user
    await ctx.reply(user.lang.nameUpdated);

    // Return to settings menu
    await settingsHandler(ctx);
  } catch (e, stack) {
    log('Error occurred', error: e, stackTrace: stack, name: 'updateName');
    await ctx.reply(user.lang.somethingWentWrong);
    await settingsHandler(ctx);
  }
}
