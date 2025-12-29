import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reading_book_app/core/models/Library.dart';
import 'package:reading_book_app/core/models/LibraryStory.dart';
import 'package:reading_book_app/core/stores/LibraryStore.dart';
import 'package:reading_book_app/core/theme/AppColors.dart';

class PlaylistScreen extends StatefulWidget {
  final Library? library;
  final bool isFavorite;
  const PlaylistScreen({
    super.key,
    required this.library,
    this.isFavorite = false,
  });

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  List<LibraryStory> _stories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLibraryStories();
    });
    _scrollController.addListener(() {
      if (_scrollController.offset > 300 && !_showScrollToTop) {
        setState(() => _showScrollToTop = true);
      } else if (_scrollController.offset <= 300 && _showScrollToTop) {
        setState(() => _showScrollToTop = false);
      }
    });
  }

  Future<void> _loadLibraryStories() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final libraryStore = context.read<LibraryStore>();
    try {
      final stories = await libraryStore.getLibraryStories(widget.library!.id);
      setState(() {
        _stories = stories;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải danh sách truyện: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
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
    final libraryName = widget.library?.name ?? 'Thư viện';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          RefreshIndicator(
            color: Colors.white,
            backgroundColor: Colors.black.withOpacity(0.7),
            displacement: 40,
            onRefresh: () async {
              await context.read<LibraryStore>().fetchLibraries();
              await _loadLibraryStories();
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  centerTitle: true,
                  pinned: true,
                  backgroundColor: AppColors.background,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(
                    libraryName,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                if (_isLoading && _stories.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppColors.primary),
                          const SizedBox(height: 16),
                          Text(
                            'Đang tải...',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_stories.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bookmark_border,
                            color: AppColors.textSecondary,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.isFavorite
                                ? 'Chưa có truyện yêu thích'
                                : 'Thư viện trống',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.isFavorite
                                ? 'Nhấn ♡ để thêm truyện vào yêu thích'
                                : 'Thêm truyện vào thư viện này để xem tại đây',
                            style: TextStyle(
                              color: AppColors.textSecondary.withOpacity(0.7),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                //=====LIST=====
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final libraryStory = _stories[index];
                      final story = libraryStory.story;

                      return GestureDetector(
                        onTap: () {
                          Navigator.of(
                            context,
                          ).pushNamed('/chapter', arguments: {'story': story});
                        },
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  // Sử dụng Image.network thay vì Image.asset
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: story.coverUrl.isNotEmpty
                                        ? Image.network(
                                            story.coverUrl,
                                            width: 56,
                                            height: 56,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Container(
                                                width: 56,
                                                height: 56,
                                                color: AppColors.primary
                                                    .withOpacity(0.1),
                                                child: Center(
                                                  child: CircularProgressIndicator(
                                                    value:
                                                        loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                  .cumulativeBytesLoaded /
                                                              loadingProgress
                                                                  .expectedTotalBytes!
                                                        : null,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              );
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Container(
                                                    width: 56,
                                                    height: 56,
                                                    color: AppColors.primary
                                                        .withOpacity(0.1),
                                                    child: Icon(
                                                      Icons.book,
                                                      color: AppColors.primary,
                                                    ),
                                                  );
                                                },
                                          )
                                        : Container(
                                            width: 56,
                                            height: 56,
                                            color: AppColors.primary
                                                .withOpacity(0.1),
                                            child: Icon(
                                              Icons.book,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          story.title,
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          story.author.isNotEmpty
                                              ? story.author
                                              : 'Tác giả chưa rõ',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Remove from library button (optional)
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red.withOpacity(0.7),
                                    ),
                                    onPressed: () {
                                      _removeFromLibrary(libraryStory);
                                    },
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
                    }, childCount: _stories.length),
                  ),
              ],
            ),
          ),

          // ===== SCROLL TO TOP BUTTON =====
          if (_showScrollToTop && _stories.isNotEmpty)
            Positioned(
              bottom: 24,
              right: 16,
              child: FloatingActionButton(
                backgroundColor: AppColors.primary.withOpacity(0.8),
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

  Future<void> _removeFromLibrary(LibraryStory libraryStory) async {
    final libraryStore = context.read<LibraryStore>();
    final libraryId = widget.library?.id;

    if (libraryId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text(
          'Xóa truyện',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Bạn có chắc muốn xóa "${libraryStory.story.title}" khỏi thư viện?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Hủy',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Gọi API để xóa truyện khỏi thư viện
        await libraryStore.removeStoryFromLibrary(
          libraryId: libraryId,
          storyId: libraryStory.story.id,
        );

        // Refresh the list
        await _loadLibraryStories();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa truyện khỏi thư viện'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xóa truyện: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
