

class Book {
  final String title;
  final List<dynamic>? authorNames;
  final int? firstPublishYear;
  final int? coverId;
  final String? worksKey;

  Book({
    required this.title,
    this.authorNames,
    this.firstPublishYear,
    this.coverId,
    this.worksKey,
  });

  factory Book.fromJson(Map<String, dynamic> json) {

    List<dynamic>? names;
    if (json.containsKey('author_name')) {
      names = json['author_name'];
    } else if (json.containsKey('authors')) {
      final List<dynamic>? authorsJson = json['authors'];
      names = authorsJson?.map((author) => author['name'] as String).toList();
    }

    int? parsedCoverId;
    final dynamic coverValue = json['cover_i'] ?? json['cover_id'];
    if (coverValue is int) {
      parsedCoverId = coverValue;
    } else if (coverValue is String) {
      parsedCoverId = int.tryParse(coverValue);
    }

    return Book(
      title: json['title'] ?? 'Unknown Title',
      authorNames: names,
      firstPublishYear: json['first_publish_year'],
      coverId: parsedCoverId,
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