import 'package:flutter/material.dart';
import 'package:bookread/components/arc_painter.dart';

class ArcProgressBar extends StatelessWidget {
  const ArcProgressBar({
    super.key,
    required this.progress,
    this.size = const Size(200, 95),
  });

  final double progress;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: Size(200, 95),
          painter: ArcPainter(
            completedColor: Theme.of(context).colorScheme.primary,
            incompletedColor: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        CustomPaint(
          size: Size(200, 95),
          painter: ArcPainter(
            complete: true,
            progress: progress,
            completedColor: Theme.of(context).colorScheme.primary,
            incompletedColor: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
