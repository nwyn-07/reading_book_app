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
                            final isFavorite = library.name == 'Yêu thích';

                            return Card(
                              color: AppColors.surface,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isFavorite
                                      ? AppColors.accent
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isFavorite
                                        ? AppColors.accent.withOpacity(0.2)
                                        : AppColors.surface,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Image.asset(
                                    'assets/images/bg.jpg',
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(
                                  library.name,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    '/playlist',
                                    arguments: {'library': library},
                                  );
                                },
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
              title: const Text('Tạo thư viện'),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Tên thư viện',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _isDialogOpen = false;
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Huỷ'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = controller.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng nhập tên thư viện'),
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
                  child: const Text('Tạo'),
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
