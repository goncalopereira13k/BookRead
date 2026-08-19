import 'dart:convert';

import 'package:bookread/models/book.dart';
import 'package:bookread/services/api_paths.dart';
import 'package:bookread/services/network.dart';
import 'package:bookread/utilities/constants.dart';
import 'package:bookread/utilities/task_response.dart';

mixin BookStatusFields {
  static const String id = 'id';
  static const String book = 'book';
  static const String status = 'status';
  static const String startDate = 'startDate';
  static const String endDate = 'endDate';
  static const String count = 'count';
  static const String rate = 'rate';
}

class BookStatus {
  BookStatus({
    required this.id,
    required this.book,
    required this.status,
    this.startDate,
    this.endDate,
    this.rate,
  });

  factory BookStatus.fromJson(Map<String, dynamic> json) {
    return BookStatus(
      id: BigInt.parse(json[BookStatusFields.id] as String),
      book: Book.fromJson(json[BookStatusFields.book]),
      status: BookStatusType.values[json[BookStatusFields.status] as int],
      startDate:
          json[BookStatusFields.startDate] != null
              ? DateTime.parse(json[BookStatusFields.startDate])
              : null,
      endDate:
          json[BookStatusFields.endDate] != null
              ? DateTime.parse(json[BookStatusFields.endDate])
              : null,
      rate: json[BookStatusFields.rate] != null
          ? json[BookStatusFields.rate] as int
          : null,
    );
  }

  BigInt id;
  Book book;
  BookStatusType status;
  DateTime? startDate;
  DateTime? endDate;
  int? rate;

  Map<String, dynamic> toJson() {
    return {
      BookStatusFields.id: id.toString(),
      BookStatusFields.book: book.toJson(),
      BookStatusFields.status: status.name,
      BookStatusFields.startDate: startDate?.toIso8601String(),
      BookStatusFields.endDate: endDate?.toIso8601String(),
      BookStatusFields.rate: rate,
    };
  }

  bool get isWanted => status == BookStatusType.wanted;
  bool get isReading => status == BookStatusType.reading;
  bool get isReaded => status == BookStatusType.readed;
  bool get isArchived => status == BookStatusType.archived;
}

