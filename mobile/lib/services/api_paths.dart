import 'package:bookread/models/book.dart';

mixin ApiPaths {
  static const String baseUrl = 'http://192.168.1.86:3000';

  // Authentication
  static String login() {
    return '$baseUrl/auth/login';
  }

  static String register() {
    return '$baseUrl/auth/register';
  }

  // User
  static String user() {
    return '$baseUrl/user/';
  }

  static String changePassword() {
    return '$baseUrl/user/changePassword';
  }

  // Settings
  static String settings() {
    return '$baseUrl/settings';
  }

  // Goals
  static String dailyGoal() {
    return '$baseUrl/goal/daily';
  }

  static String yearlyGoal() {
    return '$baseUrl/goal/yearly';
  }

  // Reading Books
  static String allBooks() {
    return '$baseUrl/books/all';
  }

  static String wantedBooks() {
    return '$baseUrl/books/wanted';
  }

  static String readingBooks() {
    return '$baseUrl/books/reading';
  }

  static String readedBooks() {
    return '$baseUrl/books/readed';
  }

  static String archivedBooks() {
    return '$baseUrl/books/archived';
  }

  static String setBookRate() {
    return '$baseUrl/books/rate';
  }

  static String countReadedBooksByYear(DateTime date) {
    final String year = date.year.toString();
    return '$baseUrl/books/countReaded?year=$year';
  }

  // Book
  static String book() {
    return '$baseUrl/book';
  }

  // Reading Logs
  static String readingLogs() {
    return '$baseUrl/readinglog';
  }

  static String readingLogsByBookStatus(String bookStatusId) {
    return '$baseUrl/readinglog?bStatusId=$bookStatusId';
  }

  static String countReadedPagesByDate(DateTime date) {
    final String dateIso = date.toIso8601String().split('T')[0];
    return '$baseUrl/readinglog/countPages?date=$dateIso';
  }

  // Book Notes
  static String getBookNotes(Book book) {
    final String bookId = book.id?.toString() ?? '';
    return '$baseUrl/books/notes?bookId=$bookId';
  }

  static String bookNotes() {
    return '$baseUrl/books/notes';
  }

  // Stats
  static String streak() {
    return '$baseUrl/stats/streak';
  }
}
