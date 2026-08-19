import 'package:flutter_test/flutter_test.dart';
import 'package:bookread/models/auth.dart';
import 'package:bookread/models/goal.dart';
import 'package:bookread/models/settings.dart';
import 'package:bookread/models/user.dart';

void main() {
  group('AuthResponse', () {
    group('fromJson', () {
      test('should create an instance from JSON with all values', () {
        final json = {
          AuthFields.token: 'ashtashtioashntoasht',
          AuthFields.user: {
            UserFields.id: '1234',
            UserFields.username: 'Test User',
            UserFields.email: 'test@test.com',
            UserFields.birthdate: '2000-01-01T00:00:00.000Z',
            UserFields.gender: 0,
            UserFields.avatar: 'https://example.com/avatar.png',
          },
          AuthFields.goals: [
            {
              GoalFields.userId: '1234',
              GoalFields.type: 0,
              GoalFields.value: 5,
            },
            {
              GoalFields.userId: '1234',
              GoalFields.type: 1,
              GoalFields.value: 5,
            },
          ],
          AuthFields.settings: {
            SettingsFields.notifDaily: true,
            SettingsFields.notifGoal: false,
          },
        };

        final authResponse = AuthResponse.fromJson(json);

        expect(authResponse.token, isNotNull);
        expect(authResponse.user, isA<User>());
        expect(authResponse.goals, isA<List<Goal>>());
        expect(authResponse.goals, hasLength(2));
        expect(authResponse.settings, isA<Settings>());
      });

      test(
        'should fail to create an instance from JSON with missing values',
        () {
          final json = {AuthFields.token: 'ashtashtioashntoasht'};

          expect(() => AuthResponse.fromJson(json), throwsA(isA<TypeError>()));
        },
      );
    });
  });
}
