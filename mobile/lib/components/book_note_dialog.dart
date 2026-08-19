import 'package:bookread/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:bookread/utilities/constants.dart';

class BookNoteDialog extends StatefulWidget {
  const BookNoteDialog({super.key, this.initialPage, this.initialContent});

  final int? initialPage;
  final String? initialContent;

  @override
  State<BookNoteDialog> createState() => _BookNoteDialogState();
}

class _BookNoteDialogState extends State<BookNoteDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController pageController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  int? page;
  String content = '';

  @override
  void initState() {
    super.initState();

    pageController.text = widget.initialPage?.toString() ?? '';
    contentController.text = widget.initialContent?.toString() ?? '';
    page = widget.initialPage;
    content = widget.initialContent ?? '';
  }

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
                Text(t.translate('createNewBookNote')),
                const SizedBox(height: kSpaceSizeBetweenWidgets),
                TextFormField(
                  controller: pageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: t.translate('pageNumberHint')),
                  onChanged: (value) {
                    page = int.tryParse(value);
                  },
                ),
                const SizedBox(height: kSpaceSizeBetweenWidgets),
                TextFormField(
                  controller: contentController,
                  decoration: InputDecoration(hintText: t.translate('typeInHere')),
                  maxLines: 6,
                  onChanged: (value) {
                    content = value;
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
                      onPressed:
                          () => Navigator.of(context).pop((page, content)),
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
