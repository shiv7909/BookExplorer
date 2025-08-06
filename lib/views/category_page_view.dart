import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/category_page_controller.dart';
import 'package:lottie/lottie.dart';
import 'book_detail_page_view.dart';

class CategoryPageView extends StatelessWidget {
  final String category;
  const CategoryPageView({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    Get.put(CategoryPageController(category: category));
    final CategoryPageController categoryController = Get.find<CategoryPageController>();


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
     title: Text(category,style: TextStyle(
          fontFamily: 'rubik',
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500
        ),),
        centerTitle: true,
       leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (categoryController.isLoading.value) {
          return Center(
            child: Lottie.asset(
              'assets/animations/Girl with books.json',
              width: 200,
              height: 200
            ));
        }

        if (categoryController.books.isEmpty) {
          return const Center(child: Text('No books found for this category.'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2 / 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 20,
          ),
          itemCount: categoryController.books.length,
          itemBuilder: (context, index) {
            final book = categoryController.books[index];
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
                          Get.to(() => BookDetailPageView(book: book));
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
                              placeholder: (context, url) =>  Center(child: Lottie.asset("assets/animations/Book animation.json")),
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
                            fontFamily: 'rubik'
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
                          fontFamily: 'rubik'
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}