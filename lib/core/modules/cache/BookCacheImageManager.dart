import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class BookImageCacheManager extends CacheManager {
  static const key = 'bookImageCache';

  static final BookImageCacheManager _instance =
      BookImageCacheManager._internal();

  factory BookImageCacheManager() {
    return _instance;
  }

  BookImageCacheManager._internal()
    : super(
        Config(
          key,
          stalePeriod: const Duration(days: 7), // cache 7 ngày
          maxNrOfCacheObjects: 200, // tối đa 200 ảnh
        ),
      );
}
