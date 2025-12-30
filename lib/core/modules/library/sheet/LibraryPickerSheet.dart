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
  bool _isDialogOpen = false;

  @override
  void dispose() {
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

              ListTile(
                leading: const Icon(Icons.add, color: Colors.orangeAccent),
                title: const Text(
                  'Tạo thư viện mới',
                  style: TextStyle(color: Colors.orangeAccent),
                ),
                onTap: () {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
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
            bool isCreating = false;

            Future<void> _createLibrary() async {
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
                    content: Text('Không thể tạo thư viện với tên này'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              setDialogState(() {
                isCreating = true;
              });

              try {
                await libraryStore.createLibrary(name);

                _isDialogOpen = false;
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text('Tạo thư viện thành công'),
                      backgroundColor: Colors.green,
                    ),
                  );
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
              } finally {
                if (dialogContext.mounted) {
                  setDialogState(() {
                    isCreating = false;
                  });
                }
              }
            }

            return AlertDialog(
              backgroundColor: AppColors.background,
              title: Text(
                'Tạo thư viện',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    maxLength: 50,
                    decoration: InputDecoration(
                      hintText: 'Nhập tên thư viện',
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    style: TextStyle(color: AppColors.textPrimary),
                    onSubmitted: (_) {
                      if (!isCreating) {
                        _createLibrary();
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  if (isCreating)
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isCreating
                      ? null
                      : () {
                          _isDialogOpen = false;
                          Navigator.of(dialogContext).pop();
                        },
                  child: Text(
                    'Huỷ',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: isCreating ? null : _createLibrary,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text(
                    'Tạo',
                    style: TextStyle(color: Colors.white),
                  ),
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
