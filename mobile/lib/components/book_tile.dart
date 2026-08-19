import 'package:flutter/material.dart';
import 'package:bookread/app_localizations.dart';
import 'package:bookread/models/book.dart';
import 'package:bookread/models/book_status.dart';
import 'package:bookread/utilities/task_response.dart';

class BookTile extends StatefulWidget {
  const BookTile({
    super.key,
    required this.book,
    this.bookStatus,
    required this.onStatusChanged,
    required this.onTap,
    this.onTileStatusChanged,
  });

  final Book book;
  final BookStatus? bookStatus;
  final VoidCallback onStatusChanged;
  final VoidCallback? onTileStatusChanged;
  final void Function(BookStatus?) onTap;

  @override
  State<BookTile> createState() => _BookTileState();
}

class _BookTileState extends State<BookTile> {
  bool isWanted = false;
  bool isReading = false;
  bool isReaded = false;
  bool _isLoading = false;
  BookStatus? bookStatus;

  @override
  void initState() {
    super.initState();
    bookStatus = widget.bookStatus;
    associateWithBookStatus();
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

  Future<void> associateWithBookStatus() async {
    await BookStatusApi.getAllBooks();
    if (!mounted) return;
    setState(() {
      bookStatus = BookStatusApi.findBookStatus(
        widget.book,
        bookStatus: bookStatus,
      );
      isWanted = bookStatus?.isWanted ?? false;
      isReading = bookStatus?.isReading ?? false;
      isReaded = bookStatus?.isReaded ?? false;
    });
  }

  /// Add [Book] to wanted list
  Future<void> addBookToWanted() async {
    if (_isLoading) return;
    setLoading();
    final t = AppLocalizations.of(context)!;
    try {
      final TaskResponse response = await BookStatusApi.setWantedBook(
        widget.book,
      );
      if (response.isSuccess) {
        if (widget.onTileStatusChanged != null) {
          widget.onTileStatusChanged!();
        }
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
    if (bookStatus?.book.id == null) {
      unsetLoading();
      return;
    }

    try {
      final TaskResponse response = await BookStatusApi.removeWantedBook(
        bookStatus!.book,
      );
      if (response.isSuccess) {
        if (widget.onTileStatusChanged != null) {
          widget.onTileStatusChanged!();
        }
        await associateWithBookStatus();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.translate('removedFromWanted')),
              duration: const Duration(seconds: 2),
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
        if (widget.onTileStatusChanged != null) {
          widget.onTileStatusChanged!();
        }
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
    try {
      final TaskResponse response = await BookStatusApi.setReadedBook(
        bookStatus!.book,
      );
      if (response.isSuccess) {
        if (widget.onTileStatusChanged != null) {
          widget.onTileStatusChanged!();
        }
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

  Widget? buildTrailingIcon() {
    if (bookStatus == null) {
      return IconButton(
        icon: const Icon(Icons.favorite_outline),
        onPressed: addBookToWanted,
      );
    } else if (isWanted) {
      return IconButton(
        icon: const Icon(Icons.heart_broken),
        onPressed: removeBookFromWanted,
      );
    } else if (isWanted && !isReading) {
      return IconButton(
        icon: const Icon(Icons.bookmark),
        onPressed: setBookAsReading,
      );
    } else if (isReading) {
      return IconButton(
        icon: const Icon(Icons.bookmark_added),
        onPressed: setBookAsReaded,
      );
    } else if (isReaded) {
      return IconButton(icon: const Icon(Icons.done), onPressed: null);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey(widget.book.apiId),
      title: Text(widget.book.title),
      subtitle: Text(widget.book.authors.join(', ')),
      leading:
          widget.book.thumbnail == null
              ? null
              : (widget.book.thumbnail!.isNotEmpty
                  ? Image.network(widget.book.thumbnail!)
                  : null),
      trailing: buildTrailingIcon(),
      onTap: () => widget.onTap(bookStatus),
    );
  }
}
