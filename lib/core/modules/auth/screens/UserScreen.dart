import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';

import 'package:provider/provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reading_book_app/core/components/SkeletonBox.dart';
import 'package:reading_book_app/core/modules/cache/BookCacheImageManager.dart';
import 'package:reading_book_app/core/modules/chapter/WeeklyChart.dart';
import 'package:reading_book_app/core/stores/AudioStore.dart';
import 'package:reading_book_app/core/stores/AuthStore.dart';
import 'package:reading_book_app/core/stores/StatsStore.dart';
import 'package:reading_book_app/core/stores/StoryStore.dart';
import 'package:reading_book_app/core/stores/UserStore.dart';
import 'package:reading_book_app/core/theme/AppColors.dart';
import 'package:reading_book_app/core/theme/AppTextStyles.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final List<Map<String, dynamic>> menuItems = [
    {
      'label': 'Sưu tập',
      'icon': 'assets/icons/favorite.svg',
      'type': 'library',
    },
    {
      'label': 'Lịch sử',
      'icon': 'assets/icons/history.svg',
      'route': '/history',
    },
    {
      'label': 'Tải xuống',
      'icon': 'assets/icons/download.svg',
      'route': '/download',
    },
  ];

  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatsStore>().fetchDayStats();
    });
  }

  /// =========================
  /// VIEW AVATAR (FULLSCREEN)
  /// =========================
  void _viewAvatar(String imageUrl) {
    if (imageUrl.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (_) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.pop(context),
              ),
            ),

            Center(
              child: GestureDetector(
                onTap: () {},
                child: InteractiveViewer(
                  maxScale: 3,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickAvatarSource() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPickItem(
                icon: Icons.photo_library,
                label: 'Chọn từ thư viện',
                source: ImageSource.gallery,
              ),
              _buildPickItem(
                icon: Icons.camera_alt,
                label: 'Chụp ảnh',
                source: ImageSource.camera,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Hủy',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPickItem({
    required IconData icon,
    required String label,
    required ImageSource source,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        _pickAndUpdateAvatar(source);
      },
    );
  }

  Future<void> _pickAndUpdateAvatar(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (picked == null) return;

    final file = File(picked.path);
    final userStore = context.read<UserStore>();

    final success = await userStore.updateProfile(avatarFile: file);

    if (!mounted) return;

    if (success) {
      final authStore = context.read<AuthStore>();
      await authStore.updateUserAvatar(userStore.currentUser?.avatarUrl ?? '');

      await _clearImageCache();
      setState(() {});
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Cập nhật ảnh đại diện thành công' : 'Cập nhật thất bại',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _clearImageCache() async {
    try {
      PaintingBinding.instance.imageCache?.clear();
      PaintingBinding.instance.imageCache?.clearLiveImages();

      await DefaultCacheManager().emptyCache();
      await BookImageCacheManager().emptyCache();
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  Future<void> _handleLogout() async {
    await _clearImageCache();

    context.read<StoryStore>().clear();
    context.read<AudioStore>().reset();
    await context.read<AuthStore>().logout();
  }

  String _getAvatarUrl(AuthStore auth, UserStore userStore) {
    final userAvatar = userStore.currentUser?.avatarUrl;
    if (userAvatar != null && userAvatar.isNotEmpty) {
      return userAvatar;
    }

    return auth.user?['avatarUrl'] ?? '';
  }

  String _getUserName(AuthStore auth, UserStore userStore) {
    final userName = userStore.currentUser?.fullName;
    if (userName != null && userName.isNotEmpty) {
      return userName;
    }

    return auth.user?['fullName'] ?? 'Người dùng';
  }

  /// =========================
  /// EDIT NAME FUNCTIONS
  /// =========================
  Future<void> _showEditNameDialog(String currentName) async {
    _nameController.text = currentName;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isUpdating = false;

            Future<void> _saveName() async {
              final newName = _nameController.text.trim();
              if (newName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tên không được để trống'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              setState(() {
                isUpdating = true;
              });

              try {
                final userStore = context.read<UserStore>();
                final success = await userStore.updateProfile(
                  fullName: newName,
                );

                if (success) {
                  final authStore = context.read<AuthStore>();
                  await authStore.updateUserName(newName);

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cập nhật tên thành công'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cập nhật tên thất bại'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
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
              } finally {
                if (mounted) {
                  setState(() {
                    isUpdating = false;
                  });
                }
              }
            }

            return AlertDialog(
              backgroundColor: AppColors.background,
              title: Text(
                'Chỉnh sửa tên',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    autofocus: true,
                    maxLength: 50,
                    decoration: InputDecoration(
                      hintText: 'Nhập tên của bạn',
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
                      if (!isUpdating) {
                        _saveName();
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  if (isUpdating)
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isUpdating
                      ? null
                      : () {
                          _nameController.clear();
                          Navigator.pop(context);
                        },
                  child: Text(
                    'Hủy',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: isUpdating ? null : _saveName,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text(
                    'Lưu',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      _nameController.clear();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStore>();
    final userStore = context.watch<UserStore>();

    final avatarUrl = _getAvatarUrl(auth, userStore);
    final userName = _getUserName(auth, userStore);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              // decoration: const BoxDecoration(
              //   image: DecorationImage(
              //     image: AssetImage('assets/images/background.png'),
              //     fit: BoxFit.cover,
              //   ),
              // ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 200,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: const BoxDecoration(color: Colors.transparent),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(48),
                                color: AppColors.primary,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  if (avatarUrl.isNotEmpty) {
                                    _viewAvatar(avatarUrl);
                                  }
                                },
                                onLongPress: _pickAvatarSource,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(52),
                                      child: auth.user == null
                                          ? SvgPicture.asset(
                                              'assets/icons/person.svg',
                                              width: 24,
                                              height: 24,
                                              colorFilter: ColorFilter.mode(
                                                AppColors.iconInactive,
                                                BlendMode.srcIn,
                                              ),
                                            )
                                          : _buildAvatarImage(avatarUrl),
                                    ),

                                    if (userStore.isUpdating)
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.4),
                                          borderRadius: BorderRadius.circular(
                                            52,
                                          ),
                                        ),
                                        child: const CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onLongPress: () {
                                _showEditNameDialog(userName);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    userName,
                                    style: AppTextStyles.body.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w300,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    height: 220,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/chart.svg',
                              width: 20,
                              height: 20,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tuần này',
                              style: AppTextStyles.body.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Divider(
                          color: Colors.white38,
                          height: 1,
                          thickness: 0.6,
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: Consumer<StatsStore>(
                            builder: (_, stats, __) {
                              if (stats.loading) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (stats.dayStats == null ||
                                  stats.dayStats!.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'Chưa có dữ liệu tuần này',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                );
                              }

                              return WeeklyHourChart(
                                items: stats.dayStats!, // ✅ DATA THẬT
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    height: 170,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: menuItems.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: Colors.white.withOpacity(0.1),
                      ),
                      itemBuilder: (context, index) {
                        final item = menuItems[index];
                        return SizedBox(
                          height: 56,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              if (item['type'] == 'library') {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/home',
                                  (route) => false,
                                  arguments: {'tab': 2},
                                );
                              } else if (item['route'] != null) {
                                Navigator.pushNamed(context, item['route']);
                              }
                            },
                            child: Row(
                              children: [
                                const SizedBox(width: 16),
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: SvgPicture.asset(
                                    item['icon'] as String,
                                    colorFilter: ColorFilter.mode(
                                      AppColors.iconActive,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    item['label'] as String,
                                    style: AppTextStyles.body.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(right: 16),
                                  child: Icon(
                                    Icons.chevron_right,
                                    color: Colors.white38,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _handleLogout,
                      icon: SvgPicture.asset(
                        'assets/icons/log-out.svg',
                        width: 22,
                        colorFilter: ColorFilter.mode(
                          AppColors.error,
                          BlendMode.srcIn,
                        ),
                      ),
                      label: Text(
                        'Đăng xuất',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.background,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage(String avatarUrl) {
    if (avatarUrl.isEmpty) {
      return SvgPicture.asset(
        'assets/icons/person.svg',
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(AppColors.iconInactive, BlendMode.srcIn),
      );
    }

    return CachedNetworkImage(
      imageUrl: avatarUrl,
      cacheManager: BookImageCacheManager(),
      width: 100,
      height: 100,
      fit: BoxFit.cover,
      placeholder: (_, __) => SkeletonBox(width: 100, height: 100),
      errorWidget: (_, __, ___) => SvgPicture.asset(
        'assets/icons/person.svg',
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(AppColors.iconInactive, BlendMode.srcIn),
      ),
    );
  }
}
