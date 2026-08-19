import 'package:bookread/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:bookread/components/arc_progress_bar.dart';
import 'package:bookread/providers/timer_provider.dart';
import 'package:bookread/utilities/constants.dart';
import 'package:bookread/utilities/helper.dart';
import 'package:provider/provider.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  static const String id = 'timer_screen';

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final TimerProvider timerProvider = Provider.of<TimerProvider>(context);
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(t.translate('timer'))),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              t.translate('readingGoals'),
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kSpaceSizeBetweenWidgets),
            Text(
              t.translate('readingGoalsSubtitle'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),
            ArcProgressBar(progress: timerProvider.progress),
            const SizedBox(height: 20),
            Text(t.translate('todayReading'), style: TextStyle(fontSize: 18)),
            TextButton(
              onPressed: () async {
                if (timerProvider.isRunning) return;

                final Duration? duration = await Helper.getDuration(
                  context,
                  initialTime: timerProvider.duration,
                );

                if (duration == null) return;
                timerProvider.setDuration(duration);
              },
              child: Text(
                timerProvider.formatTime(),
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  timerProvider.isRunning
                      ? timerProvider.stopTimer
                      : timerProvider.startTimer,
              child: Text(
                timerProvider.isRunning ? t.translate('stopTimer') : t.translate('startTimer'),
              ),
            ),
            if (!timerProvider.isRunning && timerProvider.hasStarted)
              const SizedBox(height: 20),
            if (!timerProvider.isRunning && timerProvider.hasStarted)
              ElevatedButton(
                onPressed: timerProvider.resetTimer,
                child: Text(t.translate('resetTimer')),
              ),
          ],
        ),
      ),
    );
  }
}
