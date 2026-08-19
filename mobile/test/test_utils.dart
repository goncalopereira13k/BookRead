import 'package:flutter/material.dart';
import 'package:bookread/models/book.dart';
import 'package:bookread/models/user.dart';
import 'package:bookread/models/reading_log.dart';
import 'package:bookread/models/goal.dart';
import 'package:bookread/models/book_status.dart';
import 'package:bookread/utilities/constants.dart';

/// Test utilities and mock data for unit tests
class TestUtils {
  /// Creates a mock Book for testing
  static Book createMockBook({
    BigInt? id,
    String? apiId,
    String title = 'Test Book',
    String subtitle = 'Test Subtitle',
    List<String> authors = const ['Test Author'],
    List<String> categories = const ['Fiction'],
    String? description,
    String? publisher,
    DateTime? publishedDate,
    int pageCount = 300,
    String? thumbnail,
    String language = 'en',
  }) {
    return Book(
      id: id ?? BigInt.from(1),
      apiId: apiId ?? 'test-api-id',
      title: title,
      subtitle: subtitle,
      authors: authors,
      categories: categories,
      description: description ?? 'Test description',
      publisher: publisher ?? 'Test Publisher',
      publishedDate: publishedDate ?? DateTime.now(),
      pageCount: pageCount,
      thumbnail: thumbnail ?? 'https://example.com/thumbnail.jpg',
      language: language,
    );
  }

  /// Creates a mock User for testing
  static User createMockUser({
    BigInt? id,
    String username = 'testuser',
    String email = 'test@example.com',
    DateTime? birthdate,
    Gender gender = Gender.male,
    String? avatar,
    String? password,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? BigInt.from(1),
      username: username,
      email: email,
      birthdate:
          birthdate ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      gender: gender,
      avatar: avatar,
      password: password,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  /// Creates a mock ReadingLog for testing
  static ReadingLog createMockReadingLog({
    BigInt? id,
    BigInt? bookStatusId,
    int? duration,
    int pagesReaded = 50,
    DateTime? createdAt,
  }) {
    return ReadingLog(
      id: id ?? BigInt.from(1),
      bookStatusId: bookStatusId ?? BigInt.from(1),
      duration: duration,
      pagesReaded: pagesReaded,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  /// Creates a mock Goal for testing
  static Goal createMockGoal({GoalType type = GoalType.daily, int value = 10}) {
    return Goal(type: type, value: value);
  }

  /// Creates a mock BookStatus for testing
  static BookStatus createMockBookStatus({
    BigInt? id,
    Book? book,
    BookStatusType status = BookStatusType.reading,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return BookStatus(
      id: id ?? BigInt.from(1),
      book: book ?? createMockBook(),
      status: status,
      startDate: startDate ?? DateTime.now(),
      endDate: endDate,
    );
  }

  /// Creates a test widget wrapper for widget tests
  static Widget wrapWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  /// Creates a test widget wrapper with theme and localization
  static Widget wrapWidgetWithTheme(Widget child) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(body: child),
    );
  }

  /// Common test data for JSON serialization tests
  static Map<String, dynamic> get validBookJson => {
    BookFields.id: '1',
    BookFields.apiId: 'api-123',
    BookFields.isbn10: '1234567890',
    BookFields.isbn13: '1234567890123',
    BookFields.title: 'Test Book',
    BookFields.subtitle: 'Test Subtitle',
    BookFields.authors: ['Author One', 'Author Two'],
    BookFields.categories: ['Fiction', 'Adventure'],
    BookFields.description: 'A test book description',
    BookFields.publisher: 'Test Publisher',
    BookFields.publishedDate: '2023-01-01',
    BookFields.pageCount: 300,
    BookFields.thumbnail: 'https://example.com/thumbnail.jpg',
    BookFields.language: 'en',
  };

  /// Invalid JSON data for testing error cases
  static Map<String, dynamic> get invalidBookJson => {
    BookFields.id: '1',
    // Missing required fields
  };

  /// Utility method to verify DateTime equality within tolerance
  static bool dateTimeEquals(
    DateTime? a,
    DateTime? b, {
    Duration tolerance = const Duration(seconds: 1),
  }) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return a.difference(b).abs() <= tolerance;
  }
}
