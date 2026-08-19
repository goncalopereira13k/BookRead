import 'package:flutter_test/flutter_test.dart';
import 'package:bookread/models/user.dart';
import 'package:bookread/utilities/constants.dart';

void main() {
  group('User Model Tests', () {
    test('Conversão de User para JSON', () {
      final user = User(
        id: BigInt.from(123),
        username: 'testuser',
        email: 'test@example.com',
        birthdate: DateTime(2000),
        gender: Gender.male,
        avatar: 'avatar.png',
      );

      final json = user.toJson();

      expect(json[UserFields.id], '123');
      expect(json[UserFields.username], 'testuser');
      expect(json[UserFields.email], 'test@example.com');
      expect(json[UserFields.birthdate], '2000-01-01T00:00:00.000');
      expect(json[UserFields.gender], Gender.male.index);
      expect(json[UserFields.avatar], 'avatar.png');
    });

    test('Conversão de JSON para User', () {
      final json = {
        UserFields.id: '123',
        UserFields.username: 'testuser',
        UserFields.email: 'test@example.com',
        UserFields.birthdate: '2000-01-01T00:00:00.000',
        UserFields.gender: Gender.male.index,
        UserFields.avatar: 'avatar.png',
      };

      final user = User.fromJson(json);

      expect(user.id, BigInt.from(123));
      expect(user.username, 'testuser');
      expect(user.email, 'test@example.com');
      expect(user.birthdate, DateTime(2000));
      expect(user.gender, Gender.male);
      expect(user.avatar, 'avatar.png');
    });
  });
}
