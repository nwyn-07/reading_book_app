import 'package:flutter/material.dart';
import 'package:reading_book_app/core/theme/AppColors.dart';

class RecommendedWidget extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<String> stories;
  final void Function(int index) onStorySelected;

  const RecommendedWidget({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    required this.stories,
    required this.onStorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      //color: AppColors.accent,
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isExpanded ? AppColors.background : AppColors.accent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          /// Collapsed row (always visible)
          GestureDetector(
            onTap: onToggle,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Đề nghị',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                  color: Colors.white,
                ),
              ],
            ),
          ),

          /// Expanded content
          if (isExpanded) ...[
            const SizedBox(height: 12),
            GridView.builder(
              itemCount: stories.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.6,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => onStorySelected(index),

                  child: Container(
                    height: 50,
                    width: 30,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),

                    child: Center(
                      child: Text(
                        stories[index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
