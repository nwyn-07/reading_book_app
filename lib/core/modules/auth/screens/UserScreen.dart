import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reading_book_app/core/components/SkeletonBox.dart';
import 'package:reading_book_app/core/modules/cache/BookCacheImageManager.dart';
import 'package:reading_book_app/core/modules/chapter/WeeklyChart.dart';
import 'package:reading_book_app/core/stores/AudioStore.dart';
import 'package:reading_book_app/core/stores/AuthStore.dart';
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

  /// =========================
  /// VIEW AVATAR (FULLSCREEN)
  /// =========================
  void _viewAvatar(String imageUrl) {
    if (imageUrl.isEmpty) return;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Center(
            child: InteractiveViewer(
              maxScale: 3.0,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                cacheManager: BookImageCacheManager(),
              ),
            ),
          ),
        ),
      ),
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
      // Cập nhật AuthStore với avatar mới
      final authStore = context.read<AuthStore>();
      await authStore.updateUserAvatar(userStore.currentUser?.avatarUrl ?? '');

      // Clear cache để load lại hình mới
      await _clearImageCache();

      // Force rebuild widget
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
      // Clear flutter image cache
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      // Clear cache manager
      await DefaultCacheManager().emptyCache();

      // Nếu có custom cache manager cho avatar
      await BookImageCacheManager().emptyCache();
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  Future<void> _handleLogout() async {
    await _clearImageCache();

    context.read<StoryStore>().clear();
    await context.read<AuthStore>().logout();

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
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
          SliverToBoxAdapter(
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

                                    // ⏳ Loading overlay
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
                            const SizedBox(height: 12),
                            Text(
                              userName,
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ===== Chart =====
          SliverToBoxAdapter(
            child: Container(
              height: 220,
              margin: const EdgeInsets.symmetric(horizontal: 16),
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

                  Divider(color: Colors.white38, height: 1, thickness: 0.6),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Consumer<AudioStore>(
                      builder: (_, audio, __) {
                        // Tạo dữ liệu giả sau khi widget được build xong
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (audio.getWeeklyHours().every((e) => e == 0.0)) {
                            audio.fakeWeeklyData();
                          }
                        });

                        final weeklyData = audio.getWeeklyHours();
                        return WeeklyHourChart(data: weeklyData);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ===== Menu items =====
          SliverToBoxAdapter(
            child: Container(
              height: 170,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24),
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: menuItems.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.white.withOpacity(0.1)),
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
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ===== Logout button =====
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
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
                    style: AppTextStyles.body.copyWith(color: AppColors.error),
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
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
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

    final cacheBusterUrl =
        '$avatarUrl?t=${DateTime.now().millisecondsSinceEpoch}';

    return CachedNetworkImage(
      imageUrl: cacheBusterUrl,
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
