import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._init();

  static final NotificationService instance = NotificationService._init();

  final String channelId = 'timer_channel';
  final String channelName = 'Timer Notifications';
  final String channelDescription = 'Timer Notifications';
  final int notificationId = 0;

  bool hasNotificationPermission = false;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initializes the notification settings.
  /// This method sets up the notification channel and requests permission
  /// to show notifications on Android devices.
  Future<void> init({bool isBackgroudService = false}) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      importance: Importance.max,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    await androidImplementation?.createNotificationChannel(channel);

    if (isBackgroudService) {
      hasNotificationPermission = true;
      return;
    }
    final bool? grantedNotificationPermission =
        await androidImplementation?.requestNotificationsPermission();

    if (grantedNotificationPermission != null) {
      hasNotificationPermission = grantedNotificationPermission;
    } else {
      hasNotificationPermission = false;
    }
  }

  /// Shows a notification with the given [title] and [body].
  /// If [details] is provided, it will be used instead of the default
  /// notification details.
  void show(String title, String body, {NotificationDetails? details}) {
    if (!hasNotificationPermission) return;

    final NotificationDetails notificationDetails =
        details ??
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDescription,
            importance: Importance.max,
            priority: Priority.high,
          ),
        );

    flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      notificationDetails,
    );
  }
}
