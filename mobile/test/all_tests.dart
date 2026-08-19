import 'package:flutter_test/flutter_test.dart';

import 'models/book_test.dart' as book_test;
import 'models/user_test.dart' as user_test;
import 'models/book_status_test.dart' as book_status_test;
import 'models/goal_test.dart' as goal_test;
import 'models/reading_log_test.dart' as reading_log_test;
import 'models/settings_test.dart' as settings_test;
import 'models/streak_test.dart' as streak_test;
import 'models/book_note_test.dart' as book_note_test;
import 'models/auth_test.dart' as auth_test;
import 'services/validator_test.dart' as validator_test;
import 'providers/timer_provider_test.dart' as timer_provider_test;
import 'providers/theme_provider_test.dart' as theme_provider_test;
import 'utilities/helper_test.dart' as helper_test;

void main() {
  group('All Tests', () {
    group('Model Tests', () {
      book_test.main();
      user_test.main();
      book_status_test.main();
      goal_test.main();
      reading_log_test.main();
      settings_test.main();
      streak_test.main();
      book_note_test.main();
      auth_test.main();
    });

    group('Service Tests', () {
      validator_test.main();
    });

    group('Provider Tests', () {
      timer_provider_test.main();
      theme_provider_test.main();
    });

    group('Utility Tests', () {
      helper_test.main();
    });
  });
}
