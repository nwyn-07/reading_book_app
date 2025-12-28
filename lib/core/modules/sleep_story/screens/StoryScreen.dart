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

  // Thêm ScrollController để kiểm soát scroll behavior
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    storyCategories = List.from(StoryCategory.mockData);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoryStore>().fetchStories(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
                                  child: const Text('Tải lại'),
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
                ),
              );
            },
          ),

          const Align(alignment: Alignment.bottomCenter, child: MiniPlayer()),
        ],
      ),
    );
  }
}
