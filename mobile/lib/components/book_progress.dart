import 'package:flutter/material.dart';
import 'package:bookread/app_localizations.dart';
import 'package:bookread/models/book_status.dart';
import 'package:bookread/models/reading_log.dart';
import 'package:bookread/providers/theme_provider.dart';
import 'package:bookread/screens/book_screen.dart';
import 'package:bookread/utilities/constants.dart';
import 'package:bookread/utilities/helper.dart';
import 'package:provider/provider.dart';

class BookProgress extends StatefulWidget {
  const BookProgress({
    super.key,
    required this.bStatus,
    required this.onCreatedReadingLog,
    required this.onStatusChanged,
  });

  final BookStatus bStatus;
  final VoidCallback onCreatedReadingLog;
  final VoidCallback onStatusChanged;

  @override
  State<BookProgress> createState() => _BookProgressState();
}

class _BookProgressState extends State<BookProgress> {
  Future<List<ReadingLog>> futureReadingLogs = Future.value([]);

  @override
  void initState() {
    super.initState();

    setupReadingLogs();
  }

  void setupReadingLogs() {
    setState(() {
      futureReadingLogs = ReadingLogApi.getReadingLogs(widget.bStatus);
    });
  }

  double _calculateProgress(List<ReadingLog> readingLogs) {
    final int totalPages = widget.bStatus.book.pageCount;

    int totalReadedPages = 0;
    for (final ReadingLog rLog in readingLogs) {
      totalReadedPages += rLog.pagesReaded;
    }

    return totalPages == 0 ? 0 : totalReadedPages / totalPages * 100;
  }

  ImageProvider _getImageProvider() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    if (widget.bStatus.book.thumbnail == null) {
      return AssetImage(
        themeProvider.isDarkMode
            ? 'assets/images/logo_night.png'
            : 'assets/images/logo_day.png',
      );
    }
    return NetworkImage(widget.bStatus.book.thumbnail!);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => BookScreen(
                  book: widget.bStatus.book,
                  bookStatus: widget.bStatus,
                  onCreatedReadingLog: () {
                    widget.onCreatedReadingLog();
                    setupReadingLogs();
                  },
                  onStatusChanged: widget.onStatusChanged,
                ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 200, // Altura do botão
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kRadiusLarge),
          image: DecorationImage(image: _getImageProvider(), fit: BoxFit.cover),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(kRadiusLarge),
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.bStatus.book.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: kSpaceSizeBetweenWidgets),
                  FutureBuilder(
                    future: futureReadingLogs,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(t.translate('errorLoadingData')),
                        );
                      } else if (snapshot.hasData) {
                        List<ReadingLog> readingLogs = snapshot.data;
                        final double progress = _calculateProgress(readingLogs);

                        return Text(
                          '${Helper.roundToString(progress, decimalPlaces: 1)} %',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      } else {
                        return Text(
                          '0%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
