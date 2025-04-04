import 'dart:async';
import 'dart:developer';
import 'dart:math' hide log;
import 'dart:math' as math;

import 'package:supabase/supabase.dart';
import 'package:televerse/telegram.dart';
import 'package:televerse/televerse.dart';
import '../consts/consts.dart';
import '../language/en.dart';
import '../luckeverydaybot.dart';
import '../models/pool_entry.dart';
import '../models/user.dart';
import '../utils/formatting.dart';
import '../utils/logger.dart';

/// Selects a winner from the daily pool and distributes the prize
class WinnerSelector {
  WinnerSelector({required this.supabase});
  final SupabaseClient supabase;
  final Random _random = Random.secure();

  // Configure house fee percentage (10-15%)
  final double houseFeePercentage = 15;

  /// Run the winner selection process for the given date
  /// If no date is provided, today's date is used (in GMT)
  Future<void> selectWinner({String? date}) async {
    // Get the date in the format used by the database (DD-MM-YYYY)
    final targetDate = date ?? getCurrentDate();

    BotLogger.log('🎲 Running winner selection for date: $targetDate').ignore();

    try {
      // 1. Fetch all pool entries for the target date
      final List<PoolEntry> poolEntries = await fetchPoolEntriesForDate(
        targetDate,
      );

      if (poolEntries.isEmpty) {
        log(
          'ℹ️ No pool entries found for $targetDate. Skipping winner selection.',
        );
        return;
      }

      // 2. Calculate total pool amount
      final int totalPool = poolEntries.fold(
        0,
        (sum, entry) => sum + entry.amount,
      );

      if (totalPool <= 0) {
        log(
          'ℹ️ Total pool amount is 0 for $targetDate. Skipping winner selection.',
        );
        return;
      }

      log('💰 Total pool amount: $totalPool stars');

      // 3. Calculate house fee
      final int houseFee = (totalPool * houseFeePercentage / 100).round();
      final int prizeAmount = totalPool - houseFee;

      log(
        '💸 House fee (${houseFeePercentage.toStringAsFixed(1)}%): $houseFee stars',
      );
      log('🏆 Prize amount: $prizeAmount stars');

      // 4. Fetch all users who participated
      final List<int> userIds =
          poolEntries.map((entry) => entry.userId).toList();
      final List<BotUser> participants = await fetchUsersByIds(userIds);

      if (participants.isEmpty) {
        log('⚠️ Failed to fetch participant data. Skipping winner selection.');
        const channel = ChatID(CommonData.channelId);
        await api.sendMessage(
          channel,
          'ℹ️ *Lucky Draw Update*\n\n'
          'There were no participants in today\'s pool. '
          'As a result, the draw has been skipped. \n\n'
          'We hope to see more people joining in the next round! 🍀',
          replyMarkup: InlineKeyboard().addUrl(
            'Join next round',
            'https://t.me/TheCashSplashBot',
          ),
          parseMode: ParseMode.markdown,
        );
        return;
      }

      // 5. Select winner based on weighted probabilities
      final weightedWinner = await _selectWinnerWithWeightedProbability(
        poolEntries,
        participants,
      );

      final winner = weightedWinner.user;

      // 6. Update pool entry to mark winner
      await markWinner(targetDate, winner.userId);

      // 7. Update winner's balance
      await updateUserWinnings(winner.userId, prizeAmount);

      log('🎉 Winner selected: ${winner.name} (ID: ${winner.userId})');
      log('💵 Prize of $prizeAmount stars awarded!');

      final hasBeenReferred = !winner.isVip && winner.referredBy != null;

      var winning = prizeAmount;
      if (hasBeenReferred) {
        winning = prizeAmount - (prizeAmount * 0.05).round();
        log('User was referred by ${winner.referredBy}');
        log('We should send 5% commission to them.');
      }

      // Announce the winner.
      try {
        const channel = ChatID(CommonData.channelId);
        await api.sendDice(channel, emoji: DiceEmoji.slotMachine);
        await api.sendMessage(
          channel,
          '🎉 *WINNER ANNOUNCEMENT* 🎉\n\n🏆 '
          "Congratulations to *${winner.name}* ${winner.isVip ? '🎖️ ' : ''}for winning today's lucky draw!\n\n"
          '🦄 Winner ID: ${winner.userId}\n'
          '💰 Total pool: *$totalPool* ⭐️\n\n'
          'The more stars you contribute, the higher your chances to win. '
          'Will YOU be our next lucky winner? 🍀',
          replyMarkup: InlineKeyboard().addUrl(
            'Join next round',
            'https://t.me/TheCashSplashBot',
          ),
          parseMode: ParseMode.markdown,
        );
      } catch (err, stack) {
        BotLogger.log(
          'Error while posting on channel',
          error: err,
          stackTrace: stack,
        ).ignore();
      }
      try {
        if (hasBeenReferred) {
          if (hasBeenReferred) {
            await api.sendMessage(
              ChatID(winner.userId),
              "🎊 *Congratulations!* You've WON today's Lucky Draw!\n\n💰 "
              'Your prize: *$winning* ⭐️ has been credited to your account.\n\n'
              '📝 Note: 5% (${(prizeAmount * 0.05).round()} stars) '
              'of your total win was shared with your referrer as commission.\n\n'
              '⭐ Want to keep 100% of your winnings? '
              'Upgrade to VIP status to eliminate referral commissions on future wins!',
              parseMode: ParseMode.markdown,
            );
          }
        } else {
          final winnerChat = ChatID(winner.userId);
          final msg = await api.sendMessage(
            winnerChat,
            "🎊 *Congratulations!* You've WON today's Lucky Draw!\n\n💰 "
            'Your prize: *$prizeAmount stars* worth of gifts are coming on '
            'the way!\n\nKeep participating daily for more chances to win big! 🍀',
            parseMode: ParseMode.markdown,
          );
          await api.setMessageReaction(
            winnerChat,
            msg.messageId,
            reaction: [const ReactionType.emoji(emoji: '🎉')],
            isBig: true,
          );
        }
      } catch (err, stack) {
        BotLogger.log(
          'Error while posting on channel',
          error: err,
          stackTrace: stack,
        ).ignore();
      }

      // 8. Get available gifts from Telegram API
      final gifts = await api.getAvailableGifts();

      // 9. Select optimal gifts for the prize amount
      final optimal = selectOptimalGifts(winning + winner.balance, gifts.gifts);

      // 10. Log selected gift IDs
      final giftIds = optimal.gifts.map((gift) => gift.id).toList();
      log(
        '🎁 Selected gift IDs: ${giftIds.join(", ")}',
        name: 'Gifts for Winner',
      );

      // Send the gifts!
      for (final gift in optimal.gifts) {
        try {
          await api.sendGift(
            giftId: gift.id,
            userId: winner.userId,
            text: 'Reward for winning the Lucky Draw! 🎉',
          );
        } catch (err, stack) {
          BotLogger.log(
            'Error sending gift to Winner (${winner.userId})!\n\n```${gift.toJson()}```',
            error: err,
            stackTrace: stack,
          ).ignore();
        }
      }

      // 11. Add any unused stars to the user's balance
      if (optimal.unusedStars > 0) {
        await updateUserBalance(
          winner.userId,
          optimal.unusedStars,
          overwrite: true,
        );
      }

      // 12. Process referral commission if applicable
      if (hasBeenReferred) {
        final commissionAmount = (prizeAmount * 0.05).round();
        log(
          '💸 Sending commission of $commissionAmount stars to referrer ${winner.referredBy}',
        );
        // 13. Find optimal gifts for the referrer
        final opGiftsForReferrer = selectOptimalGifts(
          commissionAmount,
          gifts.gifts,
        );

        // 14. Log selected gift IDs
        final giftIdsForRef =
            opGiftsForReferrer.gifts.map((gift) => gift.id).toList();
        log(
          '🎁 Selected gift IDs for : ${giftIdsForRef.join(", ")}',
          name: 'Gifts for Referrer',
        );

        if (opGiftsForReferrer.unusedStars > 0) {
          await updateUserBalance(
            winner.referredBy!,
            opGiftsForReferrer.unusedStars,
          );
        }

        // Notify the referrer about the commission (optional)
        try {
          await api.sendMessage(
            ChatID(winner.referredBy!),
            '🎉 *Referral Bonus!* 🎉\n\nYou just received *$commissionAmount '
            "stars* as commission because someone you invited won today's "
            'lucky draw! Keep inviting friends to earn more commissions.',
            parseMode: ParseMode.markdown,
          );
        } catch (e, stack) {
          BotLogger.log(
            'Failed to notify referrer about commission.',
            error: e,
            stackTrace: stack,
          ).ignore();
        }
      }

      // Notify every eligible participants that results are just came in.
      for (var i = 0; i < participants.length; i++) {
        final participant = participants[i];
        if (participant.userId == winner.userId) {
          continue;
        }
        try {
          await api.sendMessage(
            ChatID(participant.userId),
            participant.lang.resultsAreIn(totalPool),
            replyMarkup: InlineKeyboard().addUrl(
              participant.lang.checkWinnerTitle,
              CommonData.channel,
            ),
          );
          await Future.delayed(const Duration(seconds: 10));
        } catch (_) {}
      }
    } catch (e, stacktrace) {
      if (e is OnlyParticipantException) {
        const channel = ChatID(CommonData.channelId);
        await api.sendMessage(
          channel,
          'ℹ️ *Lucky Draw Update*\n\n'
          'There was only one participant in today\'s pool. '
          'As per our policy, the draw has been skipped and the entry fee has been refunded. '
          'Thank you for participating, and we hope to see more players in the next round! 🍀',
          parseMode: ParseMode.markdown,
        );
        BotLogger.log(
          '✅ There was only one player in the pool. So we refuneded.',
        ).ignore();
        return;
      }
      BotLogger.log(
        '❌ Error selecting winner.',
        error: e,
        stackTrace: stacktrace,
      ).ignore();
    }
  }

