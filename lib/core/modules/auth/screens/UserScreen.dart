import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:reading_book_app/core/modules/chapter/WeeklyChart.dart';
import 'package:reading_book_app/core/stores/AudioStore.dart';
import 'package:reading_book_app/core/stores/AuthStore.dart';
import 'package:reading_book_app/core/stores/StoryStore.dart';
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

  Future<void> _handleLogout() async {
    await DefaultCacheManager().emptyCache();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    context.read<StoryStore>().clear();

    await context.read<AuthStore>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStore>();
    final userName = auth.user?['fullName'] ?? 'Người dùng';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          children: [
            // ===== User info =====
            Container(
              height: 200,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(48),
                      color: AppColors.primary,
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/person.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        AppColors.iconInactive,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userName,
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ===== Chart =====
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

            const SizedBox(height: 24),

            // ===== Menu items =====
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

            const SizedBox(height: 50),

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

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
