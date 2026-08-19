mixin Validator {
  static bool isValidUsername(String username) {
    // Username must be at least 3 characters long and can contain letters, numbers, and underscores
    final RegExp usernameRegex = RegExp(r'^[a-z0-9_]{3,20}$');
    return usernameRegex.hasMatch(username);
  }

  static bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  static bool isValidPassword(String password) {
    // At least 8 characters, at least one uppercase letter, one lowercase letter and one number
    final RegExp passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@#$!%*?&])[a-zA-Z\d@#$!%*?&]{8,}$',
    );
    return passwordRegex.hasMatch(password);
  }
}
