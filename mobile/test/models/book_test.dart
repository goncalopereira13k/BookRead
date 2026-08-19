import 'package:flutter_test/flutter_test.dart';
import 'package:bookread/models/book.dart';

void main() {
  group('Book', () {
    group('fromJson', () {
      test('should create an instance from JSON with all values', () {
        final json = {
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
        };

        final book = Book.fromJson(json);

        expect(book.id, isA<BigInt>());
        expect(book.id.toString(), '1234');
        expect(book.apiId, 'api1234');
        expect(book.isbn10, '1234567890');
        expect(book.isbn13, '1234567890123');
        expect(book.title, 'Test Book');
        expect(book.subtitle, 'A Subtitle');
        expect(book.authors, ['Author One', 'Author Two']);
        expect(book.categories, ['Fiction', 'Adventure']);
        expect(book.description, 'A description of the test book.');
        expect(book.publisher, 'Test Publisher');
        expect(book.publishedDate, DateTime.parse('2023-10-01'));
        expect(book.pageCount, 300);
        expect(book.thumbnail, 'http://example.com/thumbnail.jpg');
        expect(book.language, 'en');
      });

      test(
        'should fail to create an instance from JSON with missing values',
        () {
          final json = {BookFields.id: '1234'};

          expect(() => Book.fromJson(json), throwsA(isA<TypeError>()));
        },
      );
    });
  });
}
