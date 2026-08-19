import 'package:flutter_test/flutter_test.dart';
import 'package:bookread/models/book_note.dart';

void main() {
  group('BookNote', () {
    group('fromJson', () {
      test('should create an instance from JSON with all values', () {
        final json = {
          BookNoteFields.id: '1234',
          BookNoteFields.bookId: '5678',
          BookNoteFields.page: 42,
          BookNoteFields.content: 'This is a test note.',
          BookNoteFields.createdAt: '2023-10-01T12:00:00Z',
          BookNoteFields.updatedAt: '2023-10-01T12:00:00Z',
        };

        final bookNote = BookNote.fromJson(json);

        expect(bookNote.id, isA<BigInt>());
        expect(bookNote.id.toString(), '1234');
        expect(bookNote.bookId, isA<BigInt>());
        expect(bookNote.bookId.toString(), '5678');
        expect(bookNote.page, 42);
        expect(bookNote.content, 'This is a test note.');
        expect(bookNote.createdAt, DateTime.parse('2023-10-01T12:00:00Z'));
        expect(bookNote.updatedAt, DateTime.parse('2023-10-01T12:00:00Z'));
      });

      test(
        'should fail to create an instance from JSON with missing values',
        () {
          final json = {BookNoteFields.id: '1234'};

          expect(() => BookNote.fromJson(json), throwsA(isA<TypeError>()));
        },
      );
    });
  });
}
