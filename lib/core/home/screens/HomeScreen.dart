import 'package:flutter/material.dart';
import 'package:reading_book_app/core/home/components/BookCard.dart';
import 'package:reading_book_app/core/models/Book.dart';
import 'package:reading_book_app/core/theme/AppTextStyles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Book> sampleBooks() {
    return [
      Book(
        title: 'Book 1',
        coverURL:
            'https://img.freepik.com/premium-photo/fairy-tale-book-is-magical-place_662214-49726.jpg',
      ),
      Book(
        title: 'Book 2',
        coverURL:
            'https://cdn.openart.ai/uploads/image__W597vKX_1687174110875_raw.jpg',
      ),
      Book(
        title: 'Book 3',
        coverURL:
            'https://thomaskinkadeca.com/wp-content/uploads/clkstr-le.jpg',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 200,
                    alignment: AlignmentGeometry.bottomLeft,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(color: Colors.transparent),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Chào buổi tối', style: AppTextStyles.h2),
                        Text(
                          'Chúc bạn một ngày tốt lành 🌙',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  Text('Lựa chọn hằng ngày', style: AppTextStyles.h3),
                  SizedBox(height: 8),
                  BookCard(sampleBooks().first, true),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Mới', style: AppTextStyles.h3),
                  ),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: sampleBooks().length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: SizedBox(
                            width: 150,
                            child: BookCard(
                              sampleBooks().elementAt(index),
                              false,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Phổ biến', style: AppTextStyles.h3),
                  ),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: sampleBooks().length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: SizedBox(
                            width: 150,
                            child: BookCard(
                              sampleBooks().elementAt(index),
                              false,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
