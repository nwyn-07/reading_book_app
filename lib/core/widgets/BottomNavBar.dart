import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reading_book_app/core/theme/AppColors.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<StatefulWidget> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: widget.currentIndex,
      onTap: widget.onTap,
      backgroundColor: AppColors.bottomNavBackground,
      selectedItemColor: AppColors.textPrimary,
      unselectedItemColor: AppColors.textMuted,
      selectedLabelStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        height: 2,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        height: 2,
      ),
      items: [
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/explore.svg',
            width: 22,
            colorFilter: ColorFilter.mode(
              AppColors.iconInactive,
              BlendMode.srcIn,
            ),
          ),
          activeIcon: SvgPicture.asset(
            'assets/icons/explore.svg',
            width: 22,
            colorFilter: ColorFilter.mode(
              AppColors.iconActive,
              BlendMode.srcIn,
            ),
          ),
          label: 'Khám phá',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/audio.svg',
            width: 22,
            colorFilter: ColorFilter.mode(
              AppColors.iconInactive,
              BlendMode.srcIn,
            ),
          ),
          activeIcon: SvgPicture.asset(
            'assets/icons/audio.svg',
            width: 22,
            colorFilter: ColorFilter.mode(
              AppColors.iconActive,
              BlendMode.srcIn,
            ),
          ),
          label: 'Âm thanh',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/book.svg',
            width: 22,
            colorFilter: ColorFilter.mode(
              AppColors.iconInactive,
              BlendMode.srcIn,
            ),
          ),
          activeIcon: SvgPicture.asset(
            'assets/icons/book.svg',
            width: 22,
            colorFilter: ColorFilter.mode(
              AppColors.iconActive,
              BlendMode.srcIn,
            ),
          ),
          label: 'Chuyện ngủ',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/person.svg',
            width: 22,
            colorFilter: ColorFilter.mode(
              AppColors.iconInactive,
              BlendMode.srcIn,
            ),
          ),
          activeIcon: SvgPicture.asset(
            'assets/icons/person.svg',
            width: 22,
            colorFilter: ColorFilter.mode(
              AppColors.iconActive,
              BlendMode.srcIn,
            ),
          ),
          label: 'Tôi',
        ),
      ],
    );
  }
}
