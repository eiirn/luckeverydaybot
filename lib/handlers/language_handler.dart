import 'dart:developer';

import 'package:televerse/televerse.dart';
import '../database/user_methods.dart';
import '../extensions/user_ext.dart';
import '../language/en.dart';
import '../language/language.dart';
import '../luckeverydaybot.dart';
import '../models/user.dart';
import 'start_handler.dart';

/// Handles language selection for users
Future<void> languageHandler(Context ctx) async {
  final BotUser? user = await ctx.user;

  // Create a dynamic keyboard based on available languages
  var keyboard = InlineKeyboard();

  // Get all available languages
  final availableLanguages = Language.availableLanguages();

  // For existing users, we'll mark their current language
  String prompt;

  if (user == null || user.langCode == 'none') {
    prompt = en.welcomeLanguagePrompt;
  } else {
    // Existing user, show their current language selection
    prompt = user.lang.languagePrompt(
      Language.languageMap[user.langCode]?.name ?? 'Unknown',
    );
  }

  // Build keyboard with all available languages
  for (final lang in availableLanguages) {
    // Format language display text (add marker for current language)
    String langText = lang.name;

    // Mark the currently selected language (if user exists)
    if (user != null && user.langCode == lang.code) {
      langText += ' 🔘';
    }

    // Add language button to keyboard
    keyboard = keyboard.add(langText, 'lang-${lang.code}');
  }

  if (ctx.hasCallbackQuery()) {
    ctx.answerCallbackQuery().ignore();
    await ctx.editMessageText(prompt, replyMarkup: keyboard);
  } else {
    // Send the message with language selection keyboard
    await ctx.reply(prompt, replyMarkup: keyboard);
  }
}

Future<void> setLanguageHandler(Context ctx) async {
  final user = await ctx.user;

  if (user == null) {
    // This is unexpected, but handle it gracefully
    await ctx.answerCallbackQuery(text: en.createAccountFirst);
    return;
  }

  // Extract the language code from the callback data
  // Callback data format is expected to be 'lang-{code}' (e.g., 'lang-en')
  final callbackData = ctx.callbackQuery?.data;
  if (callbackData == null || !callbackData.startsWith('lang-')) {
    await ctx.answerCallbackQuery(text: 'Invalid language selection');
    return;
  }

  // Extract the language code from the callback data
  final langCode = callbackData.substring(5); // Remove 'lang-' prefix

  // Check if it's a valid language code
  if (!Language.languageMap.containsKey(langCode)) {
    await ctx.answerCallbackQuery(text: 'Unsupported language');
    return;
  }

  // Get the language name for display
  final language = Language.languageMap[langCode]!;

  try {
    // Create updated user with the new language code
    final updatedUser = user.copyWith(langCode: langCode);

    // Update the user in the database
    // NOTE: You'll need to replace this with how your application accesses UserMethods
    // This could be through ctx.bot.database, an extension method, or dependency injection

    // REPLACE THIS LINE with your application's way to access UserMethods
    await UserMethods(supabase).updateUser(updatedUser);

    // If it's a new user (langCode was 'none')
    if (user.langCode == 'none') {
      // Answer the callback query
      await ctx.answerCallbackQuery(
        text: language.languageSetTo(language.name),
      );

      // Edit the original message to confirm language selection
      await ctx.editMessageText(language.languageSetTo(language.name));

      await startHandler(ctx);

      await Future.delayed(const Duration(milliseconds: 1500));
      await ctx.deleteMessage();
    } else {
      // Existing user changing language preference
      await ctx.answerCallbackQuery(
        text: language.languageUpdatedTo(language.name),
      );

      // Edit the original message to confirm language update
      await ctx.editMessageText(language.yourLangUpdated(language.name));
    }
  } catch (e, stack) {
    log('Error', error: e, stackTrace: stack, name: 'setLanguageHandler');
    // Handle errors gracefully
    await ctx.answerCallbackQuery(text: 'Failed to update language');
    await ctx.reply(user.lang.somethingWentWrong);
  }
}
