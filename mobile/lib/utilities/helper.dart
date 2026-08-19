import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bookread/utilities/constants.dart';

mixin Helper {
  static Future<Duration?> getDuration(
    BuildContext context, {
    Duration? initialTime,
  }) {
    initialTime ??= Duration.zero;

    return showDurationPicker(
      context: context,
      initialTime: initialTime,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kRadiusMedium),
      ),
    );
  }

  static Future<int?> askNumber(
    BuildContext context,
    String title, {
    int? initialValue,
    String hintText = 'Number',
  }) {
    final TextEditingController controller = TextEditingController();
    controller.text = initialValue?.toString() ?? '';

    return showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: hintText),
            onChanged: (value) {
              initialValue = int.tryParse(value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(initialValue),
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  static String getLocalDateTimeString(DateTime dateTime) {
    final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm:ss');
    return formatter.format(dateTime.toLocal());
  }

  static String getLocalDateString(DateTime? dateTime) {
    if (dateTime == null) return '';
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    return formatter.format(dateTime.toLocal());
  }

  static String getLocalTimeString(DateTime? dateTime) {
    if (dateTime == null) return '';
    final DateFormat formatter = DateFormat('HH:mm:ss');
    return formatter.format(dateTime.toLocal());
  }

  /// Remove the decimal zeros from a double.
  static String roundToString(double n, {int decimalPlaces = 6}) {
    final formatFractions = NumberFormat('#.######', 'en');
    formatFractions.minimumFractionDigits = 0;
    formatFractions.maximumFractionDigits = decimalPlaces;

    return formatFractions.format(n);
  }
}
