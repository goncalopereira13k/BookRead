import 'package:flutter/material.dart';

class ArcPainter extends CustomPainter {
  ArcPainter({
    this.complete = false,
    this.progress = 0.0,
    this.completedColor = Colors.black,
    this.incompletedColor = Colors.grey,
  });

  final bool complete;
  final double progress;
  final Color completedColor;
  final Color incompletedColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = complete ? completedColor : incompletedColor
          ..strokeWidth = 10
          ..style = PaintingStyle.stroke;

    final path =
        Path()..arcTo(
          Rect.fromCircle(
            center: Offset(size.width / 2, size.height),
            radius: 70,
          ),
          3.14,
          3.14,
          false,
        );

    if (complete) {
      final pathMetric = path.computeMetrics().first;
      final extractPath = pathMetric.extractPath(
        0.0,
        pathMetric.length * progress,
      );
      canvas.drawPath(extractPath, paint);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
