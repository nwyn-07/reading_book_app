import 'package:flutter/material.dart';
import 'package:reading_book_app/core/models/StoryCategory.dart';
import 'package:reading_book_app/core/theme/AppTextStyles.dart';

class StoryCategoryItem extends StatelessWidget {
  final StoryCategory category;
  final VoidCallback? onTap;

  const StoryCategoryItem({super.key, required this.category, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = category.isSelected;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.orangeAccent.withOpacity(0.9)
              : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          textAlign: TextAlign.center,
          category.title,
          style: AppTextStyles.h2.copyWith(
            fontSize: 14,
            color: isSelected ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}
