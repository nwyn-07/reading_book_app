import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reading_book_app/core/stores/LibraryStore.dart';
import 'package:reading_book_app/core/theme/AppColors.dart';

class LibraryPickerSheet extends StatefulWidget {
  final String storyId;

  const LibraryPickerSheet({super.key, required this.storyId});

  @override
  State<LibraryPickerSheet> createState() => _LibraryPickerSheetState();
}

class _LibraryPickerSheetState extends State<LibraryPickerSheet> {
  // Biến để theo dõi xem dialog đang mở hay không
  bool _isDialogOpen = false;

  @override
  void dispose() {
    // Đảm bảo đóng dialog khi widget bị dispose
    if (_isDialogOpen && context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryStore>(
      builder: (_, lib, _) {
        if (lib.isLoading) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Thêm vào thư viện',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              /// ====== LIST LIBRARIES ======
              ...lib.libraries.map(
                (library) => ListTile(
                  title: Text(
                    library.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () => _addStoryToLibrary(lib, library.id),
                ),
              ),
              const Divider(color: Colors.white24),

              /// ====== CREATE NEW LIBRARY ======
              ListTile(
                leading: const Icon(Icons.add, color: Colors.orangeAccent),
                title: const Text(
                  'Tạo thư viện mới',
                  style: TextStyle(color: Colors.orangeAccent),
                ),
                onTap: () {
                  // Đóng bottom sheet trước
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                  // Mở dialog tạo thư viện
                  _showCreateLibraryDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addStoryToLibrary(LibraryStore lib, String libraryId) async {
    try {
      await lib.addStoryToLibrary(
        libraryId: libraryId,
        storyId: widget.storyId,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã thêm vào thư viện')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
