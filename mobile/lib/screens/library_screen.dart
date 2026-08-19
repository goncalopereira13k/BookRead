import 'package:flutter/material.dart';
import 'package:bookread/app_localizations.dart';
import 'package:bookread/components/book_tile.dart';
import 'package:bookread/models/book_status.dart';
import 'package:bookread/screens/book_screen.dart';
import 'package:bookread/utilities/constants.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({
    super.key,
    required this.onCreatedReadingLog,
    required this.onStatusChanged,
  });
  static const String id = 'library_screen';

  final VoidCallback onCreatedReadingLog;
  final VoidCallback onStatusChanged;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with TickerProviderStateMixin {
  Future<List<BookStatus>?> _futureBooksStatus = Future.value([]);
  BookStatusType? _selectedStatus;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: BookStatusType.values.length,
      vsync: this,
    );
    _tabController.addListener(() {
      setState(() {});
    });
    setupBooksStatus();
  }

  Future<void> setupBooksStatus() async {
    final allBooks = await BookStatusApi.getAllBooks();
    if (!mounted) return;
    setState(() {
      _futureBooksStatus = Future.value(
        _selectedStatus == null
            ? allBooks
            : allBooks.where((book) => book.status == _selectedStatus).toList(),
      );
    });
  }

  List<BookStatus> _filteredBooks(List<BookStatus> books) {
    final index = _tabController.index;
    return books
        .where((b) => b.status == BookStatusType.values[index])
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: BookStatusType.values.length,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: [
              ...BookStatusType.values.map(
                (status) => Tab(text: t.translate(status.name)),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder(
              future: _futureBooksStatus,
              builder: (
                BuildContext context,
                AsyncSnapshot<List<BookStatus>?> snapshot,
              ) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: Text(t.translate('errorLoadingData')));
                } else if (snapshot.hasError) {
                  return Center(child: Text(t.translate('errorLoadingData')));
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final booksStatus = snapshot.data as List<BookStatus>;
                  final filteredBooks = _filteredBooks(booksStatus);

                  if (filteredBooks.isEmpty) {
                    return Center(child: Text(t.translate('noBooksHere')));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredBooks.length,
                    itemBuilder: (context, index) {
                      final bStatus = filteredBooks[index];
                      return BookTile(
                        key: ValueKey(bStatus.book.id),
                        book: bStatus.book,
                        bookStatus: bStatus,
                        onStatusChanged: widget.onStatusChanged,
                        onTileStatusChanged: setupBooksStatus,
                        onTap: (bookStatus) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => BookScreen(
                                    book: bStatus.book,
                                    bookStatus: bStatus,
                                    onCreatedReadingLog:
                                        widget.onCreatedReadingLog,
                                    onStatusChanged: widget.onStatusChanged,
                                  ),
                            ),
                          ).then((value) {
                            setupBooksStatus(); // Refresh list
                          });
                        },
                      );
                    },
                  );
                } else {
                  return Center(child: Text(t.translate('addBooksPrompt')));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
