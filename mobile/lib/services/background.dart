import 'package:flutter/material.dart';
import 'package:bookread/models/auth.dart';
import 'package:bookread/models/goal.dart';
import 'package:bookread/models/reading_log.dart';
import 'package:bookread/models/settings.dart';
import 'package:bookread/models/streak.dart';
import 'package:bookread/services/notification.dart';
import 'package:bookread/utilities/system.dart';
import 'package:bookread/utilities/task_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

class BackgroundService {
  static const Map<String, Map<String, String>> backgroundTranslations = {
    'en': {
      'daily_title': 'Your Streak Is Waiting 🔥',
      'daily_body': '{streak} days of streak! Don\'t forget to read today!',
      'goal_title': 'Finish the Day Right ✅',
      'goal_body':
          'How was your day? Don\'t forget to complete your daily goal!',
    },
    'pt': {
      'daily_title': 'O teu Streak Está à Espera 🔥',
      'daily_body': '{streak} dias de streak! Não te esqueças de ler hoje!',
      'goal_title': 'Termina o Dia em Grande ✅',
      'goal_body':
          'Como foi o teu dia? Não te esqueças de completar o teu objetivo diário!',
    },
  };

  static const String morningTask = 'morningNotification';
  static const String eveningTask = 'eveningNotification';

  static void init() async {
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: System.instance.isInDebug,
    );

    await scheduleDailyNotification(morningTask, hour: 14, minute: 25);
    await scheduleDailyNotification(eveningTask, hour: 14, minute: 25);
  }

  static Future<void> scheduleDailyNotification(
    String taskId, {
    required int hour,
    int minute = 0,
  }) async {
    final now = DateTime.now();
    DateTime targetTime = DateTime(now.year, now.month, now.day, hour, minute);

    if (now.isAfter(targetTime)) {
      targetTime = targetTime.add(const Duration(days: 1));
    }

    final delay = targetTime.difference(now);

    await Workmanager().registerOneOffTask(
      taskId,
      taskId,
      initialDelay: delay,
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
      ),
    );
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Required for plugin binding
    WidgetsFlutterBinding.ensureInitialized();

    // Re-initialize NotificationService
    await NotificationService.instance.init(isBackgroudService: true);

    final response = await AuthApi.tryLogin();
    if (response is! TaskOkResponse) {
      debugPrint('User is not logged in. Skipping task execution.');
      return Future.value(false);
    }

    final Settings? settings = System.instance.settings;
    if (settings == null) {
      debugPrint('Daily notifications are disabled. Skipping task execution.');
      return Future.value(false);
    }

    // Get the user's locale from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale') ?? 'pt';

    final translations = BackgroundService.backgroundTranslations[code]!;

    switch (task) {
      case BackgroundService.morningTask:
        if (settings.notifDaily) {
          final streak = await StreakApi.getStreak();
          if (streak != null) {
            final title = translations['daily_title']!;
            final body = translations['daily_body']!.replaceAll(
              '{streak}',
              streak.length.toString(),
            );
            NotificationService.instance.show(title, body);
          }
        }
        await BackgroundService.scheduleDailyNotification(
          BackgroundService.morningTask,
          hour: 8,
        );
        break;

      case BackgroundService.eveningTask:
        if (settings.notifDaily) {
          final Goal? dailyGoal = System.instance.dailyGoal;
          if (dailyGoal == null) {
            debugPrint('No daily goal set. Skipping task execution.');
            return Future.value(false);
          }

          final TaskResponse response =
              await ReadingLogApi.countReadedPagesByDate(DateTime.now());
          if (response is! TaskOkResponse) {
            debugPrint('Failed to count readed pages: ${response.message}');
            return Future.value(false);
          }

          final int readedPages = response.result as int;
          if (readedPages < dailyGoal.value) {
            final title = translations['goal_title']!;
            final body = translations['goal_body']!;
            NotificationService.instance.show(title, body);
          }
        }
        await BackgroundService.scheduleDailyNotification(
          BackgroundService.eveningTask,
          hour: 20,
        );
        break;
    }

    return Future.value(true);
  });
}
