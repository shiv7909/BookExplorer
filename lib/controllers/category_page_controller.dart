import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book_model.dart';

class CategoryPageService {
  Future<List<Book>> fetchBooksByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('https://openlibrary.org/subjects/${category.toLowerCase()}.json'),
      );

      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(response.body);
          print('JSON response for $category: $jsonResponse'); // Add this line
          final List<dynamic> workList = jsonResponse['works'] ?? [];
          return workList
              .map((work) => Book.fromJson(work))
              .where((book) => book.coverId != null && book.worksKey != null)
              .toList();
        } on FormatException {
          print('Warning: Received non-JSON response for category: $category');
          return [];
        }
      } else {
        throw Exception('Failed to load books for category: $category. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}