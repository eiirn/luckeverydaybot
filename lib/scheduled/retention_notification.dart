import 'dart:developer';

import 'package:televerse/televerse.dart';

import '../database/user_methods.dart';
import '../luckeverydaybot.dart';

class RetentionNotificationService {
  Future<void> notifyInactiveUsers() async {
    final methods = UserMethods(supabase);

    final peeps = await methods.fetchUsersForReminder();
    log('We have ${peeps.length} number of people to notify.');

    for (var i = 0; i < peeps.length; i++) {
      try {
        await api.sendMessage(
          ChatID(peeps[i].userId),
          peeps[i].lang.getInactivityReminderMessage(peeps[i].totalSpends > 0),
        );
        await methods.updateLastNotified(peeps[i].userId);
        log('Notified ${i + 1}/${peeps.length}: ${peeps[i].userId}');
        await Future.delayed(const Duration(seconds: 8));
      } catch (_) {}
    }
  }
}
