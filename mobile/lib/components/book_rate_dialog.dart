import 'package:bookread/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:bookread/utilities/constants.dart';
import 'package:bookread/components/star_rating.dart';

class BookRateDialog extends StatefulWidget {
  const BookRateDialog({super.key, this.initialValue});

  final int? initialValue;

  @override
  State<BookRateDialog> createState() => _BookRateDialogState();
}

class _BookRateDialogState extends State<BookRateDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int rate = 0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Dialog(
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(kRadiusLarge),
          ),
          padding: EdgeInsets.all(kPadding),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(t.translate('setBookRate')),
                const SizedBox(height: kSpaceSizeBetweenWidgets),
                StarRating(
                  initialValue: widget.initialValue ?? 0,
                  onRatingChanged: (value) {
                    setState(() {
                      rate = value;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(t.translate('cancel')),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop((rate)),
                      child: Text(t.translate('ok')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
