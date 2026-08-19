import 'package:googleapis/books/v1.dart';
import 'package:http/http.dart';
import 'package:bookread/models/book.dart';

mixin GoogleBooksApi {
  static Future<List<Book>?> searchBooks(String query) async {
    List<Book> books = [];

    final client = Client();
    try {
      // Use the client to make requests to the Google Books API

      final booksApi = BooksApi(client);
      Volumes response = await booksApi.volumes.list(query);
      if (response.items == null) {
        return null;
      }

      for (Volume item in response.items!) {
        books.add(Book.fromApi(item));
      }
    } finally {
      client.close();
    }
    return books;
  }
}
