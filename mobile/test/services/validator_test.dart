import 'package:flutter_test/flutter_test.dart';
import 'package:bookread/services/validator.dart';

void main() {
  group('Validator', () {
    group('isValidUsername', () {
      test('should return true for valid usernames', () {
        expect(Validator.isValidUsername('user123'), isTrue);
        expect(Validator.isValidUsername('test_user'), isTrue);
        expect(Validator.isValidUsername('abc'), isTrue);
        expect(Validator.isValidUsername('username_123'), isTrue);
        expect(Validator.isValidUsername('a1b2c3'), isTrue);
      });

      test('should return false for invalid usernames', () {
        // Too short
        expect(Validator.isValidUsername('ab'), isFalse);
        expect(Validator.isValidUsername(''), isFalse);

        // Too long
        expect(Validator.isValidUsername('a' * 21), isFalse);

        // Invalid characters
        expect(Validator.isValidUsername('user@123'), isFalse);
        expect(Validator.isValidUsername('user-123'), isFalse);
        expect(Validator.isValidUsername('user 123'), isFalse);
        expect(Validator.isValidUsername('User123'), isFalse);
        expect(Validator.isValidUsername('user.123'), isFalse);
        expect(Validator.isValidUsername('user#123'), isFalse);
      });

      test('should handle edge cases', () {
        // Minimum length
        expect(Validator.isValidUsername('abc'), isTrue);

        // Maximum length
        expect(Validator.isValidUsername('a' * 20), isTrue);

        // Only numbers
        expect(Validator.isValidUsername('123'), isTrue);

        // Only underscores with letters
        expect(Validator.isValidUsername('___'), isTrue);
      });
    });

    group('isValidEmail', () {
      test('should return true for valid emails', () {
        expect(Validator.isValidEmail('test@example.com'), isTrue);
        expect(Validator.isValidEmail('user.name@domain.co.uk'), isTrue);
        expect(Validator.isValidEmail('user+tag@example.org'), isTrue);
        expect(Validator.isValidEmail('test123@test-domain.com'), isTrue);
        expect(Validator.isValidEmail('a@b.co'), isTrue);
        expect(Validator.isValidEmail('user_name@example.com'), isTrue);
        expect(Validator.isValidEmail('user%test@example.com'), isTrue);
      });

      test('should return false for invalid emails', () {
        expect(Validator.isValidEmail(''), isFalse);
        expect(Validator.isValidEmail('invalid-email'), isFalse);
        expect(Validator.isValidEmail('user@'), isFalse);
        expect(Validator.isValidEmail('@example.com'), isFalse);
        expect(Validator.isValidEmail('user@.com'), isFalse);
        expect(Validator.isValidEmail('user@domain'), isFalse);
        expect(Validator.isValidEmail('user@domain.'), isFalse);
        expect(Validator.isValidEmail('user@@domain.com'), isFalse);
      });

      test('should handle edge cases', () {
        // Very long domain
        expect(
          Validator.isValidEmail('user@very-long-domain-name.com'),
          isTrue,
        );

        // Single character local part
        expect(Validator.isValidEmail('a@example.com'), isTrue);

        // Multiple dots in domain
        expect(Validator.isValidEmail('user@sub.domain.example.com'), isTrue);
      });
    });

    group('isValidPassword', () {
      test('should return true for valid passwords', () {
        expect(Validator.isValidPassword('Password123!'), isTrue);
        expect(Validator.isValidPassword('MySecure@Pass1'), isTrue);
        expect(Validator.isValidPassword('Test123#Password'), isTrue);
        expect(Validator.isValidPassword('Abcd1234!'), isTrue);
        expect(Validator.isValidPassword('StrongP@ssw0rd'), isTrue);
        expect(Validator.isValidPassword('ValidPass123\$'), isTrue);
        expect(Validator.isValidPassword('Another@Valid123'), isTrue);
        expect(Validator.isValidPassword('Secure*Pass123'), isTrue);
      });

      test('should return false for invalid passwords', () {
        // Too short
        expect(Validator.isValidPassword('Ab1@'), isFalse);
        expect(Validator.isValidPassword(''), isFalse);

        // Missing uppercase
        expect(Validator.isValidPassword('password123!'), isFalse);

        // Missing lowercase
        expect(Validator.isValidPassword('PASSWORD123!'), isFalse);

        // Missing number
        expect(Validator.isValidPassword('Password!'), isFalse);

        // Missing special character
        expect(Validator.isValidPassword('Password123'), isFalse);

        // Only letters
        expect(Validator.isValidPassword('Password'), isFalse);

        // Only numbers
        expect(Validator.isValidPassword('12345678'), isFalse);
      });

      test('should handle edge cases', () {
        // Minimum length with all required chars
        expect(Validator.isValidPassword('Abc123!@'), isTrue);

        // Very long password
        expect(Validator.isValidPassword('VeryLongPasswordWith123!@#'), isTrue);

        // All special characters
        expect(Validator.isValidPassword('Pass123@#!%*?&'), isTrue);

        // Mixed case with numbers and symbols
        expect(Validator.isValidPassword('MyP@ssw0rd!'), isTrue);
      });
    });

    group('edge cases and security', () {
      test('should handle null and empty strings safely', () {
        // Note: In Dart, passing null to a non-nullable parameter would cause a compile error
        // So we only test empty strings
        expect(Validator.isValidUsername(''), isFalse);
        expect(Validator.isValidEmail(''), isFalse);
        expect(Validator.isValidPassword(''), isFalse);
      });

      test('should handle whitespace correctly', () {
        expect(Validator.isValidUsername(' user123 '), isFalse);
        expect(Validator.isValidEmail(' test@example.com '), isFalse);
        expect(Validator.isValidPassword(' Password123! '), isFalse);
      });

      test('should be case sensitive where appropriate', () {
        // Username should be lowercase only
        expect(Validator.isValidUsername('Username123'), isFalse);

        // Email should handle case
        expect(Validator.isValidEmail('TEST@EXAMPLE.COM'), isTrue);

        // Password requires mixed case
        expect(Validator.isValidPassword('password123!'), isFalse);
        expect(Validator.isValidPassword('PASSWORD123!'), isFalse);
      });
    });
  });
}
