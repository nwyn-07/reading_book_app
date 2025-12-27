import 'package:flutter/material.dart';
import 'package:reading_book_app/core/models/StoryCategory.dart';
import 'package:reading_book_app/core/sleep_story/components/StoryCategory.dart';
import 'package:reading_book_app/core/theme/AppTextStyles.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StatefulWidget> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  late List<StoryCategory> storyCategories;

  @override
  void initState() {
    super.initState();
    storyCategories = storyCategories;
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

          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: 260)),

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
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(
                          context,
                        ).pushNamed('/audio', arguments: {'storyIndex': index});
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            'Story ${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }, childCount: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ],
      ),
    );
  }
}
