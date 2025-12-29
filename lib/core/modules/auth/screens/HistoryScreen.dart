import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reading_book_app/core/stores/ChapterStore.dart';

import 'package:reading_book_app/core/stores/HistoryStore.dart';
import 'package:reading_book_app/core/stores/StoryStore.dart';
import 'package:reading_book_app/core/stores/AudioStore.dart';
import 'package:reading_book_app/core/theme/AppColors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final historyStore = context.read<HistoryStore>();
      final chapterStore = context.read<ChapterStore>();

      await historyStore.loadHistory();

      for (final h in historyStore.cache.values) {
        chapterStore.fetchChapterDetail(h.chapterId);
      }
    });

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
            onRefresh: () => context.read<HistoryStore>().loadHistory(),
            child: Consumer<HistoryStore>(
              builder: (_, historyStore, __) {
                final histories = historyStore.cache.values.toList()
                  ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

                if (histories.isEmpty) {
                  return CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      _buildAppBar(),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmpty(),
                      ),
                    ],
                  );
                }

                final storyStore = context.read<StoryStore>();
                final audioStore = context.read<AudioStore>();
                final chapterStore = context.read<ChapterStore>();

                return CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    _buildAppBar(),

                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final history = histories[index];

                        final chapter = chapterStore.getChapterById(
                          history.chapterId,
                        );

                        if (chapter == null) {
                          return const SizedBox.shrink(); // chờ frame sau
                        }

                        final progress = history.totalTimeSeconds > 0
                            ? history.lastPosition / history.totalTimeSeconds
                            : 0.0;

                        return InkWell(
                          onTap: () {
                            audioStore.playChapter(
                              story: chapter.story,
                              chapter: chapter,
                              resumePositionSeconds: history.lastPosition,
                            );
                          },
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    // ===== COVER =====
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child:
                                          chapter.story.coverUrl != null &&
                                              chapter.story.coverUrl!.isNotEmpty
                                          ? Image.network(
                                              chapter.story.coverUrl!,
                                              width: 56,
                                              height: 56,
                                              fit: BoxFit.cover,
                                            )
                                          : Container(
                                              width: 56,
                                              height: 56,
                                              color: AppColors.primary
                                                  .withOpacity(0.2),
                                              child: Icon(
                                                Icons.menu_book,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                    ),

                                    const SizedBox(width: 12),

                                    // ===== INFO =====
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            chapter.story.title,
                                            style: TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            chapter.title,
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 13,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),

                                          // ===== PROGRESS =====
                                          LinearProgressIndicator(
                                            value: progress,
                                            minHeight: 4,
                                            backgroundColor: Colors.white24,
                                            color: AppColors.primary,
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    Icon(
                                      Icons.play_circle_fill,
                                      color: AppColors.primary,
                                      size: 28,
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
                          ),
                        );
                      }, childCount: histories.length),
                    ),
                  ],
                );
              },
            ),
          ),

          // ===== SCROLL TO TOP =====
          if (_showScrollToTop)
            Positioned(
              bottom: 24,
              right: 16,
              child: FloatingActionButton(
                backgroundColor: AppColors.primary.withOpacity(0.7),
                foregroundColor: Colors.white,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                onPressed: _scrollToTop,
                child: const Icon(Icons.arrow_upward_rounded),
              ),
            ),
        ],
      ),
    );
  }

  // ================= UI PARTS =================

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      centerTitle: true,
      pinned: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      title: Text(
        'Lịch sử nghe',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.history,
          size: 72,
          color: AppColors.textSecondary.withOpacity(0.5),
        ),
        const SizedBox(height: 16),
        Text(
          'Chưa có lịch sử nghe',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          'Các chương bạn đã nghe sẽ xuất hiện ở đây',
          style: TextStyle(
            color: AppColors.textSecondary.withOpacity(0.7),
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
