import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reading_book_app/core/stores/LibraryStore.dart';
import 'package:reading_book_app/core/theme/AppColors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryscreenState();
}

class _HistoryscreenState extends State<HistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   context.read<LibraryStore>().fetchLibraries();
    // });
    _scrollController.addListener(() {
      if (_scrollController.offset > 300 && !_showScrollToTop) {
        setState(() => _showScrollToTop = true);
      } else if (_scrollController.offset <= 300 && _showScrollToTop) {
        setState(() => _showScrollToTop = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  final List<Map<String, String>> mockStories = List.generate(
    30,
    (index) => {
      'image': 'assets/images/bg.jpg', // ảnh mẫu
      'title': 'Truyện  ${index + 1}',
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          RefreshIndicator(
            color: Colors.white,
            backgroundColor: Colors.black.withOpacity(0.7),
            displacement: 40,
            onRefresh: () => context.read<LibraryStore>().fetchLibraries(),
            child: Consumer<LibraryStore>(
              builder: (_, lib, _) {
                // final stories = lib.libraries;
                final stories = mockStories;
                return CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      centerTitle: true,
                      pinned: true,
                      backgroundColor: AppColors.background,
                      elevation: 0,
                      leading: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white, // màu icon back
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      title: Text(
                        'Lịch sử',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    if (stories.isEmpty) ...{
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              Text(
                                'Chưa có truyện yêu thích',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    }
                    //=====LIST=====
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final story = stories[index];

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        story['image']!,
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Text(
                                        story['title']!,
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Divider(
                                  color: Colors.white24,
                                  height: 1,
                                  thickness: 0.6,
                                ),
                              ),
                            ],
                          );
                        }, childCount: stories.length),
                      ),
                  ],
                );
              },
            ),
          ),
          // ===== SCROLL TO TOP BUTTON =====
          if (_showScrollToTop)
            Positioned(
              bottom: 24,
              right: 16,
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
        ],
      ),
    );
  }
}
