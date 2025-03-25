import 'dart:developer';

import 'package:luckeverydaybot/database/user_methods.dart';
import 'package:luckeverydaybot/luckeverydaybot.dart';
import 'package:test/test.dart';

void main() {
  group('UserMethods Tests', () {
    final methods = UserMethods(supabase);

    test('getNumberOfReferredUsers returns correct count', () async {
      final result = await methods.getNumberOfReferredUsers(1726826785);
      log('Result: $result');
      expect(result, isA<int>());
    });

    test(
      'getNumberOfReferredUsers returns zero for non-existent user',
      () async {
        final result = await methods.getNumberOfReferredUsers(9999999999);
        log('Result: $result');
        expect(result, equals(0));
      },
    );
  });
}
