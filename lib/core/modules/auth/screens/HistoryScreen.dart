import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reading_book_app/core/stores/ChapterStore.dart';
import 'package:reading_book_app/core/stores/HistoryStore.dart';
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

                return Consumer<ChapterStore>(
                  builder: (_, chapterStore, __) {
                    return CustomScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        _buildAppBar(),
                        SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final history = histories[index];
                            final chapter = chapterStore.getChapterById(
                              history.chapterId,
                            );

                            if (chapter == null) {
                              return const SizedBox.shrink();
                            }

                            final progress = history.totalTimeSeconds > 0
                                ? history.lastPosition /
                                      history.totalTimeSeconds
                                : 0.0;

                            return _HistoryItem(
                              chapter: chapter,
                              progress: progress,
                              resumeSeconds: history.lastPosition,
                            );
                          }, childCount: histories.length),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          if (_showScrollToTop)
            Positioned(
              bottom: 24,
              right: 16,
              child: FloatingActionButton(
                backgroundColor: AppColors.primary.withOpacity(0.7),
                onPressed: _scrollToTop,
                child: const Icon(Icons.arrow_upward_rounded),
              ),
            ),
        ],
      ),
    );
  }

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
      ],
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final dynamic chapter;
  final double progress;
  final int resumeSeconds;

  const _HistoryItem({
    required this.chapter,
    required this.progress,
    required this.resumeSeconds,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioStore>(
      builder: (_, audioStore, _) => InkWell(
        onTap: () async {
          final audio = audioStore;

          final isSameChapter = audio.currentChapter?.id == chapter.id;

          if (isSameChapter) {
            if (audio.isPlaying) {
              audio.pause();
            } else {
              audio.resume();
            }
            return;
          }

          await audio.playChapter(
            story: chapter.story,
            chapter: chapter,
            resumePositionSeconds: resumeSeconds,
          );
        },

        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: chapter.story.coverUrl?.isNotEmpty == true
                        ? Image.network(
                            chapter.story.coverUrl!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 56,
                            height: 56,
                            color: AppColors.primary.withOpacity(0.2),
                            child: Icon(
                              Icons.menu_book,
                              color: AppColors.primary,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chapter.story.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          chapter.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  audioStore.isPlaying &&
                          audioStore.currentChapter?.id == chapter.id
                      ? Icon(
                          Icons.pause_circle_filled,
                          color: AppColors.primary,
                          size: 28,
                        )
                      : Icon(
                          Icons.play_circle_fill,
                          color: AppColors.primary,
                          size: 28,
                        ),
                ],
              ),
            ),
            // const Divider(thickness: 0.3),
          ],
        ),
      ),
    );
  }
}
