import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
      child: Stack(
        children: [
          // ClipRRect(
          //   borderRadius: BorderRadius.circular(12),
          //   child: Image.network(
          //     book.coverURL,
          //     width: double.infinity,
          //     height: 180,
          //     fit: BoxFit.cover,
          //     errorBuilder: (context, error, stackTrace) {
          //       return Container(
          //         color: Colors.grey,
          //         child: const Icon(Icons.broken_image),
          //       );
          //     },
          //   ),
          // ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: book.coverURL,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,

              placeholder: (context, url) => Container(
                color: AppColors.background,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(strokeWidth: 4),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  book.title,
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (showPlayIcon)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
