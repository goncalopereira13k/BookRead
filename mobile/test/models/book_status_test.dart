import 'package:flutter_test/flutter_test.dart';
import 'package:bookread/models/book.dart';
import 'package:bookread/models/book_status.dart';
import 'package:bookread/utilities/constants.dart';

void main() {
  group('BookStatus', () {
    group('fromJson', () {
      test('should create an instance from JSON with all values', () {
        final json = {
          BookStatusFields.id: '1234',
          BookStatusFields.book: {
            BookFields.id: '1234',
            BookFields.apiId: 'api1234',
            BookFields.isbn10: '1234567890',
            BookFields.isbn13: '1234567890123',
            BookFields.title: 'Test Book',
            BookFields.subtitle: 'A Subtitle',
            BookFields.authors: ['Author One', 'Author Two'],
            BookFields.categories: ['Fiction', 'Adventure'],
            BookFields.description: 'A description of the test book.',
            BookFields.publisher: 'Test Publisher',
            BookFields.publishedDate: '2023-10-01',
            BookFields.pageCount: 300,
            BookFields.thumbnail: 'http://example.com/thumbnail.jpg',
            BookFields.language: 'en',
          },
          BookStatusFields.status: 1,
          BookStatusFields.startDate: '2023-10-01T12:00:00Z',
          BookStatusFields.endDate: '2023-10-15T12:00:00Z',
        };

        final bookStatus = BookStatus.fromJson(json);

        expect(bookStatus.id, isA<BigInt>());
        expect(bookStatus.id.toString(), '1234');
        expect(bookStatus.book, isA<Book>());
        expect(bookStatus.status, isA<BookStatusType>());
        expect(bookStatus.status, BookStatusType.reading);
        expect(bookStatus.startDate, DateTime.parse('2023-10-01T12:00:00Z'));
        expect(bookStatus.endDate, DateTime.parse('2023-10-15T12:00:00Z'));
      });

      test(
        'should fail to create an instance from JSON with missing values',
        () {
          final json = {BookStatusFields.id: '1234'};

          expect(() => BookStatus.fromJson(json), throwsA(isA<TypeError>()));
        },
      );
    });
  });

  group('BookStatusApi', () {
    setUp(() {
      final json = [
        {
          'id': '3',
          'book': {
            'id': '3',
            'apiId': null,
            'isbn10': null,
            'isbn13': null,
            'title': 'h',
            'subtitle': 'h',
            'authors': ['h'],
            'categories': ['h'],
            'publisher': null,
            'pubDate': null,
            'pageCount': 3,
            'imageUrl': null,
            'language': 'pt',
            'description': null,
            'createdAt': '2025-06-14T22:25:15.506Z',
            'updatedAt': '2025-06-14T22:25:15.506Z',
          },
          'status': 0,
          'startDate': null,
          'endDate': null,
          'createdAt': '2025-06-14T22:25:15.523Z',
          'updatedAt': '2025-06-14T22:25:15.523Z',
        },
        {
          'id': '4',
          'book': {
            'id': '4',
            'apiId': null,
            'isbn10': null,
            'isbn13': null,
            'title': 'h',
            'subtitle': 'h',
            'authors': ['h'],
            'categories': ['h'],
            'publisher': null,
            'pubDate': null,
            'pageCount': 3,
            'imageUrl': null,
            'language': 'pt',
            'description': null,
            'createdAt': '2025-06-14T22:25:15.598Z',
            'updatedAt': '2025-06-14T22:25:15.598Z',
          },
          'status': 0,
          'startDate': null,
          'endDate': null,
          'createdAt': '2025-06-14T22:25:15.602Z',
          'updatedAt': '2025-06-14T22:25:15.602Z',
        },
        {
          'id': '1',
          'book': {
            'id': '1',
            'apiId': null,
            'isbn10': null,
            'isbn13': null,
            'title': 'gg',
            'subtitle': 'dd',
            'authors': ['dd'],
            'categories': ['dd'],
            'publisher': null,
            'pubDate': null,
            'pageCount': 1,
            'imageUrl': null,
            'language': 'pt',
            'description': null,
            'createdAt': '2025-06-14T16:48:06.235Z',
            'updatedAt': '2025-06-14T16:48:06.235Z',
          },
          'status': 2,
          'startDate': '2025-06-19T11:28:17.874Z',
          'endDate': '2025-06-20T16:27:58.210Z',
          'createdAt': '2025-06-14T16:48:06.250Z',
          'updatedAt': '2025-06-20T16:27:58.210Z',
        },
        {
          'id': '2',
          'book': {
            'id': '2',
            'apiId': null,
            'isbn10': null,
            'isbn13': null,
            'title': 'gg',
            'subtitle': 'dd',
            'authors': ['dd'],
            'categories': ['dd'],
            'publisher': null,
            'pubDate': null,
            'pageCount': 1,
            'imageUrl': null,
            'language': 'pt',
            'description': null,
            'createdAt': '2025-06-14T16:48:14.295Z',
            'updatedAt': '2025-06-14T16:48:14.295Z',
          },
          'status': 2,
          'startDate': '2025-06-20T16:24:43.801Z',
          'endDate': '2025-06-20T16:29:33.846Z',
          'createdAt': '2025-06-14T16:48:14.301Z',
          'updatedAt': '2025-06-20T16:29:33.846Z',
        },
        {
          'id': '5',
          'book': {
            'id': '7',
            'apiId': null,
            'isbn10': null,
            'isbn13': null,
            'title': 'j',
            'subtitle': 'j',
            'authors': ['h'],
            'categories': ['h'],
            'publisher': null,
            'pubDate': null,
            'pageCount': 9,
            'imageUrl': null,
            'language': 'pt',
            'description': null,
            'createdAt': '2025-06-14T22:29:58.579Z',
            'updatedAt': '2025-06-14T22:29:58.579Z',
          },
          'status': 1,
          'startDate': '2025-06-20T16:36:45.497Z',
          'endDate': null,
          'createdAt': '2025-06-14T22:27:45.262Z',
          'updatedAt': '2025-06-20T16:36:45.497Z',
        },
      ];

      BookStatusApi.allBooks = List.from(
        json.map((e) => BookStatus.fromJson(e)),
      );

      // 2,,,,gg,dd,'[''dd'']','[''dd'']',,,1,,pt,,2025-06-14 17:48:14.295 +0100,2025-06-14 17:48:14.295 +0100
      // 3,,,,h,h,"[""h""]","[""h""]",,,3,,pt,,2025-06-14 23:25:15.506 +0100,2025-06-14 23:25:15.506 +0100
      // 5,,,,f,g,"[""c""]","[""f""]",,,2,,pt,,2025-06-14 23:27:45.251 +0100,2025-06-14 23:27:45.251 +0100
      // 7,,,,j,j,"[""h""]","[""h""]",,,9,,pt,,2025-06-14 23:29:58.579 +0100,2025-06-14 23:29:58.579 +0100
    });

    group('findBookStatus', () {
      test('get book status associated with a book', () {
        final Book book = Book(
          id: BigInt.parse('2'),
          title: 'gg',
          subtitle: 'dd',
          authors: ['dd'],
          categories: ['dd'],
          pageCount: 1,
          language: 'pt',
        );

        final status = BookStatusApi.findBookStatus(book);
        expect(status, isA<BookStatus?>());
      });
    });
  });
}
