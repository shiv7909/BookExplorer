import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/book_model.dart';

class CategoryPageController extends GetxController {
  final String category;
  final RxBool isLoading = false.obs;
  final RxList<Book> books = <Book>[].obs;

  CategoryPageController({required this.category});

  @override
  void onInit() {
    super.onInit();
    fetchBooksByCategory();
  }

  Future<void> fetchBooksByCategory() async {
    isLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse('https://openlibrary.org/subjects/${category.toLowerCase()}.json'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> workList = jsonResponse['works'];
        books.assignAll(
          workList.map((work) {
            final book = Book.fromJson(work);
            return Book(
              title: book.title,
              authorNames: book.authorNames,
              firstPublishYear: work['first_publish_year'],
              coverId: work['cover_id']?.toString(),
              worksKey: book.worksKey,
            );
          }).where((book) => book.coverId != null && book.worksKey != null).toList(),
        );
      } else {
        Get.snackbar('Error', 'Failed to load books for category: $category');
        books.clear();
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
      books.clear();
    } finally {
      isLoading.value = false;
    }
  }
}