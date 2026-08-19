import 'package:flutter/material.dart';
import 'package:bookread/models/reading_log.dart';
import 'package:bookread/utilities/helper.dart';

class ReadingLogTile extends StatelessWidget {
  const ReadingLogTile({super.key, required this.readingLog});

  final ReadingLog readingLog;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey(readingLog.id),
      title: Text(readingLog.pagesReaded.toString()),
      subtitle:
          readingLog.duration == null
              ? null
              : Text(Duration(seconds: readingLog.duration!).toString()),
      trailing: Text(Helper.getLocalDateTimeString(readingLog.createdAt)),
    );
  }
}
