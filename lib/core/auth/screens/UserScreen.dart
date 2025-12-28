import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reading_book_app/core/theme/AppColors.dart';
import 'package:reading_book_app/core/theme/AppTextStyles.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreanState();
}

class _UserScreanState extends State<UserScreen> {
  final List<Map<String, Object>> menuItems = [
    {'label': 'Sưu tập', 'icon': 'assets/icons/favorite.svg'},
    {'label': 'Lịch sử', 'icon': 'assets/icons/history.svg'},
    {'label': 'Tải xuống', 'icon': 'assets/icons/download.svg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 200,
                    alignment: AlignmentGeometry.center,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(color: Colors.transparent),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: 100,
                                height: 100,
                                padding: EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(48),
                                  color: AppColors.primary,
                                ),
                                child: SvgPicture.asset(
                                  'assets/icons/person.svg',
                                  width: 20,
                                  height: 20,
                                  colorFilter: ColorFilter.mode(
                                    AppColors.iconInactive,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              'Ba chị em',
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
                  Container(
                    height: 170,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
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
                            onTap: () {},
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

                                // Arrow
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

                  SizedBox(height: 50),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await DefaultCacheManager().emptyCache();
                        PaintingBinding.instance.imageCache.clear();
                        PaintingBinding.instance.imageCache.clearLiveImages();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã xoá ảnh khỏi cache'),
                          ),
                        );
                      },
                      icon: SvgPicture.asset(
                        'assets/icons/log-out.svg',
                        width: 22,
                        colorFilter: ColorFilter.mode(
                          AppColors.error,
                          BlendMode.srcIn,
                        ),
                      ),
                      label: Text(
                        'Xoá cache ảnh',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.background,
                        foregroundColor: Colors.white,
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
}
