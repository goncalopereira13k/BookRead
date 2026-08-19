import 'package:flutter/material.dart';
import 'package:bookread/app_localizations.dart';
import 'package:bookread/models/settings.dart';
import 'package:bookread/utilities/constants.dart';
import 'package:bookread/utilities/system.dart';
import 'package:bookread/utilities/task_response.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  static const String id = 'notifications_screen';

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool dailyGoal = true;
  bool streak = true;
  bool allNotifications = true;

  @override
  void initState() {
    super.initState();
    setup();
  }

  Future<void> setup() async {
    Settings? settings = System.instance.settings;
    if (settings == null) {
      final TaskResponse response = await SettingsApi.getSettings();
      if (response is TaskOkResponse) settings = response.result;
    }

    if (settings == null && mounted) return Navigator.pop(context);
    setState(() {
      dailyGoal = settings!.notifGoal;
      streak = settings.notifDaily;
      allNotifications = dailyGoal & streak;
    });
  }

  Future<void> onChangeNotifDaily(bool value) async {
    final TaskResponse response = await SettingsApi.setSettings(
      Settings(notifDaily: value, notifGoal: dailyGoal),
    );

    if (response is TaskOkResponse) {
      final Settings settings = response.result;
      setState(() {
        dailyGoal = settings.notifGoal;
        streak = settings.notifDaily;
        allNotifications = dailyGoal & streak;
      });
    }
  }

  Future<void> onChangeNotifGoal(bool value) async {
    final TaskResponse response = await SettingsApi.setSettings(
      Settings(notifDaily: streak, notifGoal: value),
    );

    if (response is TaskOkResponse) {
      final Settings settings = response.result;
      setState(() {
        dailyGoal = settings.notifGoal;
        streak = settings.notifDaily;
        allNotifications = dailyGoal & streak;
      });
    }
  }

  Future<void> onChangeAll(bool value) async {
    final TaskResponse response = await SettingsApi.setSettings(
      Settings(notifDaily: value, notifGoal: value),
    );

    if (response is TaskOkResponse) {
      final Settings settings = response.result;
      setState(() {
        dailyGoal = settings.notifGoal;
        streak = settings.notifDaily;
        allNotifications = dailyGoal & streak;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(t.translate('notifications')),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(kPadding),
              child: Column(
                children: [
                  Row(
                    children: [
                      Switch(
                        value: allNotifications,
                        onChanged: onChangeAll,
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.red[300],
                      ),
                      const SizedBox(width: kSpaceSizeBetweenWidgets),
                      Expanded(child: Text(t.translate('allNotifications'))),
                    ],
                  ),
                  Row(
                    children: [
                      Switch(
                        value: dailyGoal,
                        onChanged: onChangeNotifGoal,
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.red[300],
                      ),
                      const SizedBox(width: kSpaceSizeBetweenWidgets),
                      Expanded(
                        child: Text(t.translate('dailyGoalNotification')),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Switch(
                        value: streak,
                        onChanged: onChangeNotifDaily,
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.red[300],
                      ),
                      const SizedBox(width: kSpaceSizeBetweenWidgets),
                      Expanded(child: Text(t.translate('streakNotification'))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
