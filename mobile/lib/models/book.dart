import 'dart:core';

import 'package:googleapis/books/v1.dart';
import 'package:bookread/models/book_status.dart';
import 'package:bookread/services/api_paths.dart';
import 'package:bookread/services/network.dart';
import 'package:bookread/utilities/task_response.dart';

mixin BookFields {
  static const String id = 'id';
  static const String apiId = 'apiId';
  static const String isbn10 = 'isbn10';
  static const String isbn13 = 'isbn13';
  static const String title = 'title';
  static const String subtitle = 'subtitle';
  static const String authors = 'authors';
  static const String categories = 'categories';
  static const String description = 'description';
  static const String publisher = 'publisher';
  static const String publishedDate = 'pubDate';
  static const String pageCount = 'pageCount';
  static const String thumbnail = 'imageUrl';
  static const String language = 'language';
}

class Book {
  Book({
    this.id,
    this.apiId,
    this.isbn10,
    this.isbn13,
    required this.title,
    required this.subtitle,
    required this.authors,
    required this.categories,
    this.description,
    this.publisher,
    this.publishedDate,
    required this.pageCount,
    this.thumbnail,
    required this.language,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: BigInt.tryParse(json[BookFields.id] as String),
      apiId: json[BookFields.apiId] as String?,
      isbn10: json[BookFields.isbn10] as String?,
      isbn13: json[BookFields.isbn13] as String?,
      title: json[BookFields.title] as String,
      subtitle:
          json[BookFields.subtitle] == null
              ? ''
              : json[BookFields.subtitle] as String,
      description: json[BookFields.description] as String?,
      authors:
          json[BookFields.authors] == null
              ? []
              : List<String>.from(json[BookFields.authors]),
      categories:
          json[BookFields.categories] == null
              ? []
              : List<String>.from(json[BookFields.categories]),
      pageCount:
          json[BookFields.pageCount] == null
              ? 0
              : json[BookFields.pageCount] as int,
      publisher: json[BookFields.publisher] as String?,
      publishedDate:
          json[BookFields.publishedDate] == null
              ? null
              : DateTime.parse(json[BookFields.publishedDate]),
      thumbnail: json[BookFields.thumbnail] as String?,
      language:
          json[BookFields.language] == null
              ? ''
              : json[BookFields.language] as String,
    );
  }

  factory Book.fromApi(Volume item) {
    final List<VolumeVolumeInfoIndustryIdentifiers>? industryIdentifiers =
        item.volumeInfo?.industryIdentifiers;
    final String isbn10 =
        industryIdentifiers
            ?.firstWhere(
              (identifier) => identifier.type == 'ISBN_10',
              orElse:
                  () => VolumeVolumeInfoIndustryIdentifiers(
                    type: '',
                    identifier: '',
                  ),
            )
            .identifier ??
        '';
    final String isbn13 =
        industryIdentifiers
            ?.firstWhere(
              (identifier) => identifier.type == 'ISBN_13',
              orElse:
                  () => VolumeVolumeInfoIndustryIdentifiers(
                    type: '',
                    identifier: '',
                  ),
            )
            .identifier ??
        '';

    return Book(
      apiId: item.id ?? '',
      isbn10: isbn10,
      isbn13: isbn13,
      title: item.volumeInfo?.title ?? '',
      subtitle: item.volumeInfo?.subtitle ?? '',
      authors: item.volumeInfo?.authors ?? [],
      pageCount: item.volumeInfo?.pageCount ?? 0,
      categories: item.volumeInfo?.categories ?? [],
      publisher: item.volumeInfo?.publisher ?? '',
      publishedDate:
          item.volumeInfo?.publishedDate != null
              ? DateTime.tryParse(item.volumeInfo!.publishedDate!)
              : null,
      description: item.volumeInfo?.description ?? '',
      thumbnail: item.volumeInfo?.imageLinks?.thumbnail ?? '',
      language: item.volumeInfo?.language ?? '',
    );
  }

  final BigInt? id;
  final String? apiId;
  final String? isbn10;
  final String? isbn13;
  final String title;
  final String subtitle;
  final List<String> authors;
  final List<String> categories;
  final String? description;
  final String? publisher;
  final DateTime? publishedDate;
  final int pageCount;
  final String? thumbnail;
  final String language;

  Map<String, dynamic> toJson() {
    return {
      BookFields.id: id,
      BookFields.apiId: apiId,
      BookFields.isbn10: isbn10,
      BookFields.isbn13: isbn13,
      BookFields.title: title,
      BookFields.subtitle: subtitle,
      BookFields.authors: authors,
      BookFields.categories: categories,
      BookFields.pageCount: pageCount,
      BookFields.publisher: publisher,
      BookFields.publishedDate: publishedDate?.toIso8601String(),
      BookFields.description: description,
      BookFields.thumbnail: thumbnail,
      BookFields.language: language,
    };
  }

  bool get isWanted => BookStatusApi.wantedBooks.any(
    (bookStatus) => bookStatus.book.apiId == apiId,
  );

  bool get isReading => BookStatusApi.readingBooks.any(
    (bookStatus) => bookStatus.book.apiId == apiId,
  );
}

mixin BookApi {
  static Future<TaskResponse> createBook(Book book) async {
    final String url = ApiPaths.book();
    final Network networkService = Network(url);

    final TaskResponse response = await networkService.postData(
      body: book.toJson(),
    );
    if (response is TaskOkResponse) {
      return TaskOkResponse();
    } else {
      return response;
    }
  }
}
