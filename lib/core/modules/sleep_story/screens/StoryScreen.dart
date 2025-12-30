import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:reading_book_app/core/models/StoryCategory.dart';
import 'package:reading_book_app/core/modules/home/components/MiniPlayer.dart';
import 'package:reading_book_app/core/modules/sleep_story/components/StoryCategory.dart';
import 'package:reading_book_app/core/stores/AudioStore.dart';
import 'package:reading_book_app/core/stores/StoryStore.dart';
import 'package:reading_book_app/core/models/Book.dart';
import 'package:reading_book_app/core/theme/AppTextStyles.dart';
import 'package:reading_book_app/core/theme/AppColors.dart'; // Thêm import AppColors

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  late List<StoryCategory> storyCategories;
  String selectedCategory = 'ALL';

  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTopButton = false;

  @override
  void initState() {
    super.initState();

    storyCategories = List.from(StoryCategory.mockData);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoryStore>().fetchStories(refresh: true);
    });

    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset > 300) {
      if (!_showScrollToTopButton) {
        setState(() {
          _showScrollToTopButton = true;
        });
      }
    } else {
      if (_showScrollToTopButton) {
        setState(() {
          _showScrollToTopButton = false;
        });
      }
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  List<Book> _filterStories(List<Book> stories) {
    if (selectedCategory == 'ALL') return stories;

    return stories.where((b) => b.type == selectedCategory).toList();
  }

  Future<void> _handleRefresh() async {
    try {
      await context.read<StoryStore>().fetchStories(refresh: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải lại: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),

          Consumer<StoryStore>(
            builder: (context, store, _) {
              if (store.isLoading && store.stories.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (store.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        store.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _handleRefresh,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.primary, // Sử dụng màu từ AppColors
                        ),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              final filteredStories = _filterStories(store.stories);

              return RefreshIndicator(
                color: Colors.white,
                backgroundColor: Colors.black.withOpacity(0.7),
                displacement: 40,
                onRefresh: _handleRefresh,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    const SliverToBoxAdapter(child: SizedBox(height: 260)),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Shhh', style: AppTextStyles.h1),
                            const SizedBox(height: 6),
                            Text(
                              'Bây giờ, nhắm mắt lại và tận hưởng',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 36,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: storyCategories.length,
                          itemBuilder: (context, index) {
                            final category = storyCategories[index];

                            return StoryCategoryItem(
                              category: category,
                              onTap: () {
                                setState(() {
                                  selectedCategory = category.value;

                                  storyCategories = storyCategories
                                      .map(
                                        (c) => c.copyWith(
                                          isSelected: c.id == category.id,
                                        ),
                                      )
                                      .toList();
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 24)),

                    if (store.isLoading && store.stories.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: CircularProgressIndicator(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ),
                      )
                    else if (filteredStories.isEmpty)
                      SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  'Không có câu chuyện nào trong mục này.',
                                  style: AppTextStyles.body,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _handleRefresh,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                  ),
                                  child: const Text(
                                    'Tải lại',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final book = filteredStories[index];

                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  '/chapter',
                                  arguments: {'story': book},
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: book.coverUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey.shade300,
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                            color: Colors.grey,
                                            child: const Icon(
                                              Icons.broken_image,
                                            ),
                                          ),
                                    ),

                                    // Overlay tối
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        border: Border.all(
                                          color: AppColors.primary.withOpacity(
                                            0.3,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        book.title,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }, childCount: filteredStories.length),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.75,
                              ),
                        ),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                ),
              );
            },
          ),

          const Align(alignment: Alignment.bottomCenter, child: MiniPlayer()),

          if (_showScrollToTopButton)
            Consumer<AudioStore>(
              builder: (context, audioStore, child) => Positioned(
                bottom: audioStore.isMiniVisible ? 100 : 40,
                right: 20,
                child: FloatingActionButton(
                  backgroundColor: AppColors.primary.withOpacity(0.5),
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),

                  onPressed: _scrollToTop,
                  child: const Icon(Icons.arrow_upward_rounded, size: 30),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
