import 'dart:async';
import 'dart:developer';
import 'package:cron/cron.dart';
import 'package:supabase/supabase.dart';
import '../utils/formatting.dart';
import 'winner_selector.dart';

/// Manages all scheduled tasks for the bot
class TaskScheduler {
  TaskScheduler({required this.supabase}) {
    _winnerSelector = WinnerSelector(supabase: supabase);
  }
  final SupabaseClient supabase;
  final Cron _cron = Cron();
  late final WinnerSelector _winnerSelector;

  /// Initialize all scheduled tasks
  void initialize() {
    _scheduleWinnerSelection();
    log('✅ Scheduled tasks initialized');
  }

  /// Schedule the daily winner selection at 23:59 GMT
  void _scheduleWinnerSelection() {
    // Cron expression for 23:59 GMT every day: minute hour day-of-month month day-of-week
    // 59 23 * * * means "At 23:59 every day"
    _cron.schedule(Schedule.parse('59 23 * * *'), () async {
      log('⏰ Running scheduled winner selection (23:59 GMT)');
      await _winnerSelector.selectWinner();
    });

    log('🕙 Winner selection scheduled for 23:59 GMT daily');
  }

  /// Manually run the winner selection for a specific date (for testing or recovery)
  Future<void> runWinnerSelectionManually({String? date}) async {
    final targetDate = date ?? getCurrentDate();
    log('🔄 Manually running winner selection for date: $targetDate');
    await _winnerSelector.selectWinner(date: targetDate);
  }

  /// Dispose of all scheduled tasks
  void dispose() {
    _cron.close();
    log('🛑 Scheduled tasks disposed');
  }
}
