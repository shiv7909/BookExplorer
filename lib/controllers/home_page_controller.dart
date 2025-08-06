import 'package:get/get.dart';
import '../models/book_model.dart';
import '../services/shared_preferences_service.dart';

class HomePageController extends GetxController {


  final SharedPreferencesService _prefsService = SharedPreferencesService();
  final RxList<Book> recentlyVisitedBooks = <Book>[].obs;
  final List<String> categories = [
    'History', 'Plays', 'Philosophy', 'Self Help', 'Science',
    'Religion', 'Autobiographies', 'Fantasy', 'Finance', 'Romance'
  ];

  @override
  void onInit() {
    super.onInit();
    loadRecentlyVisitedBooks();
  }

  Future<void> loadRecentlyVisitedBooks() async {
    final books = await _prefsService.getRecentlyVisitedBooks();
    recentlyVisitedBooks.assignAll(books);
  }
}