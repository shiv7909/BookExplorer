import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import '../controllers/search_page_controller.dart';
import 'book_detail_page_view.dart';

class SearchPageView extends StatefulWidget {
  const SearchPageView({super.key});

  @override
  State<SearchPageView> createState() => _SearchPageViewState();
}

class _SearchPageViewState extends State<SearchPageView> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final SearchPageController searchController = Get.put(SearchPageController());
    final TextEditingController searchTextFieldController = TextEditingController();

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
                  controller: searchTextFieldController,
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
                  style: const TextStyle(color: Colors.black,fontFamily: 'rubik'),
                  onSubmitted: (query) {
                    searchController.searchBooks(query);
                  },
                ),
                SizedBox(height: 10,)
              ],
            ),
          ),
        ),
      ),

      body: Obx(() {
        if (searchController.isLoading.value) {
          return  Center(child: Lottie.asset("assets/animations/Book animation.json"));
        }

        if (searchController.searchResults.isEmpty) {
          return const Center(child: Text('No search results. Please enter a query.',style: TextStyle(
         fontFamily: 'rubik'
          ),));
        }

        return ListView.builder(
          itemCount: searchController.searchResults.length,
          itemBuilder: (context, index) {
            final book = searchController.searchResults[index];
            return GestureDetector(
              onTap: () {
                Get.to(() => BookDetailPageView(book: book));
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
                                                    placeholder: (context, url) =>  SizedBox(width: 80, height: 120, child:  Center(child: Lottie.asset("assets/animations/Book animation.json"))),
                                                    errorWidget: (context, url, error) => const SizedBox(width: 80, height: 120, child: Icon(Icons.broken_image)),
                                                  ),
                          )
                          : const SizedBox(width: 80, height: 120, child: Icon(Icons.book, size: 50)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 3,
                          children: [
                            Text(book.title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15,fontFamily: 'rubik')),
                            if (book.authorNames != null)
                              Text('by ${book.authorNames!.join(', ')}', style: const TextStyle(color: Colors.grey,fontFamily: 'rubik',fontSize: 13)),
                            if (book.firstPublishYear != null)
                              Text('Published: ${book.firstPublishYear}', style: const TextStyle(fontFamily: 'rubik',fontSize: 13)),
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
      }),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}