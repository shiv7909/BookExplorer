import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book_model.dart';

class SharedPreferencesService {

  static const _recentlyVisitedKey = 'recentlyVisitedBooks';

  Future<List<Book>> getRecentlyVisitedBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? booksJson = prefs.getString(_recentlyVisitedKey);
    if (booksJson == null) {
      return [];
    }
    final List<dynamic> jsonList = jsonDecode(booksJson);
    return jsonList.map((json) => Book.fromJson(json)).toList();
  }

  Future<void> addRecentlyVisitedBook(Book book) async {
    final prefs = await SharedPreferences.getInstance();
    List<Book> books = await getRecentlyVisitedBooks();

    books.removeWhere((b) => b == book);

    books.insert(0, book);

    if (books.length > 10) {
      books = books.sublist(0, 10);
    }

    final String booksJson = jsonEncode(Book.toJsonList(books));
    await prefs.setString(_recentlyVisitedKey, booksJson);
  }
}