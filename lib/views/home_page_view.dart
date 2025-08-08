import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;
import '../controllers/home_page_controller.dart';
import '../models/book_model.dart';
import 'book_detail_page_view.dart';
import 'category_page_view.dart';
import 'search_page_view.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  final HomePageController _homeController = HomePageController();

  @override
  void initState() {
    super.initState();
    _homeController.loadRecentlyVisitedBooks();
  }

  Future<void> _loadRecentlyVisitedBooks() async {
    _homeController.loadRecentlyVisitedBooks();
  }

  @override
  void dispose() {
    _homeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSearchBarPlaceholder(context),
            const SizedBox(height: 20),
            _buildRecentlyVisitedSection(context),
            const SizedBox(height: 20),
            _buildCategoryGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBarPlaceholder(BuildContext context) {
    return Container(
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
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchPageView()),
            );
          },
          child: Column(
            children: [
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Colors.black),
                    SizedBox(width: 10),
                    Text(
                      'Search for books...',
                      style: TextStyle(color: Colors.black, fontFamily: 'rubik'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentlyVisitedSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Recently Visited', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500, fontFamily: 'rubik')),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 210,
          child: ListenableBuilder(
            listenable: _homeController,
            builder: (context, child) {
              if (_homeController.recentlyVisitedBooks.isEmpty) {
                return const Center(child: Text('No recently visited books.', style: TextStyle(color: Colors.grey, fontFamily: 'rubik')));
              } else {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _homeController.recentlyVisitedBooks.length,
                  itemBuilder: (context, index) {
                    final book = _homeController.recentlyVisitedBooks[index];
                    return _buildBookItem(context, book);
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookItem(BuildContext context, Book book) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailPageView(
              book: book,
              onBookVisited: _loadRecentlyVisitedBooks, 
            ),
          ),
        ).then((_) => _loadRecentlyVisitedBooks()); // Trigger reload when returning to this page
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            book.coverId != null
                ? ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CachedNetworkImage(
                  imageUrl: 'https://covers.openlibrary.org/b/id/${book.coverId}-M.jpg',
                  width: 100,
                  height: 150,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => SizedBox(width: 100, height: 150, child: Center(child: Lottie.asset("assets/animations/Book animation.json"))),
                  errorWidget: (context, url, error) => const SizedBox(width: 100, height: 150, child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                ))
                : const SizedBox(width: 100, height: 150, child: Icon(Icons.book, size: 50, color: Colors.grey)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                book.title,
                textAlign: TextAlign.start,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12.5, color: Colors.blueGrey[800], fontFamily: 'rubik'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Explore Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'rubik')),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, childAspectRatio: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
          itemCount: _homeController.categories.length,
          padding: const EdgeInsets.all(16.0),
          itemBuilder: (context, index) {
            final color = Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0).withAlpha(150);
            final category = _homeController.categories[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CategoryPageView(category: category,onBookVisited: _loadRecentlyVisitedBooks, // Correctly pass the reload function here
                  )),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 2,
                color: Colors.blueGrey[50],
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(8),
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            category,
                            style: TextStyle(fontWeight: FontWeight.w500, fontFamily: 'rubik', color: Colors.blueGrey[800], fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}