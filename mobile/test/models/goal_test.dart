import 'package:flutter_test/flutter_test.dart';
import 'package:bookread/models/goal.dart';
import 'package:bookread/utilities/constants.dart';

void main() {
  group('Goal', () {
    group('fromJson', () {
      test('should create an instance from JSON with all values', () {
        final json = {
          GoalFields.userId: '1234',
          GoalFields.type: 0,
          GoalFields.value: 100,
        };

        final goal = Goal.fromJson(json);

        expect(goal.type, isA<GoalType>());
        expect(goal.type, GoalType.daily);
        expect(goal.value, 100);
      });

      test(
        'should fail to create an instance from JSON with missing values',
        () {
          final json = {GoalFields.type: 0};

          expect(() => Goal.fromJson(json), throwsA(isA<TypeError>()));
        },
      );
    });
  });
}
