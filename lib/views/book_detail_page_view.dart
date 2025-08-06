import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import '../controllers/book_detail_page_controller.dart';
import '../models/book_model.dart';



class BookDetailPageView extends StatelessWidget {
  final Book book;
  const BookDetailPageView({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    Get.put(BookDetailPageController(book: book));
    final BookDetailPageController detailController = Get.find<BookDetailPageController>();

    return Scaffold(
      appBar: AppBar(
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: book.coverId != null
                  ? CachedNetworkImage(
                imageUrl: 'https://covers.openlibrary.org/b/id/${book.coverId}-L.jpg',
                width: 200, fit: BoxFit.cover,
                placeholder: (context, url) =>  SizedBox(width: 200, height: 300, child:  Center(child: Lottie.asset("assets/animations/Book animation.json"))),
                errorWidget: (context, url, error) => const SizedBox(width: 200, height: 300, child: Icon(Icons.broken_image, size: 100)),
              )
                  : const SizedBox(width: 200, height: 300, child: Icon(Icons.book, size: 100)),
            ),
            const SizedBox(height: 20),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(book.title, style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w500,fontFamily: 'rubik')),
            ),
            const SizedBox(height: 8),
            if (book.authorNames != null)
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('by ${book.authorNames!.join(', ')}', style: const TextStyle(fontSize: 14.5, fontStyle: FontStyle.italic,fontFamily: 'rubik')),
              ),
            const SizedBox(height: 8),
            if (book.firstPublishYear != null)
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('First Published: ${book.firstPublishYear}', style: const TextStyle(fontSize: 16,fontFamily: 'rubik')),
              ),
            const Divider(height: 30),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: const Text('Description', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold,fontFamily: 'rubik')),
            ),
            const SizedBox(height: 10),
            Obx(() {
              if (detailController.isLoadingDescription.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: Text(detailController.description.value, style: const TextStyle(fontSize: 15,fontFamily: 'rubik'), textAlign: TextAlign.justify),
              );
            }),
          ],
        ),
      ),
    );
  }
}