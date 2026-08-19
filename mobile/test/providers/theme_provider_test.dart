import 'package:flutter_test/flutter_test.dart';
import 'package:bookread/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThemeProvider', () {
    late ThemeProvider themeProvider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      themeProvider = ThemeProvider();
    });

    group('initialization', () {
      test('should initialize with light theme by default', () {
        expect(themeProvider.isDarkMode, isFalse);
      });

      test('should load saved theme preference', () async {
        // Set mock preferences
        SharedPreferences.setMockInitialValues({'isDarkMode': true});

        themeProvider = ThemeProvider();
        themeProvider.loadTheme();

        // Wait for async operation
        await Future.delayed(const Duration(milliseconds: 100));

        expect(themeProvider.isDarkMode, isTrue);
      });
    });

    group('theme toggling', () {
      test('should toggle to dark mode', () {
        themeProvider.toggleTheme();
        expect(themeProvider.isDarkMode, isTrue);
      });

      test('should toggle back to light mode', () {
        themeProvider.toggleTheme(); // to dark
        themeProvider.toggleTheme(); // back to light
        expect(themeProvider.isDarkMode, isFalse);
      });

      test('should set specific theme value', () {
        themeProvider.toggleTheme(value: true);
        expect(themeProvider.isDarkMode, isTrue);

        themeProvider.toggleTheme(value: false);
        expect(themeProvider.isDarkMode, isFalse);
      });

      test('should notify listeners when theme changes', () {
        bool wasNotified = false;
        themeProvider.addListener(() {
          wasNotified = true;
        });

        themeProvider.toggleTheme();
        expect(wasNotified, isTrue);
      });
    });

    group('persistence', () {
      test('should save theme preference to shared preferences', () async {
        themeProvider.toggleTheme();

        // Wait for async save operation
        await Future.delayed(const Duration(milliseconds: 100));

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('isDarkMode'), isTrue);
      });

      test('should load theme preference from shared preferences', () async {
        // Set preference
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isDarkMode', true);

        // Load theme
        themeProvider.loadTheme();

        // Wait for async operation
        await Future.delayed(const Duration(milliseconds: 100));

        expect(themeProvider.isDarkMode, isTrue);
      });

      test('should handle missing theme preference', () async {
        themeProvider.loadTheme();

        // Wait for async operation
        await Future.delayed(const Duration(milliseconds: 100));

        expect(themeProvider.isDarkMode, isFalse);
      });

      test('should handle null theme preference', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('isDarkMode');

        themeProvider.loadTheme();

        // Wait for async operation
        await Future.delayed(const Duration(milliseconds: 100));

        expect(themeProvider.isDarkMode, isFalse);
      });
    });

    group('edge cases', () {
      test('should handle multiple rapid theme changes', () {
        for (int i = 0; i < 10; i++) {
          themeProvider.toggleTheme();
        }

        // After 10 toggles (even number), should be back to original state (false)
        expect(themeProvider.isDarkMode, isFalse);
      });

      test('should handle setting same theme multiple times', () {
        themeProvider.toggleTheme(value: true);
        themeProvider.toggleTheme(value: true);
        themeProvider.toggleTheme(value: true);

        expect(themeProvider.isDarkMode, isTrue);
      });

      test('should handle rapid save operations', () async {
        for (int i = 0; i < 5; i++) {
          themeProvider.toggleTheme();
          await Future.delayed(const Duration(milliseconds: 10));
        }

        expect(themeProvider.isDarkMode, isTrue);
      });

      test('should handle concurrent load and save operations', () async {
        // Start load operation
        themeProvider.loadTheme();

        // Immediately toggle theme (which triggers save)
        themeProvider.toggleTheme();

        // Wait for both operations to complete
        await Future.delayed(const Duration(milliseconds: 200));

        // Should not throw errors
        expect(themeProvider.isDarkMode, isTrue);
      });
    });

    group('state management', () {
      test('should maintain state consistency', () {
        final initialState = themeProvider.isDarkMode;

        themeProvider.toggleTheme();
        expect(themeProvider.isDarkMode, !initialState);

        themeProvider.toggleTheme();
        expect(themeProvider.isDarkMode, initialState);
      });

      test('should not notify listeners when state does not change', () {
        int notificationCount = 0;
        themeProvider.addListener(() {
          notificationCount++;
        });

        themeProvider.toggleTheme(value: false); // Already false
        expect(notificationCount, equals(1)); // Always notifies regardless
      });

      test('should handle listener removal', () {
        bool wasNotified = false;
        void listener() {
          wasNotified = true;
        }

        themeProvider.addListener(listener);
        themeProvider.removeListener(listener);
        themeProvider.toggleTheme();

        expect(wasNotified, isFalse);
      });
    });
  });
}
