import 'package:flutter/material.dart';
import 'package:bookread/app_localizations.dart';
import 'package:bookread/components/arc_progress_bar.dart';
import 'package:bookread/providers/timer_provider.dart';
import 'package:bookread/screens/timer_screen.dart';
import 'package:bookread/utilities/constants.dart';
import 'package:provider/provider.dart';

class TimerWidget extends StatelessWidget {
  const TimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final TimerProvider timerProvider = Provider.of<TimerProvider>(context);
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, TimerScreen.id);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(kRadiusLarge),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t.translate('timer'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            ArcProgressBar(progress: timerProvider.progress),
            const SizedBox(height: kSpaceSizeBetweenWidgets),
            Text(
              t.translate('todayReading'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              timerProvider.formatTime(),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