  /// Select a winner using weighted probability based on multiple factors:
  /// - Amount contributed (more stars = higher chance)
  /// - Channel/group membership (must be a member)
  /// - Premium status (small bonus for premium users)
  /// - Referrals (small bonus for users who bring others)
  /// - VIP status (small bonus for VIP users)
  /// - Random factor (for fairness)
  Future<_WeightedParticipant> _selectWinnerWithWeightedProbability(
    List<PoolEntry> poolEntries,
    List<BotUser> users,
  ) async {
    // Create a map of userId to user for easier lookup
    final Map<int, BotUser> userMap = {
      for (final user in users) user.userId: user,
    };

    // Filter eligible entries (user must not be banned or blocked)
    final List<PoolEntry> eligibleEntries =
        poolEntries.where((entry) {
          final user = userMap[entry.userId];
          return user != null && !user.banned && !user.blocked;
        }).toList();

    if (eligibleEntries.isEmpty) {
      throw Exception('No eligible participants found for winner selection');
    }

    if (eligibleEntries.length == 1) {
      try {
        await api.sendMessage(
          ChatID(eligibleEntries.first.userId),
          (userMap[eligibleEntries.first.userId]?.lang ?? en).onlyOnePlayer,
        );
        for (var i = 0; i < eligibleEntries.first.transactionIds.length; i++) {
          await api.refundStarPayment(
            userId: eligibleEntries.first.userId,
            telegramPaymentChargeId: eligibleEntries.first.transactionIds[i],
          );
          await Future.delayed(const Duration(seconds: 8));
        }
      } catch (err, stack) {
        BotLogger.log(
          'Error while refunding.',
          error: err,
          stackTrace: stack,
        ).ignore();
      }
      throw OnlyParticipantException();
    }

    // Calculate weights for each eligible entry
    final List<_WeightedParticipant> weightedParticipants = [];

    for (final entry in eligibleEntries) {
      final user = userMap[entry.userId]!;

      // Base weight from amount contributed (more stars = higher weight)
      double weight = entry.amount.toDouble();

      // Premium status bonus (small bonus for Telegram Premium users)
      if (user.isPremium) {
        weight *= 1.03; // 3% bonus for Premium users
      }

      // VIP bonus (optional: give VIP users a slight advantage)
      if (user.isVip) {
        weight *= 1.05; // 5% bonus for VIPs
      }

      // Referral bonus (reward users who bring others)
      // Using a logarithmic scale to prevent excessive advantage for popular users
      if (user.totalReferrals > 0) {
        // Calculate referral bonus factor: up to 5% extra for referrals
        // Using log base 10 to flatten the curve for users with many referrals
        final referralFactor =
            1 + (Math.log(user.totalReferrals + 1) / Math.log(10)) * 0.05;
        weight *= referralFactor;
      }

      // Channel/group membership bonus (if they've joined our communities)
      if (user.hasJoinedChannel && user.hasJoinedGroup) {
        weight *= 1.02; // 2% bonus for community members
      }

      // Random factor (adds unpredictability and fairness)
      // Between 0.9 and 1.1 multiplier (±10% randomness)
      final randomFactor = 0.9 + (_random.nextDouble() * 0.2);
      weight *= randomFactor;

      weightedParticipants.add(
        _WeightedParticipant(user: user, entry: entry, weight: weight),
      );
    }

    // Sort by weight (highest to lowest) for debugging clarity
    weightedParticipants.sort((a, b) => b.weight.compareTo(a.weight));

    // Log weights for debugging
    log('🎯 Weighted probabilities:');
    for (final wp in weightedParticipants) {
      final user = wp.user;
      log(
        '  ${user.name} (ID: ${user.userId}): ${wp.weight.toStringAsFixed(2)} '
        '[Stars: ${wp.entry.amount}, '
        'Premium: ${user.isPremium}, '
        'VIP: ${user.isVip}, '
        'Referrals: ${user.totalReferrals}]',
      );
    }

    // Calculate total weight
    final double totalWeight = weightedParticipants.fold(
      0,
      (sum, wp) => sum + wp.weight,
    );

    // Select a random point within the total weight
    final double randomPoint = _random.nextDouble() * totalWeight;

    // Find the winner based on the random point
    double currentWeight = 0;
    for (final wp in weightedParticipants) {
      currentWeight += wp.weight;
      if (randomPoint <= currentWeight) {
        return wp;
      }
    }

    // Fallback (should never reach here, but just in case)
    return weightedParticipants.first;
  }

