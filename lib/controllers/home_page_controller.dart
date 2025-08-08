import 'package:flutter/foundation.dart';
import '../models/book_model.dart';
import '../services/shared_preferences_service.dart';

class HomePageController with ChangeNotifier {
  final SharedPreferencesService _prefsService = SharedPreferencesService();

  List<Book> _recentlyVisitedBooks = [];
  List<Book> get recentlyVisitedBooks => _recentlyVisitedBooks;

  final List<String> categories = [
    'History', 'Plays', 'Philosophy', 'Self Help', 'Science',
    'Religion', 'Autobiographies', 'Fantasy', 'Finance', 'Romance'
  ];

  HomePageController() {
    loadRecentlyVisitedBooks();
  }

  Future<void> loadRecentlyVisitedBooks() async {
    final books = await _prefsService.getRecentlyVisitedBooks();
    _recentlyVisitedBooks = books;
    notifyListeners(); 
  }
}