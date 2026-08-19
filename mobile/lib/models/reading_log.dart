import 'dart:convert';

import 'package:bookread/models/book_status.dart';
import 'package:bookread/services/api_paths.dart';
import 'package:bookread/services/network.dart';
import 'package:bookread/utilities/task_response.dart';

mixin ReadingLogFields {
  static const String id = 'id';
  static const String bookStatusId = 'bStatusId';
  static const String bookStatus = 'bookStatus';
  static const String duration = 'duration';
  static const String pagesReaded = 'pagesReaded';
  static const String createdAt = 'createdAt';
  static const String count = 'count';
}

class ReadingLog {
  ReadingLog({
    required this.id,
    required this.bookStatusId,
    required this.duration,
    required this.pagesReaded,
    required this.createdAt,
  });

  factory ReadingLog.fromJson(Map<String, dynamic> json) {
    return ReadingLog(
      id: BigInt.parse(json[ReadingLogFields.id] as String),
      bookStatusId: BigInt.parse(json[ReadingLogFields.bookStatusId] as String),
      duration: json[ReadingLogFields.duration] as int?,
      pagesReaded: json[ReadingLogFields.pagesReaded] as int,
      createdAt: DateTime.parse(json[ReadingLogFields.createdAt]),
    );
  }

  final BigInt id;
  final BigInt bookStatusId;
  final int? duration;
  final int pagesReaded;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      ReadingLogFields.id: id.toString(),
      ReadingLogFields.bookStatusId: bookStatusId.toString(),
      ReadingLogFields.duration: duration,
      ReadingLogFields.pagesReaded: pagesReaded,
      ReadingLogFields.createdAt: createdAt.toIso8601String(),
    };
  }
}

mixin ReadingLogApi {
  static Future<List<ReadingLog>> getReadingLogs(BookStatus bookStatus) async {
    final String url = ApiPaths.readingLogsByBookStatus(
      bookStatus.id.toString(),
    );
    final Network networkService = Network(url);

    final TaskResponse response = await networkService.getData();
    if (response is TaskOkResponse) {
      final String? result = response.result;
      if (result == null || result.isEmpty) return [];

      final json = jsonDecode(result) as Iterable;

      return List<ReadingLog>.from(
        json.map((item) => ReadingLog.fromJson(item as Map<String, dynamic>)),
      );
    } else {
      return [];
    }
  }

  static Future<TaskResponse> createReadingLog(
    BookStatus bookStatus,
    int pagesReaded, {
    int? duration,
  }) async {
    final String url = ApiPaths.readingLogs();
    final Network networkService = Network(url);

    final TaskResponse response = await networkService.postData(
      body: {
        ReadingLogFields.bookStatusId: bookStatus.id.toString(),
        ReadingLogFields.duration: duration,
        ReadingLogFields.pagesReaded: pagesReaded,
      },
    );

    if (response.isSuccess) {
      return TaskOkResponse();
    } else {
      return response;
    }
  }

    static Future<TaskResponse> deleteReadingLog(
    ReadingLog readingLog,{
    int? duration,
  }) async {
    final String url = ApiPaths.readingLogs();
    final Network networkService = Network(url);

    final TaskResponse response = await networkService.deleteData(
      body: {
        ReadingLogFields.id: readingLog.id.toString(),
      },
    );

    if (response.isSuccess) {
      return TaskOkResponse();
    } else {
      return response;
    }
  }

  static Future<TaskResponse> countReadedPagesByDate(DateTime date) async {
    final String url = ApiPaths.countReadedPagesByDate(date);
    final Network networkService = Network(url);

    final TaskResponse response = await networkService.getData();

    if (response is TaskOkResponse) {
      final Map<String, dynamic> json = jsonDecode(response.result);
      final int count = json[ReadingLogFields.count] as int;
      return TaskOkResponse(result: count);
    } else {
      return response;
    }
  }
}
