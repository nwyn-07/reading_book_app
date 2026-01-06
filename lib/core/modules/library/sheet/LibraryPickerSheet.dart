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
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<LibraryStore>(
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

                // ===== LIST LIBRARIES =====
                SizedBox(
                  height: 300,
                  child: lib.libraries.isEmpty
                      ? const Center(
                          child: Text(
                            'Chưa có thư viện nào',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      : ListView.builder(
                          itemCount: lib.libraries.length,
                          itemBuilder: (_, index) {
                            final library = lib.libraries[index];
                            return ListTile(
                              title: Text(
                                library.name,
                                style: const TextStyle(color: Colors.white),
                              ),
                              onTap: () =>
                                  _addStoryToLibrary(context, lib, library.id),
                            );
                          },
                        ),
                ),

                const Divider(color: Colors.white24),

                // ===== CREATE NEW LIBRARY =====
                ListTile(
                  leading: const Icon(Icons.add, color: Colors.orangeAccent),
                  title: const Text(
                    'Tạo thư viện mới',
                    style: TextStyle(color: Colors.orangeAccent),
                  ),
                  onTap: () {
                    Navigator.of(context).pop(); // đóng bottom sheet
                    _showCreateLibraryDialog(context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ===== ADD STORY =====
  Future<void> _addStoryToLibrary(
    BuildContext context,
    LibraryStore lib,
    String libraryId,
  ) async {
    try {
      await lib.addStoryToLibrary(
        libraryId: libraryId,
        storyId: widget.storyId,
      );

      if (!context.mounted) return;

      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã thêm vào thư viện')));
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ===== CREATE LIBRARY DIALOG =====
  void _showCreateLibraryDialog(BuildContext context) {
    final controller = TextEditingController();
    final libraryStore = context.read<LibraryStore>();

    showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (dialogContext) {
        bool isCreating = false;

        return StatefulBuilder(
          builder: (dialogContext, setState) {
            Future<void> createLibrary() async {
              final name = controller.text.trim();

              if (name.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập tên thư viện'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (name == 'Yêu thích' || name == 'Favorites') {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Tên thư viện không hợp lệ'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              setState(() => isCreating = true);

              try {
                await libraryStore.createLibrary(name);

                if (!dialogContext.mounted) return;

                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Tạo thư viện thành công'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!dialogContext.mounted) return;

                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                if (dialogContext.mounted) {
                  setState(() => isCreating = false);
                }
              }
            }

            return AlertDialog(
              backgroundColor: AppColors.background,
              title: const Text(
                'Tạo thư viện',
                style: TextStyle(color: Colors.white),
              ),
              content: TextField(
                controller: controller,
                autofocus: true,
                maxLength: 50,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Nhập tên thư viện',
                  hintStyle: TextStyle(color: Colors.white54),
                  counterStyle: TextStyle(color: Colors.white38),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.orangeAccent),
                  ),
                ),
                onSubmitted: (_) {
                  if (!isCreating) createLibrary();
                },
              ),
              actions: [
                TextButton(
                  onPressed: isCreating
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text(
                    'Huỷ',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
                ElevatedButton(
                  onPressed: isCreating ? null : createLibrary,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                  ),
                  child: isCreating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Tạo'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
