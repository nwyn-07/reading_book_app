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
  bool _initialLoad = false;
  bool _loadingChapters = false;
  int _loadedChapters = 0;
  int _totalChapters = 0;

  @override
  void initState() {
    super.initState();
    print('=== HISTORY SCREEN INIT ===');

    // Load data ngay sau khi widget được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('Post-frame callback triggered');
      _loadInitialData();
    });

    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset > 300 && !_showScrollToTop) {
      setState(() => _showScrollToTop = true);
    } else if (_scrollController.offset <= 300 && _showScrollToTop) {
      setState(() => _showScrollToTop = false);
    }
  }

  Future<void> _loadInitialData() async {
    if (_initialLoad) {
      print('History already loaded, skipping...');
      return;
    }

    print('Starting initial data load...');

    try {
      final historyStore = context.read<HistoryStore>();
      final chapterStore = context.read<ChapterStore>();

      // Load history trước
      print('Calling historyStore.loadHistory()...');
      await historyStore.loadHistory();

      print('History loaded. Cache size: ${historyStore.cache.length}');
      print('Cache keys: ${historyStore.cache.keys.toList()}');

      if (!mounted) {
        print('Widget not mounted after history load');
        return;
      }

      setState(() {
        _initialLoad = true;
        _totalChapters = historyStore.cache.length;
        _loadedChapters = 0;
      });

      // Load từng chapter detail
      if (historyStore.cache.isNotEmpty) {
        print(
          'Starting to load ${historyStore.cache.length} chapter details...',
        );
        _loadingChapters = true;

        for (final h in historyStore.cache.values) {
          print('Loading chapter detail for: ${h.chapterId}');
          try {
            await chapterStore.fetchChapterDetail(h.chapterId);
            _loadedChapters++;

            if (mounted) {
              setState(() {});
              print(
                'Loaded chapter ${_loadedChapters}/$_totalChapters: ${h.chapterId}',
              );
            }
          } catch (e) {
            print('Error loading chapter ${h.chapterId}: $e');
          }
        }

        _loadingChapters = false;
        if (mounted) setState(() {});
        print('Finished loading all chapter details');
      } else {
        print('No history items found');
      }
    } catch (e) {
      print('Error in _loadInitialData: $e');
      if (mounted) {
        setState(() {
          _initialLoad = true;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    print('=== MANUAL REFRESH TRIGGERED ===');

    setState(() {
      _initialLoad = false;
      _loadingChapters = false;
      _loadedChapters = 0;
      _totalChapters = 0;
    });

    await _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    print('=== HISTORY SCREEN DISPOSED ===');
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
    print('=== HISTORY SCREEN BUILD ===');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          RefreshIndicator(
            color: Colors.white,
            backgroundColor: Colors.black.withOpacity(0.7),
            displacement: 40,
            onRefresh: _refreshData,
            child: Consumer2<HistoryStore, ChapterStore>(
              builder: (_, historyStore, chapterStore, __) {
                // Hiển thị loading ban đầu
                if (!_initialLoad) {
                  print('Showing initial loading...');
                  return CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      _buildAppBar(),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Đang tải lịch sử...',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }

                final histories = historyStore.cache.values.toList()
                  ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

                print('Sorted histories: ${histories.length} items');

                if (histories.isEmpty) {
                  print('No history items to display');
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

                // Hiển thị loading chapters
                if (_loadingChapters && _loadedChapters < _totalChapters) {
                  print(
                    'Still loading chapters: $_loadedChapters/$_totalChapters',
                  );
                  return CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      _buildAppBar(),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: AppColors.primary),
                            const SizedBox(height: 16),
                            Text(
                              'Đang tải chi tiết...',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$_loadedChapters/$_totalChapters chương',
                              style: TextStyle(
                                color: AppColors.textSecondary.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                print('Displaying ${histories.length} history items');

                return CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    _buildAppBar(historyStore),

                    // Debug info
                    if (histories.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.primary,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${histories.length} mục lịch sử',
                                  style: TextStyle(
                                    color: AppColors.textSecondary.withOpacity(
                                      0.7,
                                    ),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final history = histories[index];

                        print(
                          'Building item $index - Chapter ID: ${history.chapterId}',
                        );

                        final chapter = chapterStore.getChapterById(
                          history.chapterId,
                        );

                        if (chapter == null) {
                          print(
                            'Chapter ${history.chapterId} not found in cache, showing skeleton',
                          );
                          return _buildSkeletonItem();
                        }

                        final progress = history.totalTimeSeconds > 0
                            ? history.lastPosition / history.totalTimeSeconds
                            : 0.0;

                        print(
                          'Progress for ${history.chapterId}: $progress (${history.lastPosition}/${history.totalTimeSeconds}s)',
                        );

                        return InkWell(
                          onTap: () {
                            print('Tapped on history item: ${chapter.title}');
                            final audioStore = context.read<AudioStore>();
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
                                              errorBuilder: (_, __, ___) {
                                                return Container(
                                                  width: 56,
                                                  height: 56,
                                                  color: AppColors.primary
                                                      .withOpacity(0.2),
                                                  child: Icon(
                                                    Icons.menu_book,
                                                    color: AppColors.primary,
                                                  ),
                                                );
                                              },
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
                                          Row(
                                            children: [
                                              Expanded(
                                                child: LinearProgressIndicator(
                                                  value: progress,
                                                  minHeight: 4,
                                                  backgroundColor:
                                                      Colors.white24,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '${(progress * 100).toStringAsFixed(0)}%',
                                                style: TextStyle(
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Vị trí: ${_formatDuration(history.lastPosition)}',
                                                style: TextStyle(
                                                  color: AppColors.textSecondary
                                                      .withOpacity(0.7),
                                                  fontSize: 11,
                                                ),
                                              ),
                                              Text(
                                                'Cập nhật: ${_formatDate(history.updatedAt)}',
                                                style: TextStyle(
                                                  color: AppColors.textSecondary
                                                      .withOpacity(0.7),
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
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

  SliverAppBar _buildAppBar([HistoryStore? historyStore]) {
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
      actions: historyStore != null
          ? [
              IconButton(
                icon: Icon(Icons.refresh, color: AppColors.primary),
                onPressed: _refreshData,
                tooltip: 'Tải lại',
              ),
              IconButton(
                icon: Icon(Icons.bug_report, color: AppColors.textSecondary),
                onPressed: () {
                  _showDebugInfo(historyStore);
                },
                tooltip: 'Debug',
              ),
            ]
          : null,
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
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _refreshData,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Thử lại'),
        ),
      ],
    );
  }

  Widget _buildSkeletonItem() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      color: Colors.grey[800],
                      margin: const EdgeInsets.only(bottom: 4),
                    ),
                    Container(
                      width: 80,
                      height: 14,
                      color: Colors.grey[800],
                      margin: const EdgeInsets.only(bottom: 8),
                    ),
                    Container(height: 4, color: Colors.grey[800]),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(color: Colors.white24, height: 1, thickness: 0.6),
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    }
    return 'Vừa xong';
  }

  void _showDebugInfo(HistoryStore historyStore) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text(
          'Debug Info',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'History Store:',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '• Cache size: ${historyStore.cache.length}',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              Text(
                '• Cache keys:',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              ...historyStore.cache.keys.map(
                (key) => Text(
                  '  - $key',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Chapter Store:',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Screen State:',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '• Initial load: $_initialLoad',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              Text(
                '• Loading chapters: $_loadingChapters',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              Text(
                '• Loaded chapters: $_loadedChapters/$_totalChapters',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _refreshData();
            },
            child: Text(
              'Force Refresh',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
