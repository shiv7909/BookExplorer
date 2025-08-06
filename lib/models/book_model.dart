import 'dart:convert';

class Book {
  final String title;
  final List<dynamic>? authorNames;
  final int? firstPublishYear;
  final String? coverId;
  final String? worksKey;

  Book({
    required this.title,
    this.authorNames,
    this.firstPublishYear,
    this.coverId,
    this.worksKey,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'] ?? 'Unknown Title',
      authorNames: json['author_name'],
      firstPublishYear: json['first_publish_year'],
      coverId: json['cover_i']?.toString(),
      worksKey: json['key'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author_name': authorNames,
      'first_publish_year': firstPublishYear,
      'cover_i': coverId,
      'key': worksKey,
    };
  }

  static List<Book> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Book.fromJson(json)).toList();
  }

  static List<dynamic> toJsonList(List<Book> books) {
    return books.map((book) => book.toJson()).toList();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Book && other.worksKey == worksKey;
  }

  @override
  int get hashCode => worksKey.hashCode;
}