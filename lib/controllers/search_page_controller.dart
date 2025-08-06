import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/book_model.dart';

class SearchPageController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<Book> searchResults = <Book>[].obs;

  Future<void> searchBooks(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    isLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse('https://openlibrary.org/search.json?q=$query'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> docs = jsonResponse['docs'];
        searchResults.assignAll(
          docs.map((doc) => Book.fromJson(doc)).where((book) => book.coverId != null && book.worksKey != null).toList(),
        );
      } else {
        Get.snackbar('Error', 'Failed to load search results.');
        searchResults.clear();
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
      searchResults.clear();
    } finally {
      isLoading.value = false;
    }
  }
}