mixin BookStatusApi {
  static List<BookStatus> allBooks = [];
  static List<BookStatus> wantedBooks = [];
  static List<BookStatus> readingBooks = [];
  static List<BookStatus> readedBooks = [];

  static BookStatus? findBookStatus(
    Book book, {
    BookStatus? bookStatus,
    BookStatusType? statusType,
  }) {
    // If bookStatus is not null, then compare by bookStatus.id
    // Else if statusType is not null, then compare by book and statusType
    // Else if book.apiId is not null, then compare by book.apiId
    // Else compare by book.id
    List<BookStatus> status =
        allBooks.where((bStatus) {
          if (bookStatus != null) {
            return bStatus.id == bookStatus.id;
          }

          final bool hasId = book.id != null;
          final bool hasApiId = book.apiId != null;

          if (statusType != null) {
            if (hasId) {
              return bStatus.status == statusType && bStatus.book.id == book.id;
            }
            if (hasApiId) {
              return bStatus.status == statusType &&
                  bStatus.book.apiId == book.apiId;
            }
            return false;
          }

          if (hasId) {
            return bStatus.book.id == book.id;
          }
          if (hasApiId) {
            return bStatus.book.apiId == book.apiId;
          }

          return false;
        }).toList();
    status.sort((a, b) {
      if (a.status.index > b.status.index) return 1;
      if (a.status.index < b.status.index) return -1;
      return 0;
    });
    return status.firstOrNull;
  }

  static Future<List<BookStatus>> getAllBooks() async {
    final String url = ApiPaths.allBooks();
    final Network networkService = Network(url);

    final TaskResponse response = await networkService.getData();

    if (response is TaskOkResponse) {
      final String? result = response.result;
      if (result == null || result.isEmpty) return allBooks = [];

      final json = jsonDecode(result) as Iterable;

      allBooks = List<BookStatus>.from(
        json.map((item) => BookStatus.fromJson(item as Map<String, dynamic>)),
      );
      return allBooks;
    } else {
      return [];
    }
  }

  static Future<List<BookStatus>> getWantedBooks() async {
    final String url = ApiPaths.wantedBooks();
    final Network networkService = Network(url);

    final TaskResponse response = await networkService.getData();

    if (response is TaskOkResponse) {
      final String? result = response.result;
      if (result == null || result.isEmpty) return wantedBooks = [];

      final json = jsonDecode(result) as Iterable;

      wantedBooks = List<BookStatus>.from(
        json.map((item) => BookStatus.fromJson(item as Map<String, dynamic>)),
      );

      return wantedBooks;
    } else {
      return [];
    }
  }

  static Future<TaskResponse> setWantedBook(Book book) async {
    final String url = ApiPaths.wantedBooks();
    final Network networkService = Network(url);

    final TaskResponse response = await networkService.postData(
      body: {BookFields.apiId: book.apiId},
    );

    if (response is TaskOkResponse) {
      final Map<String, dynamic> json = jsonDecode(response.result);
      return TaskOkResponse(result: BookStatus.fromJson(json));
    } else {
      return response;
    }
  }

  static Future<TaskResponse> removeWantedBook(Book book) async {
    final String url = ApiPaths.wantedBooks();
    final Network networkService = Network(url);

    final TaskResponse response = await networkService.deleteData(
      body: {BookFields.id: book.id.toString()},
    );

    if (response.isSuccess) {
      return TaskOkResponse();
    } else {
      return response;
    }
  }

  /// Get all reading books
  static Future<List<BookStatus>> getReadingBooks() async {
    final String url = ApiPaths.readingBooks();
    final Network networkService = Network(url);

    final TaskResponse response = await networkService.getData();

    if (response is TaskOkResponse) {
      final String? result = response.result;
      if (result == null || result.isEmpty) return readingBooks = [];

      final json = jsonDecode(result) as Iterable;

      readingBooks = List<BookStatus>.from(
        json.map((item) => BookStatus.fromJson(item as Map<String, dynamic>)),
      );

      return readingBooks;
    } else {
      return [];
    }
  }

  static Future<TaskResponse> setReadingBook(Book book) async {
    final String url = ApiPaths.readingBooks();
    final Network networkService = Network(url);

    final TaskResponse response = await networkService.postData(
      body: {BookFields.id: book.id.toString()},
    );

    if (response.isSuccess) {
      return TaskOkResponse();
    } else {
      return response;
    }
  }

  static Future<TaskResponse> removeReadingBook(Book book) async {
    final String url = ApiPaths.readingBooks();
    final Network networkService = Network(url);

    final TaskResponse response = await networkService.deleteData(
      body: {BookFields.id: book.id.toString()},
    );

    if (response.isSuccess) {
      return TaskOkResponse();
    } else {
      return response;
    }
  }

  /// Get all readed books
  static Future<List<BookStatus>> getReadedBooks() async {
    final String url = ApiPaths.readedBooks();
    final Network networkService = Network(url);

    final TaskResponse response = await networkService.getData();

    if (response is TaskOkResponse) {
      final String? result = response.result;
      if (result == null || result.isEmpty) return readedBooks = [];

      final json = jsonDecode(result) as Iterable;

      readedBooks = List<BookStatus>.from(
        json.map((item) => BookStatus.fromJson(item as Map<String, dynamic>)),
      );

      return readedBooks;
    } else {
      return [];
    }
  }

  /// Set [Book] as readed
  static Future<TaskResponse> setReadedBook(Book book) async {
    final String url = ApiPaths.readedBooks();
    final Network networkService = Network(url);

    final TaskResponse response = await networkService.postData(
      body: {BookFields.id: book.id.toString()},
    );

    if (response.isSuccess) {
      return TaskOkResponse();
    } else {
      return response;
    }
  }

  static Future<TaskResponse> countReadedBooksByYear(DateTime date) async {
    final String url = ApiPaths.countReadedBooksByYear(date);
    final Network networkService = Network(url);

    final TaskResponse response = await networkService.getData();

    if (response is TaskOkResponse) {
      final Map<String, dynamic> json = jsonDecode(response.result);
      final int count = json[BookStatusFields.count] as int;
      return TaskOkResponse(result: count);
    } else {
      return response;
    }
  }

  static Future<TaskResponse> setBookRate(BookStatus bookStatus, int rate) async {
    final String url = ApiPaths.setBookRate();
    final Network networkService = Network(url);

    final TaskResponse response = await networkService.postData(
      body: {BookStatusFields.id: bookStatus.id.toString(),
      BookStatusFields.rate: rate},
    );

    if (response.isSuccess) {
      return TaskOkResponse();
    } else {
      return response;
    }
  }
}
