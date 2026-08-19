import 'package:flutter/material.dart';

class StarRating extends StatefulWidget {
  const StarRating({
    super.key,
    this.initialValue = 0,
    this.iconSize = 36.0,
    this.onRatingChanged,
  });

  final int initialValue;
  final double iconSize;
  final ValueChanged<int>? onRatingChanged;

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  int value = 0;

  @override
  void initState() {
    super.initState();

    value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.secondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () {
            if (widget.onRatingChanged != null) {
              widget.onRatingChanged!(index + 1);
            }
            if (mounted) {
              setState(() {
                value = index + 1;
              });
            }
          },
          color: index < value ? color : null,
          iconSize: widget.iconSize,
          icon: Icon(
            index < value ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
          padding: EdgeInsets.zero,
        );
      }),
    );
  }
}
