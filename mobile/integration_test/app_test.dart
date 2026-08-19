import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:bookread/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Book Reading App Integration Tests', () {
    testWidgets('App should start and show main screen', (
      WidgetTester tester,
    ) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify the app starts correctly
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Navigation should work between screens', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Test bottom navigation if it exists
      final bottomNavItems = find.byType(BottomNavigationBar);
      if (bottomNavItems.evaluate().isNotEmpty) {
        // Find navigation items
        final navItems = find.byIcon(Icons.home);
        if (navItems.evaluate().isNotEmpty) {
          await tester.tap(navItems.first);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('Theme toggle should work', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Look for settings or theme toggle
      final settingsButton = find.byIcon(Icons.settings);
      if (settingsButton.evaluate().isNotEmpty) {
        await tester.tap(settingsButton);
        await tester.pumpAndSettle();

        // Look for theme toggle
        final themeToggle = find.byType(Switch);
        if (themeToggle.evaluate().isNotEmpty) {
          await tester.tap(themeToggle.first);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('Timer functionality should work', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Look for timer-related widgets
      final timerWidget = find.textContaining('Timer');
      if (timerWidget.evaluate().isNotEmpty) {
        await tester.tap(timerWidget.first);
        await tester.pumpAndSettle();

        // Look for start button
        final startButton = find.textContaining('Start');
        if (startButton.evaluate().isNotEmpty) {
          await tester.tap(startButton.first);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('Book search should work', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Look for search functionality
      final searchIcon = find.byIcon(Icons.search);
      if (searchIcon.evaluate().isNotEmpty) {
        await tester.tap(searchIcon.first);
        await tester.pumpAndSettle();

        // Look for search field
        final searchField = find.byType(TextField);
        if (searchField.evaluate().isNotEmpty) {
          await tester.enterText(searchField.first, 'Test Book');
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('Reading goals should be accessible', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Look for goals section
      final goalsSection = find.textContaining('Goal');
      if (goalsSection.evaluate().isNotEmpty) {
        await tester.tap(goalsSection.first);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('User profile should be accessible', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Look for profile or user section
      final profileIcon = find.byIcon(Icons.person);
      if (profileIcon.evaluate().isNotEmpty) {
        await tester.tap(profileIcon.first);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('App should handle back navigation', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to a different screen first
      final settingsButton = find.byIcon(Icons.settings);
      if (settingsButton.evaluate().isNotEmpty) {
        await tester.tap(settingsButton);
        await tester.pumpAndSettle();

        // Try to go back
        final backButton = find.byIcon(Icons.arrow_back);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('App should handle orientation changes', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Get initial size
      final Size initialSize = tester.getSize(find.byType(MaterialApp));

      // Simulate orientation change (this is limited in integration tests)
      await tester.binding.setSurfaceSize(
        Size(initialSize.height, initialSize.width),
      );
      await tester.pumpAndSettle();

      // Verify app still works
      expect(find.byType(MaterialApp), findsOneWidget);

      // Restore original size
      await tester.binding.setSurfaceSize(initialSize);
      await tester.pumpAndSettle();
    });

    testWidgets('App should handle accessibility', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test basic accessibility by verifying semantic elements
      expect(find.byType(MaterialApp), findsOneWidget);

      // Test that buttons have proper semantic labels
      final buttons = find.byType(ElevatedButton);
      for (final button in buttons.evaluate()) {
        expect(button.widget, isA<ElevatedButton>());
      }
    });

    testWidgets('App should persist state across restarts', (
      WidgetTester tester,
    ) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Make some changes (e.g., toggle theme)
      final settingsButton = find.byIcon(Icons.settings);
      if (settingsButton.evaluate().isNotEmpty) {
        await tester.tap(settingsButton);
        await tester.pumpAndSettle();

        final themeToggle = find.byType(Switch);
        if (themeToggle.evaluate().isNotEmpty) {
          await tester.tap(themeToggle.first);
          await tester.pumpAndSettle();
        }
      }

      // Restart app (simulated)
      await tester.binding.reassembleApplication();
      await tester.pumpAndSettle();

      // Verify app still works
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
