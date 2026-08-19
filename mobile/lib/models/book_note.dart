import 'dart:convert';

import 'package:bookread/models/book.dart';
import 'package:bookread/services/api_paths.dart';
import 'package:bookread/services/network.dart';
import 'package:bookread/utilities/constants.dart';
import 'package:bookread/utilities/task_response.dart';

mixin BookNoteFields {
  static const String id = 'id';
  static const String bookId = 'bookId';
  static const String page = 'page';
  static const String content = 'content';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
}

class BookNote {
  BookNote({
    this.id,
    required this.bookId,
    this.page,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookNote.fromJson(Map<String, dynamic> json) => BookNote(
    id:
        json[BookNoteFields.id] == null
            ? null
            : BigInt.tryParse(json[BookNoteFields.id] as String),
    bookId: BigInt.parse(json[BookNoteFields.bookId] as String),
    page: json[BookNoteFields.page] as int?,
    content: json[BookNoteFields.content] as String,
    createdAt: DateTime.parse(json[BookNoteFields.createdAt] as String),
    updatedAt: DateTime.parse(json[BookNoteFields.updatedAt] as String),
  );

  BigInt? id;
  BigInt bookId;
  int? page;
  String content;
  DateTime createdAt;
  DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    BookNoteFields.id: id?.toString(),
    BookNoteFields.bookId: bookId.toString(),
    BookNoteFields.page: page,
    BookNoteFields.content: content,
    BookNoteFields.createdAt: createdAt.toIso8601String(),
    BookNoteFields.updatedAt: updatedAt.toIso8601String(),
  };
}

mixin BookNoteApi {
  static Future<List<BookNote>> getBookNotes(Book book) async {
    final String url = ApiPaths.getBookNotes(book);
    final Network networkService = Network(url);

    final TaskResponse response = await networkService.getData();
    if (response is TaskOkResponse) {
      final String? result = response.result;
      if (result == null || result.isEmpty) return [];

      final json = jsonDecode(result) as Iterable;

      return List<BookNote>.from(
        json.map((item) => BookNote.fromJson(item as Map<String, dynamic>)),
      );
    } else {
      return [];
    }
  }

  static Future<TaskResponse> createBookNote(
    Book book,
    String content, {
    int? page,
  }) async {
    if (book.id == null) {
      return TaskBadResponse(
        errorCode: ErrorCode.nullArgument,
        message: 'Book id can\'t be null',
      );
    }

    final String url = ApiPaths.getBookNotes(book);
    final Network networkService = Network(url);

    final TaskResponse response = await networkService.postData(
      body: {
        BookNoteFields.bookId: book.id!.toString(),
        BookNoteFields.content: content.trim(),
        BookNoteFields.page: page,
      },
    );

    if (response is TaskOkResponse) {
      return TaskOkResponse();
    } else {
      return response;
    }
  }

  static Future<TaskResponse> updateBookNote(
    BookNote bookNote,
    String content, {
    int? page,
  }) async {
    if (bookNote.id == null) {
      return TaskBadResponse(
        errorCode: ErrorCode.nullArgument,
        message: 'BookNote id can\'t be null',
      );
    }

    final String url = ApiPaths.bookNotes();
    final Network networkService = Network(url);

    final TaskResponse response = await networkService.updateData(
      body: {
        BookNoteFields.id: bookNote.id!.toString(),
        BookNoteFields.content: content.trim(),
        BookNoteFields.page: page,
      },
    );

    if (response is TaskOkResponse) {
      return TaskOkResponse();
    } else {
      return response;
    }
  }

  static Future<TaskResponse> deleteBookNote(BookNote bookNote) async {
    final String url = ApiPaths.bookNotes();
    final Network networkService = Network(url);

    final TaskResponse response = await networkService.deleteData(
      body: {BookNoteFields.id: bookNote.id.toString()},
    );

    if (response is TaskOkResponse) {
      return TaskOkResponse();
    } else {
      return response;
    }
  }
}
