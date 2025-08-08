import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/book_model.dart';

class SearchPageService {
  Future<List<Book>> searchBooks(String query) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse('https://openlibrary.org/search.json?q=$query'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> docs = jsonResponse['docs'];
        return docs
            .map((doc) => Book.fromJson(doc))
            .where((book) => book.coverId != null && book.worksKey != null)
            .toList();
      } else {
        throw Exception('Failed to load search results.');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}