import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../controllers/category_page_controller.dart';
import '../models/book_model.dart';
import 'book_detail_page_view.dart';

class CategoryPageView extends StatefulWidget {
  final String category;
  final VoidCallback onBookVisited;

  const CategoryPageView({
    super.key,
    required this.category,
    required this.onBookVisited,
  });

  @override
  State<CategoryPageView> createState() => _CategoryPageViewState();
}

class _CategoryPageViewState extends State<CategoryPageView> {
  final CategoryPageService _categoryService = CategoryPageService();
  List<Book> _books = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _categoryService.fetchBooksByCategory(widget.category);
      setState(() {
        _books = results;
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      setState(() {
        _books = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text(
          widget.category,
          style: const TextStyle(
            fontFamily: 'rubik',
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Lottie.asset(
          'assets/animations/Girl with books.json',
          width: 200,
          height: 200,
        ),
      );
    }

    if (_books.isEmpty) {
      return const Center(child: Text('No books found for this category.', style: TextStyle(fontFamily: 'rubik')));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2 / 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 20,
      ),
      itemCount: _books.length,
      itemBuilder: (context, index) {
        final book = _books[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookDetailPageView(
                            book: book,
                            onBookVisited: widget.onBookVisited, // Pass the callback down
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.8),
                            spreadRadius: 2,
                            blurRadius: 4,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: book.coverId != null
                            ? CachedNetworkImage(
                          imageUrl: 'https://covers.openlibrary.org/b/id/${book.coverId}-M.jpg',
                          fit: BoxFit.fill,
                          placeholder: (context, url) => Center(child: Lottie.asset("assets/animations/Book animation.json")),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: Icon(Icons.broken_image, size: 50, color: Colors.grey[400]),
                          ),
                        )
                            : Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.book, size: 50, color: Colors.grey[400]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  height: 40,
                  alignment: Alignment.topCenter,
                  child: Text(
                    book.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      fontFamily: 'rubik',
                    ),
                  ),
                ),
              ),
              if (book.authorNames != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    'by ${book.authorNames!.join(', ')}',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: 'rubik',
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}