import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookread/providers/timer_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TimerProvider', () {
    late TimerProvider timerProvider;

    setUp(() {
      // Mock the audio player method channels
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('xyz.luan/audioplayers.global'),
            (MethodCall methodCall) async {
              switch (methodCall.method) {
                case 'init':
                  return null;
                default:
                  return null;
              }
            },
          );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('xyz.luan/audioplayers'),
            (MethodCall methodCall) async {
              switch (methodCall.method) {
                case 'create':
                  return 'player_id';
                case 'setReleaseMode':
                  return null;
                case 'setSource':
                  return null;
                case 'resume':
                  return null;
                case 'pause':
                  return null;
                case 'stop':
                  return null;
                case 'dispose':
                  return null;
                default:
                  return null;
              }
            },
          );

      timerProvider = TimerProvider();
    });

    tearDown(() {
      timerProvider.dispose();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('xyz.luan/audioplayers.global'),
            null,
          );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('xyz.luan/audioplayers'),
            null,
          );
    });

    group('initialization', () {
      test('should initialize with default values', () {
        expect(timerProvider.time, equals(0));
        // Progress is NaN when duration is 0, so we check for NaN
        expect(timerProvider.progress.isNaN, isTrue);
        expect(timerProvider.isRunning, isFalse);
        expect(timerProvider.hasStarted, isFalse);
        expect(timerProvider.duration, equals(Duration.zero));
      });

      test('should initialize audio player', () {
        expect(timerProvider.player, isNotNull);
      });
    });

    group('timer operations', () {
      test('should set duration correctly', () {
        const duration = Duration(minutes: 30);
        timerProvider.setDuration(duration);

        expect(timerProvider.duration, equals(duration));
        expect(timerProvider.time, equals(duration.inSeconds));
        expect(
          timerProvider.hasStarted,
          isFalse,
        ); // hasStarted is false when time equals duration
      });

      test('should not start timer when time is zero', () {
        timerProvider.startTimer();
        expect(timerProvider.isRunning, isFalse);
      });

      test('should not start timer when already running', () {
        timerProvider.setDuration(const Duration(minutes: 5));
        timerProvider.startTimer();
        expect(timerProvider.isRunning, isTrue);

        // Try to start again
        timerProvider.startTimer();
        expect(timerProvider.isRunning, isTrue);
      });

      test('should stop timer correctly', () {
        timerProvider.setDuration(const Duration(minutes: 5));
        timerProvider.startTimer();
        expect(timerProvider.isRunning, isTrue);

        timerProvider.stopTimer();
        expect(timerProvider.isRunning, isFalse);
      });

      test('should reset timer correctly', () {
        timerProvider.setDuration(const Duration(minutes: 5));
        timerProvider.startTimer();

        timerProvider.resetTimer();
        expect(timerProvider.isRunning, isFalse);
        expect(timerProvider.time, equals(300)); // Reset to duration, not 0
      });

      test('should calculate progress correctly', () {
        const duration = Duration(minutes: 10);
        timerProvider.setDuration(duration);

        expect(timerProvider.progress, equals(0.0));

        // Progress should be 0 when time equals duration
        expect(timerProvider.progress, equals(0.0));
      });

      test('should format time correctly', () {
        timerProvider.setDuration(const Duration(minutes: 5, seconds: 30));
        expect(timerProvider.formatTime(), equals('5:30'));

        timerProvider.setDuration(const Duration(minutes: 10, seconds: 5));
        expect(timerProvider.formatTime(), equals('10:05'));

        timerProvider.setDuration(const Duration(seconds: 59));
        expect(timerProvider.formatTime(), equals('0:59'));
      });
    });

    group('edge cases', () {
      test('should handle setting negative duration', () {
        const duration = Duration(seconds: -10);
        timerProvider.setDuration(duration);
        expect(timerProvider.duration, equals(duration));
        expect(timerProvider.time, equals(duration.inSeconds));
      });

      test('should handle setting zero duration', () {
        timerProvider.setDuration(Duration.zero);
        expect(timerProvider.duration, equals(Duration.zero));
        expect(timerProvider.time, equals(0));
      });

      test('should handle very long duration', () {
        const duration = Duration(hours: 24);
        timerProvider.setDuration(duration);
        expect(timerProvider.duration, equals(duration));
        expect(timerProvider.time, equals(duration.inSeconds));
      });

      test('should not set duration when timer is running', () {
        const initialDuration = Duration(minutes: 5);
        const newDuration = Duration(minutes: 10);

        timerProvider.setDuration(initialDuration);
        timerProvider.startTimer();

        // Try to set new duration while running
        timerProvider.setDuration(newDuration);

        // Duration should remain unchanged
        expect(timerProvider.duration, equals(initialDuration));
      });

      test('should handle rapid start/stop operations', () {
        timerProvider.setDuration(const Duration(minutes: 1));

        for (int i = 0; i < 10; i++) {
          timerProvider.startTimer();
          timerProvider.stopTimer();
        }

        expect(timerProvider.isRunning, isFalse);
      });
    });

    group('time formatting', () {
      test('should format single digit seconds with leading zero', () {
        timerProvider.setDuration(const Duration(minutes: 2, seconds: 5));
        expect(timerProvider.formatTime(), equals('2:05'));
      });

      test('should format double digit seconds without leading zero', () {
        timerProvider.setDuration(const Duration(minutes: 2, seconds: 15));
        expect(timerProvider.formatTime(), equals('2:15'));
      });

      test('should format zero minutes and seconds', () {
        timerProvider.setDuration(Duration.zero);
        expect(timerProvider.formatTime(), equals('0:00'));
      });

      test('should format large durations correctly', () {
        timerProvider.setDuration(
          const Duration(hours: 2, minutes: 30, seconds: 45),
        );
        expect(timerProvider.formatTime(), equals('150:45'));
      });
    });

    group('state management', () {
      test('should notify listeners when setting duration', () {
        bool wasNotified = false;
        timerProvider.addListener(() {
          wasNotified = true;
        });

        timerProvider.setDuration(const Duration(minutes: 5));
        expect(wasNotified, isTrue);
      });

      test('should provide correct hasStarted state', () {
        expect(timerProvider.hasStarted, isFalse);

        timerProvider.setDuration(const Duration(minutes: 5));
        expect(
          timerProvider.hasStarted,
          isFalse,
        ); // hasStarted is false when time equals duration

        timerProvider.resetTimer();
        expect(timerProvider.hasStarted, isFalse);
      });
    });
  });
}
