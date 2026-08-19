import 'package:flutter/material.dart';
import 'package:bookread/app_localizations.dart';
import 'package:bookread/components/book_tile.dart';
import 'package:bookread/models/book.dart';
import 'package:bookread/screens/book_screen.dart';
import 'package:bookread/services/googleapi.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.searchQuery,
    required this.onCreatedReadingLog,
    required this.onStatusChanged,
  });

  static const String id = 'search_screen';

  final String searchQuery;
  final VoidCallback onCreatedReadingLog;
  final VoidCallback onStatusChanged;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with AutomaticKeepAliveClientMixin {
  Future<List<Book>?> _futureBooks = Future.value([]);

  @override
  void didUpdateWidget(covariant SearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      setupBooks();
    }
  }

  void setupBooks() {
    if (widget.searchQuery.isEmpty) {
      setState(() {
        _futureBooks = Future.value([]);
      });
      return;
    }

    setState(() {
      _futureBooks = GoogleBooksApi.searchBooks(widget.searchQuery);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final t = AppLocalizations.of(context)!;

    return FutureBuilder(
      future: _futureBooks,
      builder: (BuildContext context, AsyncSnapshot<List<Book>?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Text(t.translate('loading')));
        } else if (snapshot.hasError) {
          return Center(child: Text(t.translate('errorLoadingData')));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final books = snapshot.data as List<Book>;
          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return BookTile(
                key: ValueKey(book.apiId),
                book: book,
                onStatusChanged: widget.onStatusChanged,
                onTap: (bookStatus) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => BookScreen(
                            book: book,
                            bookStatus: bookStatus,
                            onCreatedReadingLog: widget.onCreatedReadingLog,
                            onStatusChanged: widget.onStatusChanged,
                          ),
                    ),
                  );
                },
              );
            },
          );
        } else {
          return Center(child: Text(t.translate('typeToSeeResults')));
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
