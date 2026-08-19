import 'package:flutter_test/flutter_test.dart';
import 'package:bookread/models/goal.dart';
import 'package:bookread/models/streak.dart';

void main() {
  group('Streak', () {
    group('fromJson', () {
      test('should create an instance from JSON with all values', () {
        final json = {
          StreakFields.userId: '1234',
          StreakFields.start: '2023-01-01T00:00:00Z',
          StreakFields.end: '2023-01-10T00:00:00Z',
          StreakFields.length: 10,
        };

        final streak = Streak.fromJson(json);

        expect(streak.userId, isA<BigInt>());
        expect(streak.userId, BigInt.parse('1234'));
        expect(streak.start, DateTime.parse('2023-01-01T00:00:00Z'));
        expect(streak.end, DateTime.parse('2023-01-10T00:00:00Z'));
        expect(streak.length, 10);
      });

      test(
        'should fail to create an instance from JSON with missing values',
        () {
          final json = {StreakFields.userId: '1234'};

          expect(() => Goal.fromJson(json), throwsA(isA<TypeError>()));
        },
      );
    });
  });
}
