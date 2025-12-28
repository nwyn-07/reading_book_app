import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:reading_book_app/core/components/SkeletonBox.dart';
import 'package:reading_book_app/core/modules/cache/BookCacheImageManager.dart';
import 'package:reading_book_app/core/models/Book.dart';
import 'package:reading_book_app/core/theme/AppColors.dart';
import 'package:reading_book_app/core/theme/AppTextStyles.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final bool showPlayIcon;

  const BookCard(this.book, this.showPlayIcon, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: GestureDetector(
        onTap: () => {
          Navigator.of(context).pushNamed(
            '/chapter',
            arguments: {'storyId': book.id, 'storyTitle': book.title},
          ),
        },
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: book.coverUrl,
                cacheManager: BookImageCacheManager(),

                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,

                placeholder: (context, url) => SkeletonBox(
                  width: double.infinity,
                  height: double.infinity,
                ),

                errorWidget: (context, url, error) => Container(
                  color: Colors.grey,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.background.withOpacity(0.85),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Row(
                children: [
                  /// 👇 QUAN TRỌNG
                  Expanded(
                    child: Text(
                      book.title,
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  if (showPlayIcon) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
