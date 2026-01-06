import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reading_book_app/core/components/LoadingLottie.dart';

import 'package:reading_book_app/core/modules/home/components/BookCard.dart';
import 'package:reading_book_app/core/modules/home/components/MiniPlayer.dart';
import 'package:reading_book_app/core/stores/StoryStore.dart';
import 'package:reading_book_app/core/theme/AppColors.dart';
import 'package:reading_book_app/core/theme/AppTextStyles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoryStore>().fetchStories(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Consumer<StoryStore>(
            builder: (context, store, _) {
              if (!store.isInitialized || store.isLoading) {
                return Center(
                  child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    color: AppColors.background,
                    child: LoadingLottie(),
                  ),
                );
              }

              if (store.error != null) {
                return Center(
                  child: Text(
                    store.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              if (store.stories.isEmpty) {
                return const Center(child: Text('Không có truyện'));
              }

              final books = store.stories;

              return RefreshIndicator(
                color: Colors.white,
                backgroundColor: Colors.black.withOpacity(0.7),
                displacement: 40,
                onRefresh: () async {
                  await context.read<StoryStore>().fetchStories(refresh: true);
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 24,
                        ),
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/background.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),

                            Text('Lựa chọn hằng ngày', style: AppTextStyles.h3),
                            const SizedBox(height: 8),
                            BookCard(books.first, true),

                            const SizedBox(height: 12),
                            Text('Mới', style: AppTextStyles.h3),
                            const SizedBox(height: 8),
                            _buildHorizontalList(books),

                            const SizedBox(height: 12),
                            Text('Phổ biến', style: AppTextStyles.h3),
                            const SizedBox(height: 8),
                            _buildHorizontalList(books),

                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          Align(alignment: Alignment.bottomCenter, child: MiniPlayer()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.bottomLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('Chào buổi sáng', style: AppTextStyles.h2),
          Text('Chúc bạn một ngày tốt lành 🌙', style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(List books) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(right: 12),
          child: SizedBox(width: 150, child: BookCard(books[i], false)),
        ),
      ),
    );
  }
}
