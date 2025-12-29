import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:reading_book_app/core/stores/LibraryStore.dart';
import 'package:reading_book_app/core/theme/AppColors.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryscreenState();
}

class _LibraryscreenState extends State<LibraryScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LibraryStore>().fetchLibraries();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_isDialogOpen) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    super.dispose();
  }

  Future<bool> _confirmDeleteLibrary(BuildContext context, String name) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.background,
            title: Text(
              'Xóa thư viện "$name"',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Bạn có chắc chắn muốn xóa thư viện này?',
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
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateLibraryDialog,
        backgroundColor: AppColors.primary,
        child: SvgPicture.asset(
          'assets/icons/plus.svg',
          width: 22,
          colorFilter: const ColorFilter.mode(Colors.white54, BlendMode.srcIn),
        ),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            color: Colors.white,
            backgroundColor: Colors.black.withOpacity(0.7),
            displacement: 40,
            onRefresh: () => context.read<LibraryStore>().fetchLibraries(),
            child: Consumer<LibraryStore>(
              builder: (_, lib, _) {
                final libraries = lib.libraries;

                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      centerTitle: true,
                      pinned: true,
                      backgroundColor: AppColors.background,
                      elevation: 0,
                      title: Text(
                        'Thư viện',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    if (libraries.isEmpty) ...{
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              Text(
                                'Chưa có thư viện nào',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () => _showCreateLibraryDialog(),
                                icon: Icon(Icons.add, size: 20),
                                label: Text('Tạo thư viện đầu tiên'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    } else ...{
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final library = libraries[index];

                            final cachedStories = lib.libStories[library.id];
                            final storyCount = cachedStories?.length ?? 0;

                            debugPrint(
                              'Library ${library.name} (id: ${library.id}) has $storyCount stories',
                            );

                            final isFavoriteLib = library.name == 'Yêu thích';

                            return Dismissible(
                              key: ValueKey(library.id),
                              direction: isFavoriteLib
                                  ? DismissDirection.none
                                  : DismissDirection.endToStart,
                              confirmDismiss: (_) async {
                                return await _confirmDeleteLibrary(
                                  context,
                                  library.name,
                                );
                              },
                              onDismissed: (_) async {
                                await context
                                    .read<LibraryStore>()
                                    .deleteLibrary(library.id);
                              },
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              child: Card(
                                color: AppColors.surface,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: SvgPicture.asset(
                                      'assets/icons/library.svg',
                                      width: 24,
                                      height: 24,
                                      colorFilter: ColorFilter.mode(
                                        isFavoriteLib
                                            ? Colors.red
                                            : AppColors.primary,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    library.name,
                                    style: TextStyle(
                                      color: isFavoriteLib
                                          ? Colors.red
                                          : AppColors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '$storyCount truyện',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                      '/playlist',
                                      arguments: library,
                                    );
                                  },
                                ),
                              ),
                            );
                          }, childCount: libraries.length),
                        ),
                      ),
                    },
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateLibraryDialog() {
    final controller = TextEditingController();
    final libraryStore = context.read<LibraryStore>();

    _isDialogOpen = true;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              title: Text(
                'Tạo thư viện',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              content: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Tên thư viện',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                style: TextStyle(color: AppColors.textPrimary),
                autofocus: true,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _isDialogOpen = false;
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(
                    'Huỷ',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = controller.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text('Vui lòng nhập tên thư viện'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (name == 'Yêu thích' || name == 'Favorites') {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text('Không thể tạo thư viện với tên này'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      await libraryStore.createLibrary(name);

                      _isDialogOpen = false;
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                    } catch (e) {
                      if (dialogContext.mounted) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(
                            content: Text('Lỗi: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text('Tạo', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      _isDialogOpen = false;
    });
  }
}
