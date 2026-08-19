import 'package:flutter/material.dart';
import 'package:bookread/models/book_note.dart';
import 'package:bookread/utilities/helper.dart';

class BookNoteTile extends StatefulWidget {
  const BookNoteTile({
    super.key,
    required this.bookNote,
    required this.onPress,
  });

  final BookNote bookNote;
  final void Function(BookNote bookNote) onPress;

  @override
  State<BookNoteTile> createState() => _BookNoteTileState();
}

class _BookNoteTileState extends State<BookNoteTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey(widget.bookNote.id),
      title: Text(Helper.getLocalDateTimeString(widget.bookNote.updatedAt)),
      subtitle: Text(widget.bookNote.content),
      trailing:
          widget.bookNote.page == null
              ? null
              : Text(widget.bookNote.page.toString()),
      onTap: () => widget.onPress(widget.bookNote),
    );
  }
}
