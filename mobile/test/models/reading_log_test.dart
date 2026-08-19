import 'package:flutter_test/flutter_test.dart';
import 'package:bookread/models/reading_log.dart';

void main() {
  group('ReadingLog', () {
    group('fromJson', () {
      test('should create an instance from JSON with all values', () {
        final json = {
          ReadingLogFields.id: '1234',
          ReadingLogFields.bookStatusId: '5678',
          ReadingLogFields.duration: 120,
          ReadingLogFields.pagesReaded: 30,
          ReadingLogFields.createdAt: '2023-10-01T12:00:00Z',
        };

        final readingLog = ReadingLog.fromJson(json);

        expect(readingLog.id, isA<BigInt>());
        expect(readingLog.id.toString(), '1234');
        expect(readingLog.bookStatusId, isA<BigInt>());
        expect(readingLog.bookStatusId.toString(), '5678');
        expect(readingLog.duration, 120);
        expect(readingLog.pagesReaded, 30);
        expect(readingLog.createdAt, DateTime.parse('2023-10-01T12:00:00Z'));
      });

      test(
        'should fail to create an instance from JSON with missing values',
        () {
          final json = {ReadingLogFields.id: '1234'};

          expect(() => ReadingLog.fromJson(json), throwsA(isA<TypeError>()));
        },
      );
    });
  });
}
