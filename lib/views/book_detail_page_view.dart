import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html_unescape/html_unescape.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import '../models/book_model.dart';
import '../services/shared_preferences_service.dart';


class BookDetailPageView extends StatefulWidget {
  final Book book;
  final VoidCallback onBookVisited;

  const BookDetailPageView({
    Key? key,
    required this.book,
    required this.onBookVisited,
  }) : super(key: key);

  @override
  State<BookDetailPageView> createState() => _BookDetailPageViewState();
}

class _BookDetailPageViewState extends State<BookDetailPageView> {
  final SharedPreferencesService _prefsService = SharedPreferencesService();

  String description = 'No description available.';
  bool isLoadingDescription = true;

  @override
  void initState() {
    super.initState();
    _fetchDescription();
    _addBookToRecentlyVisited();
  }

  Future<void> _fetchDescription() async {
    if (widget.book.worksKey == null) {
      setState(() {
        isLoadingDescription = false;
        description = 'No works key available for fetching description.';
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://openlibrary.org${widget.book.worksKey}.json'),
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

        final unescape = HtmlUnescape();
        setState(() {
          description = unescape.convert(
              descText.trim().isEmpty ? 'No description available.' : descText);
          isLoadingDescription = false;
        });
      } else {
        setState(() {
          isLoadingDescription = false;
          description = 'Failed to load description. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        description = 'Error fetching description: $e';
        isLoadingDescription = false;
      });
    }
  }

  Future<void> _addBookToRecentlyVisited() async {
    await _prefsService.addRecentlyVisitedBook(widget.book);
    widget.onBookVisited();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title ?? 'Book Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: widget.book.coverId != null
                  ? CachedNetworkImage(
                imageUrl: 'https://covers.openlibrary.org/b/id/${widget.book.coverId}-L.jpg',
                width: 200,
                fit: BoxFit.cover,
                placeholder: (context, url) => SizedBox(
                  width: 200,
                  height: 300,
                  child: Center(
                    child: Lottie.asset("assets/animations/Book animation.json"),
                  ),
                ),
                errorWidget: (context, url, error) => const SizedBox(
                  width: 200,
                  height: 300,
                  child: Icon(Icons.broken_image, size: 100),
                ),
              )
                  : const SizedBox(
                width: 200,
                height: 300,
                child: Icon(Icons.book, size: 100),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                widget.book.title,
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'rubik',
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (widget.book.authorNames != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'by ${widget.book.authorNames!.join(', ')}',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'rubik',
                  ),
                ),
              ),
            const SizedBox(height: 8),
            if (widget.book.firstPublishYear != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'First Published: ${widget.book.firstPublishYear}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'rubik',
                  ),
                ),
              ),
            const Divider(height: 30),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Description',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'rubik',
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (isLoadingDescription)
              const Center(child: CircularProgressIndicator())
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: Text(
                  description,
                  style: const TextStyle(fontSize: 15, fontFamily: 'rubik'),
                  textAlign: TextAlign.justify,
                ),
              ),
          ],
        ),
      ),
    );
  }
}