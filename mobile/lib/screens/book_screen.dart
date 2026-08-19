import 'package:bookread/app_localizations.dart';
import 'package:bookread/components/book_note_dialog.dart';
import 'package:bookread/components/book_note_tile.dart';
import 'package:bookread/components/book_rate_dialog.dart';
import 'package:bookread/components/reading_log_tile.dart';
import 'package:bookread/components/star_display.dart';
import 'package:bookread/models/book.dart';
import 'package:bookread/models/book_note.dart';
import 'package:bookread/models/book_status.dart';
import 'package:bookread/models/reading_log.dart';
import 'package:bookread/services/docx_exporter.dart';
import 'package:bookread/utilities/constants.dart';
import 'package:bookread/utilities/helper.dart';
import 'package:bookread/utilities/system.dart';
import 'package:bookread/utilities/task_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({
    super.key,
    required this.book,
    this.bookStatus,
    required this.onCreatedReadingLog,
    required this.onStatusChanged,
  });

  static const String id = 'book_screen';

  final Book book;
  final BookStatus? bookStatus;
  final VoidCallback onCreatedReadingLog;
  final VoidCallback onStatusChanged;

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  late Book book;
  BookStatus? bookStatus;
  bool isWanted = false;
  bool isReading = false;
  bool isReaded = false;
  bool _isLoading = false;
  Future<List<ReadingLog>> futureReadingLogs = Future.value([]);
  Future<List<BookNote>> futureBookNotes = Future.value([]);
  Future<DateTime?> endDateEstimate = Future.value();
  Future<double?> bookProgress = Future.value();

  @override
  void initState() {
    super.initState();

    book = widget.book;
    bookStatus = widget.bookStatus;

    setup();
  }

  /// Check if the book is in the wanted list or not
  Future<void> setup() async {
    await associateWithBookStatus();

    if (!mounted) return;
    if (widget.bookStatus != null) {
      setState(() {
        futureReadingLogs = ReadingLogApi.getReadingLogs(widget.bookStatus!);
        futureBookNotes = BookNoteApi.getBookNotes(widget.bookStatus!.book);
        endDateEstimate = calculateEndOfReading();
        bookProgress = calculateProgress();
      });
    }
  }

  void setLoading() {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
  }

  void unsetLoading() {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  /// Check if the book is in the wanted list or not
  Future<void> associateWithBookStatus() async {
    await BookStatusApi.getAllBooks();
    if (!mounted) return;

    setState(() {
      bookStatus = BookStatusApi.findBookStatus(book, bookStatus: bookStatus);
      isWanted = bookStatus?.isWanted ?? false;
      isReading = bookStatus?.isReading ?? false;
      isReaded = bookStatus?.isReaded ?? false;
    });
  }

  /// Add [Book] to wanted list
  Future<void> setBookAsWanted() async {
    if (_isLoading) return;
    setLoading();

    final t = AppLocalizations.of(context)!;
    try {
      final TaskResponse response = await BookStatusApi.setWantedBook(book);
      if (response is TaskOkResponse) {
        book = (response.result as BookStatus).book;
        await associateWithBookStatus();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.translate('addedToWanted')),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.translate('errorAddingToWanted')),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
    unsetLoading();
  }

  /// Remove [Book] from wanted list
  Future<void> removeBookFromWanted() async {
    if (_isLoading) return;
    setLoading();
    final t = AppLocalizations.of(context)!;
    if (!isWanted || bookStatus?.book.id == null) {
      unsetLoading();
      return;
    }
    try {
      final TaskResponse response = await BookStatusApi.removeWantedBook(
        bookStatus!.book,
      );
      if (response.isSuccess) {
        await associateWithBookStatus();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.translate('removedFromWanted')),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.translate('errorRemovingFromWanted')),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
    unsetLoading();
  }

  /// Add [Book] to reading list
  Future<void> setBookAsReading() async {
    if (_isLoading) return;
    setLoading();
    final t = AppLocalizations.of(context)!;
    if (!isWanted || bookStatus?.book.id == null) {
      unsetLoading();
      return;
    }
    try {
      final TaskResponse response = await BookStatusApi.setReadingBook(
        bookStatus!.book,
      );
      if (response.isSuccess) {
        await associateWithBookStatus();
        widget.onStatusChanged();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.translate('addedToReading')),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.translate('errorAddingToReading')),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
    unsetLoading();
  }

  /// Set [Book] as readed
  Future<void> setBookAsReaded() async {
    if (_isLoading) return;
    setLoading();
    final t = AppLocalizations.of(context)!;
    if (!isReading || bookStatus?.book.id == null) {
      unsetLoading();
      return;
    }

    await setBookRate(called: true);

    try {
      final TaskResponse response = await BookStatusApi.setReadedBook(
        bookStatus!.book,
      );
      if (response.isSuccess) {
        await associateWithBookStatus();
        widget.onStatusChanged();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.translate('addedToReadedList')),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.translate('errorAddingToReaded')),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
    unsetLoading();
  }

  Future<void> setBookRate({bool called = false}) async {
    if (_isLoading && !called) return;
    setLoading();
    final t = AppLocalizations.of(context)!;
    final result = await showDialog(
      context: context,
      builder: (context) => BookRateDialog(initialValue: bookStatus?.rate),
    );
    if (result == null) {
      unsetLoading();
      return;
    }

    final (int? rate) = result;

    if (rate == null || rate < 0 || rate > 5 || bookStatus == null) {
      unsetLoading();
      return;
    }

    final TaskResponse response = await BookStatusApi.setBookRate(
      bookStatus!,
      rate,
    );

    if (response.isSuccess) {
      setup();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.translate('settedBookRate')),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
    unsetLoading();
  }

  Future<DateTime> calculateEndOfReading() async {
    final int dailyGoal = System.instance.dailyGoal?.value ?? 0;
    final int totalPages = bookStatus?.book.pageCount ?? 0;

    int totalReadedPages = 0;
    for (final ReadingLog rLog in await futureReadingLogs) {
      totalReadedPages += rLog.pagesReaded;
    }

    final double totalDaysLeft = (totalPages - totalReadedPages) / dailyGoal;
    return DateTime.now().add(Duration(days: totalDaysLeft.round()));
  }

  Future<double> calculateProgress() async {
    final int totalPages = book.pageCount;
    int totalReadedPages = 0;
    for (final rLog in await futureReadingLogs) {
      totalReadedPages += rLog.pagesReaded;
    }
    return totalPages == 0 ? 0 : totalReadedPages / totalPages * 100;
  }

  Future<void> createBookNote() async {
    if (_isLoading) return;
    setLoading();
    final t = AppLocalizations.of(context)!;
    final result = await showDialog(
      context: context,
      builder: (context) => BookNoteDialog(),
    );
    if (result == null) {
      unsetLoading();
      return;
    }

    final (int? page, String content) = result;

    if (content.isEmpty) {
      unsetLoading();
      return;
    }

    final TaskResponse response = await BookNoteApi.createBookNote(
      book,
      content,
      page: page,
    );

    if (response.isSuccess) {
      setup();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.translate('noteCreated')),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
    unsetLoading();
  }

  Future<void> updateBookNote(BookNote bookNote) async {
    if (_isLoading) return;
    setLoading();
    final t = AppLocalizations.of(context)!;
    final result = await showDialog(
      context: context,
      builder:
          (context) => BookNoteDialog(
            initialPage: bookNote.page,
            initialContent: bookNote.content,
          ),
    );
    if (result == null) {
      unsetLoading();
      return;
    }

    final (int? page, String content) = result;

    if (content.isEmpty) {
      unsetLoading();
      return;
    }

    final TaskResponse response = await BookNoteApi.updateBookNote(
      bookNote,
      content,
      page: page,
    );

    if (response.isSuccess) {
      setup();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.translate('updatedBookNote')),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
    unsetLoading();
  }

  Future<void> deleteBookNote(BookNote bookNote) async {
    if (_isLoading) return;
    setLoading();
    final t = AppLocalizations.of(context)!;

    final TaskResponse response = await BookNoteApi.deleteBookNote(bookNote);

    if (response.isSuccess) {
      setup();
      widget.onStatusChanged();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.translate('deletedBookNote')),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
    unsetLoading();
  }

  Future<void> deleteReadingLog(ReadingLog readingLog) async {
    if (_isLoading) return;
    setLoading();
    final t = AppLocalizations.of(context)!;

    final TaskResponse response = await ReadingLogApi.deleteReadingLog(
      readingLog,
    );

    if (response.isSuccess) {
      setup();
      widget.onStatusChanged();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.translate('deletedReadingLog')),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> exportBookToWord() async {
    final TaskResponse response = await DocxExporter.exportBookDocx(
      title: book.title,
      subtitle: book.subtitle,
      authors: book.authors,
      numPages: book.pageCount,
      notes: await futureBookNotes,
      coverUrl: book.thumbnail,
      locale: Localizations.localeOf(context),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.message), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(book.title),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.share), onPressed: exportBookToWord),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: kSpaceSizeBetweenWidgets),
                      Text(
                        book.subtitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: kSpaceSizeBetweenWidgets),
                      Text(book.authors.join(', ')),
                      // Text(bookStatus.book.categories.join(', ')),
                      const SizedBox(height: kSpaceSizeBetweenWidgets),
                      Text(
                        book.pageCount == 1
                            ? t.translate('pageNumber', {'page': '1'})
                            : t.translate('pagesNumber', {
                              'pages': book.pageCount.toString(),
                            }),
                      ),
                      if (isReading)
                        const SizedBox(height: kSpaceSizeBetweenWidgets),
                      if (isReading)
                        FutureBuilder(
                          future: endDateEstimate,
                          builder: (
                            BuildContext context,
                            AsyncSnapshot<DateTime?> snapshot,
                          ) {
                            if (snapshot.hasData) {
                              final DateTime? endDate = snapshot.data;
                              if (endDate != null) {
                                final String endDateString =
                                    Helper.getLocalDateString(endDate);
                                return Text(
                                  t.translate('estimatedToEnd', {
                                    'date': endDateString,
                                  }),
                                );
                              }
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                      if (isReading)
                        FutureBuilder(
                          future: bookProgress,
                          builder: (
                            BuildContext context,
                            AsyncSnapshot<double?> snapshot,
                          ) {
                            if (snapshot.hasData && snapshot.data != null) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.translate('readedPercentage')),
                                  Text(
                                    '${Helper.roundToString(snapshot.data!, decimalPlaces: 1)} %',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Text('0%');
                            }
                          },
                        ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    if (book.thumbnail != null && book.thumbnail!.isNotEmpty)
                      Image.network(book.thumbnail!),
                    if (bookStatus?.rate != null &&
                        bookStatus!.rate! >= 0 &&
                        bookStatus!.rate! <= 5)
                      GestureDetector(
                        child: StarDisplay(value: bookStatus!.rate!),
                        onTap: () => setBookRate(),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: kSpaceSizeBetweenWidgets),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!isWanted && !isReading)
                    TextButton.icon(
                      icon: const Icon(Icons.favorite_outline),
                      label: Text(t.translate('addToWanted')),
                      onPressed: setBookAsWanted,
                    ),
                  if (isWanted)
                    TextButton.icon(
                      icon: const Icon(Icons.heart_broken),
                      label: Text(t.translate('removeFromWanted')),
                      onPressed: removeBookFromWanted,
                    ),
                  if (isWanted && !isReading)
                    TextButton.icon(
                      icon: const Icon(Icons.bookmark),
                      label: Text(t.translate('startReading')),
                      onPressed: setBookAsReading,
                    ),
                  if (isReading)
                    TextButton.icon(
                      icon: const Icon(Icons.bookmark_added),
                      label: Text(t.translate('finishReading')),
                      onPressed: setBookAsReaded,
                    ),
                  if (isReaded) Text(t.translate('alreadyRead')),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: createBookNote,
                    child: Text(t.translate('createBookNote')),
                  ),
                ),
                if (isReading)
                  const SizedBox(width: 8), // Espaço entre os botões
                if (isReading)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        int? pages = await Helper.askNumber(
                          context,
                          t.translate('enterPagesReaded'),
                        );
                        if (pages == null) return;

                        final TaskResponse response =
                            await ReadingLogApi.createReadingLog(
                              bookStatus!,
                              pages,
                            );
                        if (response.isSuccess) {
                          setup();
                          widget.onCreatedReadingLog();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(t.translate('readingLogCreated')),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                      child: Text(t.translate('createReadingLog')),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: kSpaceSizeBetweenWidgets),
            ExpansionTile(
              title: Text(t.translate('readingLogs')),
              children: [
                FutureBuilder(
                  future: futureReadingLogs,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<List<ReadingLog>> snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(t.translate('errorLoadingLogs')),
                      );
                    } else if (snapshot.hasData) {
                      final rLogs = snapshot.data as List<ReadingLog>;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: rLogs.length,
                        itemBuilder: (context, index) {
                          final rLog = rLogs[index];
                          return Slidable(
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    deleteReadingLog(rLog);
                                  },
                                  icon: Icons.delete,
                                  // foregroundColor: Colors.red,
                                  backgroundColor: Colors.red,
                                ),
                              ],
                            ),
                            child: ReadingLogTile(
                              key: ValueKey(rLog.id),
                              readingLog: rLog,
                            ),
                          );
                        },
                      );
                    } else {
                      return Center(child: Text(t.translate('noData')));
                    }
                  },
                ),
              ],
            ),
            ExpansionTile(
              title: Text(t.translate('bookNotes')),
              children: [
                FutureBuilder(
                  future: futureBookNotes,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<List<BookNote>> snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(t.translate('errorLoadingNotes')),
                      );
                    } else if (snapshot.hasData) {
                      final bookNotes = snapshot.data as List<BookNote>;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: bookNotes.length,
                        itemBuilder: (context, index) {
                          final bookNote = bookNotes[index];
                          return Slidable(
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    deleteBookNote(bookNote);
                                  },
                                  icon: Icons.delete,
                                  foregroundColor: Colors.red,
                                ),
                              ],
                            ),
                            child: BookNoteTile(
                              key: ValueKey(bookNote.id),
                              bookNote: bookNote,
                              onPress: updateBookNote,
                            ),
                          );
                        },
                      );
                    } else {
                      return Center(child: Text(t.translate('noData')));
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
