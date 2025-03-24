import 'dart:developer';

import 'package:televerse/telegram.dart';
import 'package:televerse/televerse.dart';
import '../database/pool_methods.dart';
import '../database/transaction_methods.dart';
import '../extensions/user_ext.dart';
import '../luckeverydaybot.dart';
import '../models/transaction.dart';
import '../models/user.dart';

/// A handler that processes star transactions made by users.
///
/// This handler records all transactions, validates users, and processes
/// payments based on their payload type. For draw-bet payments, it updates
/// the user's pool entry for the day's lucky draw.
Future<void> paymentHandler(Context ctx) async {
  final successfulPayment = ctx.msg?.successfulPayment;

  // Validate payment data
  if (successfulPayment == null) {
    return;
  }

  final userId = ctx.from?.id ?? 0;
  if (userId == 0) {
    return;
  }

  // Create transaction record
  final transaction = Transaction(
    transactionId: successfulPayment.telegramPaymentChargeId,
    userId: userId,
    amount: successfulPayment.totalAmount,
    type: 'deposit',
    invoicePayload: successfulPayment.invoicePayload,
  );

  // Record the transaction regardless of further processing
  try {
    await TransactionMethods(supabase).addTransaction(transaction);
  } catch (e) {
    await ctx.reply(
      '⚠️ There was an issue processing your payment. Our team has been notified. Please contact support with ID: ${transaction.transactionId}',
    );
    return;
  }

  // Get user information
  final BotUser? user = ctx.user;
  if (user == null) {
    await ctx.reply(
      '⚠️ Your payment was received, but your account is not properly set up.\n\n'
      'Please use /start to create your account first, then send /refund to request a refund for this transaction.',
    );
    return;
  }

  // Process based on payment payload
  final payload = successfulPayment.invoicePayload;

  if (payload == 'draw-bet') {
    await _processDailyDrawPayment(ctx, user, successfulPayment);
  } else {
    // Unknown payload type

    await ctx.reply(
      '✅ Your payment of ${successfulPayment.totalAmount} stars has been recorded, but I\'m not sure what it was for.\n\n'
      'If this was a mistake, please use /refund to request assistance.',
    );
  }
}

/// Process payments specifically for the daily lucky draw
Future<void> _processDailyDrawPayment(
  Context ctx,
  BotUser user,
  SuccessfulPayment payment,
) async {
  try {
    try {
      // Acknowledge receipt immediately
      await ctx.react('🏆');
      log('Reacted to the message');
    } catch (err, stack) {
      log('Error while reacting!', error: err, stackTrace: stack);
    }

    // Add to the pool
    final poolMethods = PoolMethods(supabase);
    final entry = await poolMethods.createEntry(
      user.userId,
      payment.totalAmount,
      payment.telegramPaymentChargeId,
    );

    // Calculate time remaining until draw
    final now = DateTime.now().toUtc();
    final drawTime = DateTime.utc(now.year, now.month, now.day, 12);
    final nextDraw =
        now.hour >= 12 ? drawTime.add(const Duration(days: 1)) : drawTime;
    final remaining = nextDraw.difference(now);

    // Format time remaining
    final hoursRemaining = remaining.inHours;
    final minutesRemaining = remaining.inMinutes % 60;
    final timeString = '$hoursRemaining hours and $minutesRemaining minutes';

    // Respond with confirmation and stats
    await ctx.reply(
      '🎯 *Great bet!* You\'ve added ${payment.totalAmount} stars to today,\'s draw!\n\n'
      '💰 Your total contribution today: *${entry.amount} stars* (${entry.transactionIds.length} transactions)\n'
      '⏱ Next draw in: *$timeString*\n\n'
      'The more stars you contribute, the higher your chances of winning! Use /join to place another bet or /today to see today\'s pool.',
      parseMode: ParseMode.markdown,
    );
  } catch (e, stack) {
    log('Error in payment handler.', error: e, stackTrace: stack);
    await ctx.reply(
      '⚠️ There was an issue adding your stars to today\'s draw. Don\'t worry, your payment is safe!\n\n'
      'Our team has been notified. You can try again or contact support if needed.',
    );
  }
}
