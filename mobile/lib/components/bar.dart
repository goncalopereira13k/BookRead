import 'package:flutter/material.dart';
import 'package:bookread/utilities/constants.dart';

class Bar extends StatelessWidget {
  const Bar({
    super.key,
    required this.label,
    required this.value,
    this.maxValue = 100,
  });

  final String label;
  final int value;
  final int maxValue;
  final double maxHeight = 58.0;

  double getHeight() {
    if (maxValue == 0) return 0;
    if (value > maxValue) return maxHeight;
    return (value / maxValue) * maxHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('$value', style: const TextStyle(fontSize: 12)),
        Container(
          height: getHeight(),
          width: 20,
          constraints: BoxConstraints(maxHeight: maxHeight),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(kRadiusSmall),
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
