import 'package:flutter_test/flutter_test.dart';
import 'package:bookread/models/goal.dart';
import 'package:bookread/models/settings.dart';

void main() {
  group('Settings', () {
    group('fromJson', () {
      test('should create an instance from JSON with all values', () {
        final json = {
          SettingsFields.notifDaily: true,
          SettingsFields.notifGoal: false,
        };

        final settings = Settings.fromJson(json);

        expect(settings.notifDaily, isTrue);
        expect(settings.notifGoal, isFalse);
      });

      test(
        'should fail to create an instance from JSON with missing values',
        () {
          final json = {SettingsFields.notifDaily: 'a'};

          expect(() => Goal.fromJson(json), throwsA(isA<TypeError>()));
        },
      );
    });
  });
}
