import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../controllers/search_page_controller.dart';
import '../models/book_model.dart';
import 'book_detail_page_view.dart';

class SearchPageView extends StatefulWidget {
  const SearchPageView({super.key});

  @override
  State<SearchPageView> createState() => _SearchPageViewState();
}

class _SearchPageViewState extends State<SearchPageView> {
  final FocusNode _focusNode = FocusNode();
  final SearchPageService _searchService = SearchPageService();
  final TextEditingController _searchTextFieldController = TextEditingController();

  List<Book> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _searchResults = [];
    });

    try {
      final results = await _searchService.searchBooks(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
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
      backgroundColor: Colors.blueGrey.shade50,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey[400]!, Colors.blueGrey[700]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                TextField(
                  focusNode: _focusNode,
                  controller: _searchTextFieldController,
                  decoration: InputDecoration(
                    hintText: 'Search for books...',
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                    suffixIcon: const Icon(Icons.search, color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.black, fontFamily: 'rubik'),
                  onSubmitted: _performSearch,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: Lottie.asset("assets/animations/Book animation.json"));
    }

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage, style: const TextStyle(fontFamily: 'rubik', color: Colors.red)));
    }

    if (_searchResults.isEmpty) {
      return const Center(child: Text('No search results. Please enter a query.', style: TextStyle(fontFamily: 'rubik')));
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final book = _searchResults[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BookDetailPageView(book: book, onBookVisited: () {  },)),
            );
          },
          child: Card(
            color: Colors.white,
            elevation: 0,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  book.coverId != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: CachedNetworkImage(
                      imageUrl: 'https://covers.openlibrary.org/b/id/${book.coverId}-S.jpg',
                      width: 80, height: 120, fit: BoxFit.cover,
                      placeholder: (context, url) => SizedBox(width: 80, height: 120, child: Center(child: Lottie.asset("assets/animations/Book animation.json"))),
                      errorWidget: (context, url, error) => const SizedBox(width: 80, height: 120, child: Icon(Icons.broken_image)),
                    ),
                  )
                      : const SizedBox(width: 80, height: 120, child: Icon(Icons.book, size: 50)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(book.title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15, fontFamily: 'rubik')),
                        if (book.authorNames != null)
                          Text('by ${book.authorNames!.join(', ')}', style: const TextStyle(color: Colors.grey, fontFamily: 'rubik', fontSize: 13)),
                        if (book.firstPublishYear != null)
                          Text('Published: ${book.firstPublishYear}', style: const TextStyle(fontFamily: 'rubik', fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchTextFieldController.dispose();
    super.dispose();
  }
}