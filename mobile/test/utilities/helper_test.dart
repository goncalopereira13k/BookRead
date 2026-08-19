import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookread/utilities/helper.dart';

void main() {
  group('Helper', () {
    testWidgets('getDuration should show duration picker', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await Helper.getDuration(context);
                  },
                  child: const Text('Show Duration Picker'),
                );
              },
            ),
          ),
        ),
      );

      // Tap the button to show duration picker
      await tester.tap(find.text('Show Duration Picker'));
      await tester.pumpAndSettle();

      // Verify duration picker is shown
      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('getDuration should use initial time when provided', (
      WidgetTester tester,
    ) async {
      const initialTime = Duration(minutes: 30);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await Helper.getDuration(context, initialTime: initialTime);
                  },
                  child: const Text('Show Duration Picker'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Duration Picker'));
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('askNumber should show number input dialog', (
      WidgetTester tester,
    ) async {

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await Helper.askNumber(context, 'Enter Number', hintText: 'Enter a number');
                  },
                  child: const Text('Ask Number'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Ask Number'));
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Enter Number'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('askNumber should handle initial value', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await Helper.askNumber(
                      context,
                      'Enter Number',
                      initialValue: 42,
                      hintText: 'Enter a number',
                    );
                  },
                  child: const Text('Ask Number'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Ask Number'));
      await tester.pumpAndSettle();

      // Verify initial value is set
      expect(find.text('42'), findsOneWidget);
      expect(find.text('Enter a number'), findsOneWidget);
    });

    testWidgets('askNumber should handle cancel', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await Helper.askNumber(context, 'Enter Number');
                  },
                  child: const Text('Ask Number'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Ask Number'));
      await tester.pumpAndSettle();

      // Tap cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog should be dismissed
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('askNumber should handle text input', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await Helper.askNumber(context, 'Enter Number');
                  },
                  child: const Text('Ask Number'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Ask Number'));
      await tester.pumpAndSettle();

      // Enter text in the text field
      await tester.enterText(find.byType(TextField), '123');
      await tester.pumpAndSettle();

      // Verify text is entered
      expect(find.text('123'), findsOneWidget);
    });

    testWidgets('askNumber should handle invalid input', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await Helper.askNumber(context, 'Enter Number');
                  },
                  child: const Text('Ask Number'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Ask Number'));
      await tester.pumpAndSettle();

      // Enter invalid text
      await tester.enterText(find.byType(TextField), 'invalid');
      await tester.pumpAndSettle();

      // Should still show the invalid text
      expect(find.text('invalid'), findsOneWidget);
    });

    testWidgets('askNumber should handle empty input', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await Helper.askNumber(context, 'Enter Number');
                  },
                  child: const Text('Ask Number'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Ask Number'));
      await tester.pumpAndSettle();

      // Leave field empty and try to submit
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      // Field should remain empty
      expect(find.text(''), findsOneWidget);
    });

    group('edge cases', () {
      testWidgets('should handle negative numbers', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      await Helper.askNumber(context, 'Enter Number');
                    },
                    child: const Text('Ask Number'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Ask Number'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), '-42');
        await tester.pumpAndSettle();

        expect(find.text('-42'), findsOneWidget);
      });

      testWidgets('should handle zero', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      await Helper.askNumber(context, 'Enter Number');
                    },
                    child: const Text('Ask Number'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Ask Number'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), '0');
        await tester.pumpAndSettle();

        expect(find.text('0'), findsOneWidget);
      });

      testWidgets('should handle large numbers', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      await Helper.askNumber(context, 'Enter Number');
                    },
                    child: const Text('Ask Number'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Ask Number'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), '999999999');
        await tester.pumpAndSettle();

        expect(find.text('999999999'), findsOneWidget);
      });
    });
  });
}
