import 'dart:developer';

import 'package:televerse/telegram.dart';
import 'package:televerse/televerse.dart';
import '../consts/consts.dart';
import '../database/pool_methods.dart';
import '../database/transaction_methods.dart';
import '../database/user_methods.dart';
import '../extensions/user_ext.dart';
import '../language/en.dart';
import '../luckeverydaybot.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import '../utils/logger.dart';

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

  final userId = ctx.from!.id;

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
  } catch (err, stack) {
    BotLogger.log(
      '💰 Error while registering transaction.\n'
      'ID: $userId\n'
      'Amount: ${transaction.amount}\n\n'
      'TRXN: \n``\n${transaction.transactionId}```',
      error: err,
      stackTrace: stack,
      thread: DebugGroup.threads.paymentIssues,
      board: InlineKeyboard()
          .copyText('Copy User ID', copyText: userId.toString())
          .row()
          .copyText('Copy TRXN ID', copyText: transaction.transactionId),
    ).ignore();
    await ctx.reply(en.errorRegisteringTransaction(transaction.transactionId));
    return;
  }

  // Get user information
  BotUser? user = await ctx.user;
  final String username = (user?.name ?? 'Player!').trim();
  if (user == null) {
    log('Creating user account!');
    user = await UserMethods(supabase).createUser(
      userId: ctx.from!.id,
      name: username,
      langauge: ctx.from!.languageCode,
    );
    log('User created ${user.userId}!');
  }

  // Process based on payment payload
  final payload = successfulPayment.invoicePayload;

  if (payload == PayloadData.betPaylod) {
    await _processDailyDrawPayment(ctx, user, successfulPayment);
  } else if (payload == PayloadData.vipPayload) {
    await _processVipStatusPayment(ctx);
  } else {
    await ctx.reply(user.lang.unknownPayment(transaction.amount));
    BotLogger.log(
      '💰 Unknown payment is received.\n'
      'ID: ${user.userId}\n'
      'Amount: ${transaction.amount}\n\n'
      'TRXN: ```\n${transaction.transactionId}```',
      thread: DebugGroup.threads.paymentIssues,
    ).ignore();
  }
}

/// Process payments for activating the vip status.
Future<void> _processVipStatusPayment(Context ctx) async {
  try {
    // Acknowledge receipt immediately
    await ctx.react('⚡');
    log('Reacted to the message');
  } catch (err, stack) {
    log('Error while reacting!', error: err, stackTrace: stack);
  }

  final methods = UserMethods(supabase);
  try {
    final user = await methods.updateUser(
      (await ctx.user)!.copyWith(isVip: true),
    );
    await ctx.reply(user.lang.activatedVip, parseMode: ParseMode.markdown);
  } catch (err, stack) {
    log(
      "Error while updating user's vip status",
      error: err,
      stackTrace: stack,
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
    final todayDrawTime = DateTime.utc(now.year, now.month, now.day, 23, 59);
    final nextDraw =
        now.isAfter(todayDrawTime)
            ? todayDrawTime.add(const Duration(days: 1))
            : todayDrawTime;
    final remaining = nextDraw.difference(now);

    // Format time remaining
    final hoursRemaining = remaining.inHours;
    final minutesRemaining = remaining.inMinutes % 60;
    final timeString = user.lang.durationTimeString(
      hoursRemaining,
      minutesRemaining,
    );

    // Respond with confirmation and stats
    await ctx.reply(
      user.lang.betConfirmation(
        payment.totalAmount,
        entry.amount,
        entry.transactionIds.length,
        timeString,
      ),
      parseMode: ParseMode.markdown,
    );
  } catch (e, stack) {
    log('Error in payment handler.', error: e, stackTrace: stack);
    await ctx.reply(user.lang.paymentError);
  }
}
