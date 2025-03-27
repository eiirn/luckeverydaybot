import 'dart:developer';

import 'package:televerse/televerse.dart';

import '../database/user_methods.dart';
import '../luckeverydaybot.dart';
import '../utils/logger.dart';

class _FailedNotification {
  const _FailedNotification(this.id, this.reason);
  final int id;
  final String reason;

  @override
  String toString() => '$id: $reason\n\n';
}

class RetentionNotificationService {
  Future<void> notifyInactiveUsers() async {
    BotLogger.log('🔔 Running retention notifications').ignore();
    final methods = UserMethods(supabase);

    final peeps = await methods.fetchUsersForReminder();
    BotLogger.log(
      'We have ${peeps.length} number of people to notify.\n\n[${peeps.map((e) => e.userId).join(', ')}]',
    ).ignore();
    var success = 0;
    final failed = <_FailedNotification>[];
    for (var i = 0; i < peeps.length; i++) {
      try {
        await api.sendMessage(
          ChatID(peeps[i].userId),
          peeps[i].lang.getInactivityReminderMessage(peeps[i].totalSpends > 0),
        );
        await methods.updateLastNotified(peeps[i].userId);
        log('Notified ${i + 1}/${peeps.length}: ${peeps[i].userId}');
        success++;
        await Future.delayed(const Duration(seconds: 8));
      } catch (err) {
        failed.add(_FailedNotification(peeps[i].userId, err.toString()));
      }
    }
    BotLogger.log(
      'Total: ${peeps.length}\nSuccess: $success\nFailed: ${failed.length}',
    ).ignore();
    log(failed.toString());
  }
}
