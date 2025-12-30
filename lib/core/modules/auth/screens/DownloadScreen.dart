import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:reading_book_app/core/models/Book.dart';
import 'package:reading_book_app/core/models/Chapter.dart';
import 'package:reading_book_app/core/stores/AudioStore.dart';
import 'package:reading_book_app/core/theme/AppColors.dart';
import 'package:path/path.dart' as p;

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  bool _isRefreshing = false;
  List<Map<String, dynamic>>? _cachedStories;
  final Set<String> _expandedStoryIds = {};
  final Map<String, List<Map<String, dynamic>>> _storyChapters = {};
  final Map<String, int> _chapterFileSizes = {}; // Cache kích thước file

  @override
  void initState() {
    super.initState();
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

  Future<void> _refreshDownloads() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    // Xóa cache để force reload
    _cachedStories = null;
    _storyChapters.clear();
    _chapterFileSizes.clear();

    // Chỉ setState một lần
    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<List<Map<String, dynamic>>> _getDownloadedStories(
    AudioStore audioStore,
  ) async {
    // Return cache nếu có
    if (_cachedStories != null && !_isRefreshing) {
      return _cachedStories!;
    }

    final List<Map<String, dynamic>> stories = [];

    try {
      final dir = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${dir.path}/audio');

      if (!await audioDir.exists()) {
        _cachedStories = stories;
        return stories;
      }

      final files = await audioDir.list().toList();
      final Map<String, List<File>> storyFiles = {};

      for (var file in files) {
        if (file is File) {
          final filename = p.basename(file.path);
          final parts = filename.replaceAll('.mp3', '').split('_');
          if (parts.length >= 2) {
            final storyId = parts[0];
            final chapterId = parts[1];
            storyFiles.putIfAbsent(storyId, () => []).add(file);

            await _addChapterInfo(storyId, chapterId, file);
          }
        }
      }

      for (var entry in storyFiles.entries) {
        final storyId = entry.key;
        final files = entry.value;

        int totalSize = 0;
        DateTime? lastModified;

        for (var file in files) {
          final stat = await file.stat();
          totalSize += stat.size;

          if (lastModified == null || stat.modified.isAfter(lastModified)) {
            lastModified = stat.modified;
          }
        }

        String storyTitle = 'Story $storyId';
        String? coverUrl;

        if (audioStore.currentStory?.id == storyId) {
          storyTitle = audioStore.currentStory?.title ?? storyTitle;
          coverUrl = audioStore.currentStory?.coverUrl;
        }

        stories.add({
          'id': storyId,
          'title': storyTitle,
          'coverUrl': coverUrl,
          'size': totalSize,
          'lastModified': lastModified,
          'chapterCount': files.length,
          'files': files,
        });
      }

      stories.sort((a, b) {
        final aDate = a['lastModified'] as DateTime? ?? DateTime(0);
        final bDate = b['lastModified'] as DateTime? ?? DateTime(0);
        return bDate.compareTo(aDate);
      });

      _cachedStories = stories;
    } catch (e) {
      debugPrint('Error getting downloaded stories: $e');
    }

    return stories;
  }

  Future<void> _addChapterInfo(
    String storyId,
    String chapterId,
    File file,
  ) async {
    if (!_storyChapters.containsKey(storyId)) {
      _storyChapters[storyId] = [];
    }

    final fileSize = (await file.stat()).size;
    final fileKey = '$storyId-$chapterId';
    _chapterFileSizes[fileKey] = fileSize;

    final filename = p.basenameWithoutExtension(file.path);
    final parts = filename.split('_');

    String chapterTitle = 'Chương ${parts.length > 2 ? parts[2] : '1'}';
    int chapterIndex = 1;

    if (parts.length > 2) {
      try {
        chapterIndex = int.tryParse(parts[2]) ?? 1;
      } catch (e) {
        chapterIndex = 1;
      }

      if (parts.length > 3) {
        chapterTitle = parts.sublist(3).join(' ');
      }
    }

    _storyChapters[storyId]!.add({
      'id': chapterId,
      'title': chapterTitle,
      'index': chapterIndex,
      'filePath': file.path,
      'file': file,
      'size': fileSize, // Lưu file size vào chapter info
    });

    // Sắp xếp chapters theo index
    _storyChapters[storyId]!.sort((a, b) => a['index'].compareTo(b['index']));
  }

  Future<void> _playChapter(
    String storyId,
    Map<String, dynamic> chapterInfo,
  ) async {
    final audioStore = context.read<AudioStore>();
    final filePath = chapterInfo['filePath'] as String;

    try {
      debugPrint('Playing chapter: $filePath');
      await audioStore.playChapter(
        story: Book(
          id: storyId,
          title: 'Story $storyId',
          coverUrl: '',
          author: '',
          description: '',
          type: '',
        ),
        chapter: Chapter(
          id: chapterInfo['id'],
          title: chapterInfo['title'],
          chapterIndex: chapterInfo['index'],
          content: '',
          durationSeconds: chapterInfo['size'],
          audioUrl: filePath,
          story: Book(
            id: storyId,
            title: 'Story $storyId',
            coverUrl: '',
            author: '',
            description: '',
            type: '',
          ),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đang phát: ${chapterInfo['title']}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Error playing chapter: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi phát chương: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteStory(String storyId, AudioStore audioStore) async {
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
          'Bạn có chắc muốn xóa toan bộ truyện này và tất cả các chương đã tải xuống không?',
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
        final dir = await getApplicationDocumentsDirectory();
        final audioDir = Directory('${dir.path}/audio');

        if (await audioDir.exists()) {
          final files = await audioDir.list().toList();
          int deletedCount = 0;

          for (var file in files) {
            if (file is File && file.path.contains(storyId)) {
              await file.delete();
              deletedCount++;

              // Xóa khỏi cache file size
              final filename = p.basename(file.path);
              final parts = filename.replaceAll('.mp3', '').split('_');
              if (parts.length >= 2) {
                final chapterId = parts[1];
                final fileKey = '$storyId-$chapterId';
                _chapterFileSizes.remove(fileKey);
              }
            }
          }

          // Xóa cache
          _cachedStories = null;
          _storyChapters.remove(storyId);
          _expandedStoryIds.remove(storyId);

          // Chỉ setState một lần
          if (mounted) {
            setState(() {});
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã xóa $deletedCount chương'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error deleting story: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xóa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteChapter(
    String storyId,
    Map<String, dynamic> chapterInfo,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text(
          'Xóa chương',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Bạn có chắc muốn xóa chương này không?',
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
        final file = chapterInfo['file'] as File;
        if (await file.exists()) {
          await file.delete();

          final fileKey = '$storyId-${chapterInfo['id']}';
          _chapterFileSizes.remove(fileKey);

          if (_storyChapters.containsKey(storyId)) {
            _storyChapters[storyId]!.removeWhere(
              (c) => c['id'] == chapterInfo['id'],
            );

            if (_storyChapters[storyId]!.isEmpty) {
              _storyChapters.remove(storyId);
              _expandedStoryIds.remove(storyId);
            }
          }

          _cachedStories = null;

          if (mounted) {
            setState(() {});
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa chương'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error deleting chapter: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xóa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Không xác định';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hôm nay';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _toggleStoryExpansion(String storyId) {
    setState(() {
      if (_expandedStoryIds.contains(storyId)) {
        _expandedStoryIds.remove(storyId);
      } else {
        _expandedStoryIds.add(storyId);
      }
    });
  }

  Widget _buildChapterList(
    String storyId,
    List<Map<String, dynamic>> chapters,
  ) {
    return Consumer<AudioStore>(
      builder: (context, audioStore, _) => Column(
        children: chapters.map((chapter) {
          final title = chapter['title'] as String;
          final fileSize = chapter['size'] as int;

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 8,
            ),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${chapter['index']}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: Text(
              title,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              _formatFileSize(fileSize),
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: SvgPicture.asset(
                    audioStore.isPlaying &&
                            audioStore.currentChapter?.id == chapter['id']
                        ? 'assets/icons/pause.svg'
                        : 'assets/icons/play-1003-svgrepo-com.svg',
                    width: 20,
                    height: 20,
                    color: AppColors.primary,
                  ),
                  onPressed: () => _playChapter(storyId, chapter),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  onPressed: () => _deleteChapter(storyId, chapter),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<AudioStore>(
        builder: (context, audioStore, _) {
          return Stack(
            children: [
              RefreshIndicator(
                color: Colors.white,
                backgroundColor: Colors.black.withOpacity(0.7),
                displacement: 40,
                onRefresh: _refreshDownloads,
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _getDownloadedStories(audioStore),
                  builder: (context, snapshot) {
                    final stories = snapshot.data ?? [];

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
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          title: Text(
                            'Tải xuống',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        if (_isRefreshing)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          )
                        else if (stories.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.download_for_offline_outlined,
                                    size: 80,
                                    color: AppColors.textSecondary.withOpacity(
                                      0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Chưa có truyện tải về',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Các truyện bạn tải về sẽ xuất hiện ở đây',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.textSecondary
                                          .withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final story = stories[index];
                              final storyId = story['id'] as String;
                              final title = story['title'] as String;
                              final size = story['size'] as int;
                              final chapterCount = story['chapterCount'] as int;
                              final lastModified =
                                  story['lastModified'] as DateTime?;
                              final coverUrl = story['coverUrl'] as String?;
                              final isExpanded = _expandedStoryIds.contains(
                                storyId,
                              );
                              final chapters = _storyChapters[storyId] ?? [];

                              return Dismissible(
                                key: Key(
                                  '$storyId-${DateTime.now().millisecondsSinceEpoch}',
                                ),

                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                                onDismissed: (direction) {
                                  _deleteStory(storyId, audioStore);
                                },
                                confirmDismiss: (direction) async {
                                  return await showDialog<bool>(
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
                                            'Bạn có chắc muốn xóa toan bộ truyện này và tất cả các chương đã tải xuống không?',
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: Text(
                                                'Hủy',
                                                style: TextStyle(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: Text(
                                                'Xóa',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ) ??
                                      false;
                                },
                                child: Column(
                                  children: [
                                    // Story header
                                    InkWell(
                                      onTap: () =>
                                          _toggleStoryExpansion(storyId),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        child: Row(
                                          children: [
                                            // Thumbnail
                                            Container(
                                              width: 56,
                                              height: 56,
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: coverUrl != null
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      child: CachedNetworkImage(
                                                        imageUrl: coverUrl,
                                                        width: 56,
                                                        height: 56,
                                                        fit: BoxFit.cover,
                                                        placeholder:
                                                            (
                                                              context,
                                                              url,
                                                            ) => Center(
                                                              child: Icon(
                                                                Icons
                                                                    .headphones,
                                                                size: 32,
                                                                color: AppColors
                                                                    .primary,
                                                              ),
                                                            ),
                                                        errorWidget:
                                                            (
                                                              context,
                                                              url,
                                                              error,
                                                            ) => Center(
                                                              child: Icon(
                                                                Icons
                                                                    .headphones,
                                                                size: 32,
                                                                color: AppColors
                                                                    .primary,
                                                              ),
                                                            ),
                                                      ),
                                                    )
                                                  : Center(
                                                      child: Icon(
                                                        Icons.headphones,
                                                        size: 32,
                                                        color:
                                                            AppColors.primary,
                                                      ),
                                                    ),
                                            ),

                                            const SizedBox(width: 12),

                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          title,
                                                          style: TextStyle(
                                                            color: AppColors
                                                                .textPrimary,
                                                            fontSize: 17,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        '$chapterCount chương',
                                                        style: TextStyle(
                                                          color: AppColors
                                                              .textSecondary,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        '•',
                                                        style: TextStyle(
                                                          color: AppColors
                                                              .textSecondary,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        _formatFileSize(size),
                                                        style: TextStyle(
                                                          color: AppColors
                                                              .textSecondary,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (lastModified != null)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            top: 2,
                                                          ),
                                                      child: Text(
                                                        'Cập nhật: ${_formatDate(lastModified)}',
                                                        style: TextStyle(
                                                          color: AppColors
                                                              .textSecondary,
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),

                                            PopupMenuButton<String>(
                                              icon: Icon(
                                                Icons.more_vert,
                                                color: AppColors.textSecondary,
                                              ),
                                              itemBuilder: (context) => [
                                                const PopupMenuItem(
                                                  value: 'play_all',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .play_circle_outline,
                                                        size: 20,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text('Phát tất cả'),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'delete',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.delete,
                                                        size: 20,
                                                        color: Colors.red,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        'Xóa',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                              onSelected: (value) {
                                                if (value == 'play_all') {
                                                  // TODO: Implement play all chapters
                                                } else if (value == 'delete') {
                                                  _deleteStory(
                                                    storyId,
                                                    audioStore,
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Chapter list (expandable)
                                    if (isExpanded && chapters.isNotEmpty)
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                        child: Column(
                                          children: [
                                            const Divider(
                                              color: Colors.white24,
                                              height: 1,
                                              thickness: 0.6,
                                              indent: 16,
                                              endIndent: 16,
                                            ),
                                            _buildChapterList(
                                              storyId,
                                              chapters,
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      const Divider(
                                        color: Colors.white24,
                                        height: 1,
                                        thickness: 0.6,
                                        indent: 16,
                                        endIndent: 16,
                                      ),
                                  ],
                                ),
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
          );
        },
      ),
    );
  }
}
