import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:reading_book_app/core/models/StoryCategory.dart';
import 'package:reading_book_app/core/modules/home/components/MiniPlayer.dart';
import 'package:reading_book_app/core/modules/sleep_story/components/StoryCategory.dart';
import 'package:reading_book_app/core/stores/StoryStore.dart';
import 'package:reading_book_app/core/models/Book.dart';
import 'package:reading_book_app/core/theme/AppTextStyles.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  late List<StoryCategory> storyCategories;
  String selectedCategory = 'ALL';

  @override
  void initState() {
    super.initState();

    storyCategories = List.from(StoryCategory.mockData);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoryStore>().fetchStories(refresh: true);
    });
  }

  /// 🔥 FILTER LOGIC
  List<Book> _filterStories(List<Book> stories) {
    if (selectedCategory == 'ALL') return stories;

    return stories.where((b) => b.type == selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// BACKGROUND
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),

          /// CONTENT
          Consumer<StoryStore>(
            builder: (context, store, _) {
              if (store.isLoading && store.stories.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (store.error != null) {
                return Center(
                  child: Text(
                    store.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final filteredStories = _filterStories(store.stories);

              if (filteredStories.isEmpty) {
                return const Center(
                  child: Text(
                    'Không có truyện phù hợp',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

              return CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 260)),

                  /// HEADER
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

                  /// CATEGORY
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

                  /// GRID
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final book = filteredStories[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              '/chapter',
                              arguments: {
                                'storyId': book.id,
                                'storyTitle': book.title,
                              },
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(16),
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
              );
            },
          ),

          /// MINI PLAYER
          const Align(alignment: Alignment.bottomCenter, child: MiniPlayer()),
        ],
      ),
    );
  }
}