  /// Fetch all pool entries for a specific date
  Future<List<PoolEntry>> fetchPoolEntriesForDate(String date) async {
    try {
      final response = await supabase.from('pool').select().eq('date', date);

      return response.map(PoolEntry.fromJson).toList();
    } catch (e, stack) {
      log('Error fetching pool entries', error: e, stackTrace: stack);
      return [];
    }
  }

  /// Fetch users by their IDs
  Future<List<BotUser>> fetchUsersByIds(List<int> userIds) async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .inFilter('user_id', userIds);

      return response.map(BotUser.fromJson).toList();
    } catch (e, stack) {
      log('Error fetching users', error: e, stackTrace: stack);
      return [];
    }
  }

  /// Mark a user as the winner for a specific date
  Future<void> markWinner(String date, int userId) async {
    try {
      // First, reset all winners for this date (in case we're re-running)
      await supabase.from('pool').update({'is_winner': false}).eq('date', date);

      // Then, mark the selected winner
      await supabase
          .from('pool')
          .update({'is_winner': true})
          .eq('date', date)
          .eq('user_id', userId);
    } catch (e, stack) {
      log('Error marking winner', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Update a user's winnings balance
  Future<void> updateUserWinnings(int userId, int amount) async {
    try {
      // Get current winnings
      final response =
          await supabase
              .from('users')
              .select('winnings')
              .eq('user_id', userId)
              .single();

      final int currentWinnings = response['winnings'] as int;
      final int newWinnings = currentWinnings + amount;

      // Update winnings
      await supabase
          .from('users')
          .update({'winnings': newWinnings})
          .eq('user_id', userId);
    } catch (e, stack) {
      log('Error updating user winnings.', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Create a transaction record
  Future<void> createTransaction({
    required String transactionId,
    required int userId,
    required int amount,
    required String type,
    String? note,
  }) async {
    try {
      await supabase.from('transactions').insert({
        'transaction_id': transactionId,
        'user_id': userId,
        'amount': amount,
        'type': type,
        'note': note,
        'transaction_date': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e, stack) {
      log('Error creating transaction', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Find the optimal combination of gifts for the given prize amount
  OptimalGifts selectOptimalGifts(int prizeAmount, List<Gift> availableGifts) {
    // Sort gifts by star count in descending order
    // This helps us prioritize larger gifts first
    final sortedGifts = [...availableGifts]
      ..sort((a, b) => b.starCount.compareTo(a.starCount));

    // Initialize our selected gifts list
    final selectedGifts = <Gift>[];
    int remainingAmount = prizeAmount;

    // First pass: Greedy approach - take largest gifts that fit
    for (final gift in sortedGifts) {
      // Skip gifts that are too expensive for our remaining budget
      if (gift.starCount > remainingAmount) {
        continue;
      }

      // Check if this gift has remaining count limit
      final canAdd = gift.remainingCount == null || gift.remainingCount! > 0;

      if (canAdd) {
        selectedGifts.add(gift);
        remainingAmount -= gift.starCount;

        // If we've exactly used the prize amount, we're done
        if (remainingAmount == 0) {
          break;
        }
      }
    }

    // Second pass: If we still have budget left, try to fill in with smaller gifts
    if (remainingAmount > 0) {
      // Sort by star count ascending for filling in smaller gifts
      final fillerGifts =
          sortedGifts
              .where((gift) => gift.starCount <= remainingAmount)
              .toList()
            ..sort((a, b) => a.starCount.compareTo(b.starCount));

      for (final gift in fillerGifts) {
        // Skip if no remaining gifts of this type
        final canAdd = gift.remainingCount == null || gift.remainingCount! > 0;

        if (canAdd) {
          selectedGifts.add(gift);
          remainingAmount -= gift.starCount;

          if (remainingAmount <= 0) {
            break;
          }
        }
      }
    }

    // Log the result
    final totalStars = selectedGifts.fold(
      0,
      (sum, gift) => sum + gift.starCount,
    );
    log(
      '🎁 Selected ${selectedGifts.length} gifts worth $totalStars stars',
      name: 'selectOptimalGifts',
    );
    log('⭐ Unused stars: $remainingAmount', name: 'selectOptimalGifts');

    for (final gift in selectedGifts) {
      log(
        '  Gift ID: ${gift.id}, Stars: ${gift.starCount}',
        name: 'selectOptimalGifts',
      );
    }

    return OptimalGifts(selectedGifts, remainingAmount);
  }

  /// Update a user's star balance by incrementing it with the given amount
  ///
  /// [userId] - The ID of the user whose balance to update
  /// [amount] - The amount of stars to add (can be negative to subtract)
  /// Returns the new balance after the update
  /// Update a user's star balance
  ///
  /// [userId] - The ID of the user whose balance to update
  /// [amount] - The amount of stars to set or add
  /// [overwrite] - If true, overwrites the balance with [amount]; if false, adds [amount] to the current balance
  /// Returns the new balance after the update
  Future<int> updateUserBalance(
    int userId,
    int amount, {
    bool overwrite = false,
  }) async {
    try {
      // First get the current balance
      final response =
          await supabase
              .from('users')
              .select('balance')
              .eq('user_id', userId)
              .single();

      // Default to 0 if balance is null (might be the case for older records)
      final int currentBalance = (response['balance'] as int?) ?? 0;

      // Calculate new balance based on overwrite flag
      final int newBalance = overwrite ? amount : currentBalance + amount;

      // Update the balance
      await supabase
          .from('users')
          .update({'balance': newBalance})
          .eq('user_id', userId);

      if (overwrite) {
        log('💰 Set balance for user $userId: $currentBalance → $newBalance');
      } else {
        log(
          '💰 Updated balance for user $userId: $currentBalance → $newBalance (${amount >= 0 ? "+$amount" : amount})',
        );
      }

      return newBalance;
    } catch (e, stack) {
      log('❌ Error updating user balance', error: e, stackTrace: stack);
      rethrow;
    }
  }
}

/// Helper class for weighted selection
class _WeightedParticipant {
  _WeightedParticipant({
    required this.user,
    required this.entry,
    required this.weight,
  });
  final BotUser user;
  final PoolEntry entry;
  final double weight;
}

/// Helper class for storing optimal gifts with unused stars
class OptimalGifts {
  const OptimalGifts(this.gifts, this.unusedStars);
  final List<Gift> gifts;
  final int unusedStars;
}

/// Utility for math operations
class Math {
  const Math._();

  /// Logarithm implementation
  static double log(num x, [num? base]) {
    if (base == null) {
      return math.log(x);
    } else {
      return math.log(x) / math.log(base);
    }
  }
}

/// Only participant exception
class OnlyParticipantException implements Exception {}
