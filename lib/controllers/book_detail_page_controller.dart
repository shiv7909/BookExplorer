import 'dart:convert';
import 'package:get/get.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;
import '../models/book_model.dart';
import '../services/shared_preferences_service.dart';
import 'home_page_controller.dart';

class BookDetailPageController extends GetxController {
  final Book book;
  final SharedPreferencesService _prefsService = SharedPreferencesService();
  final HomePageController homeController = Get.find<HomePageController>();

  final RxString description = 'No description available.'.obs;
  final RxBool isLoadingDescription = false.obs;

  BookDetailPageController({required this.book});

  @override
  void onInit() {
    super.onInit();
    _fetchDescription();
    _addBookToRecentlyVisited();
  }

  Future<void> _fetchDescription() async {
    if (book.worksKey == null) return;

    isLoadingDescription.value = true;
    try {
      final response = await http.get(
        Uri.parse('https://openlibrary.org${book.worksKey}.json'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final desc = jsonResponse['description'];
        String descText = '';

        if (desc is String) {
          descText = desc;
        } else if (desc is Map && desc['value'] is String) {
          descText = desc['value'];
        }

        // Unescape HTML entities like &quot;
        final unescape = HtmlUnescape();
        description.value = unescape.convert(descText.trim().isEmpty ? 'No description available.' : descText);
      }
    } catch (e) {
      // Handle error gracefully, but keep the default text
      print('Error fetching description: $e');
    } finally {
      isLoadingDescription.value = false;
    }
  }

  Future<void> _addBookToRecentlyVisited() async {
    await _prefsService.addRecentlyVisitedBook(book);
    homeController.loadRecentlyVisitedBooks(); // Update the list on the home page
  }
}