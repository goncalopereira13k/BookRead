import 'package:bookread/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:bookread/models/book_status.dart';
import 'package:bookread/utilities/constants.dart';

class TimerFinishDialog extends StatefulWidget {
  const TimerFinishDialog({super.key});

  @override
  State<TimerFinishDialog> createState() => _TimerFinishDialogState();
}

class _TimerFinishDialogState extends State<TimerFinishDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Future<List<BookStatus>> futureReadingBooks = Future.value([]);
  final TextEditingController pagesController = TextEditingController();
  BookStatus? selectedReading;
  int? numberOfPages = 0;

  @override
  void initState() {
    super.initState();

    futureReadingBooks = BookStatusApi.getReadingBooks();
    pagesController.text = numberOfPages.toString();
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
                Text(t.translate('timerEnded')),
                const SizedBox(height: kSpaceSizeBetweenWidgets),
                FutureBuilder(
                  future: futureReadingBooks,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<List<BookStatus>> snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text(t.translate('failedToGetReadingBooks'));
                    } else if (snapshot.hasData) {
                      final booksStatus = snapshot.data;
                      if (booksStatus == null) {
                        return Text(t.translate('readingBooksNotFound'));
                      }

                      // Set first reading book as default
                      selectedReading = booksStatus.firstOrNull;

                      return DropdownButtonFormField(
                        items:
                            booksStatus
                                .map(
                                  (bookStatus) => DropdownMenuItem(
                                    key: ValueKey(bookStatus.id),
                                    value: bookStatus,
                                    child: Text(bookStatus.book.title),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          selectedReading = value;
                        },
                      );
                    } else {
                      return Text(t.translate('failedToGetReadingBooks'));
                    }
                  },
                ),
                const SizedBox(height: kSpaceSizeBetweenWidgets),
                TextFormField(
                  controller: pagesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: t.translate('numberOfPages'),
                  ),
                  onChanged: (value) {
                    numberOfPages = int.tryParse(value);
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
                          () => Navigator.of(
                            context,
                          ).pop((selectedReading, numberOfPages)),
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
