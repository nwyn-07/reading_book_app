import 'package:flutter/material.dart';
import 'package:reading_book_app/core/models/Library.dart';
import 'package:reading_book_app/core/models/LibraryStory.dart';
import 'package:reading_book_app/core/services/api/CoreService.dart';

class LibraryStore extends ChangeNotifier {
  final _api = CoreServices.instance;

  // ===== DATA =====
  List<Library> _libraries = [];
  final Set<String> _favoriteStoryIds = {};

  final Map<String, List<LibraryStory>> _libStories = {};

  final Map<String, DateTime> _libStoriesTimestamp = {};

  String? _favoriteLibraryId;
  bool _loading = false;
  String? _error;

  // ===== GETTERS =====
  bool get isLoading => _loading;
  String? get error => _error;

  List<Library> get libraries => _libraries;
  Set<String> get favoriteStoryIds => _favoriteStoryIds;

  Map<String, List<LibraryStory>> get libStories => _libStories;
  Map<String, DateTime> get libStoriesTimestamp => _libStoriesTimestamp;

  Future<void> init() async {
    await fetchLibraries();
    await fetchFavoriteStories();
  }

  Future<void> fetchLibraries() async {
    _loading = true;

    try {
      _libraries = await _api.library();

      for (final lib in _libraries) {
        final stories = await _api.libraryStories(lib.id);
        _libStories[lib.id] = stories;
        _libStoriesTimestamp[lib.id] = DateTime.now();
      }

      final fav = _libraries.firstWhere(
        (e) => e.name == 'Yêu thích',
        orElse: () =>
            createLibrary('Yêu thích').then((_) {
                  return _libraries.firstWhere((e) => e.name == 'Yêu thích');
                })
                as Library,
      );

      _favoriteLibraryId = fav.id;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> createLibrary(String name) async {
    await _api.addLibrary(name);
    await fetchLibraries();
  }

  Future<void> addStoryToLibrary({
    required String libraryId,
    required String storyId,
  }) async {
    await _api.addStoryToLibrary(libraryId: libraryId, storyId: storyId);

    // Clear cache for this library
    _libStories.remove(libraryId);
    _libStoriesTimestamp.remove(libraryId);

    // If this is favorite library, update favorite ids
    if (libraryId == _favoriteLibraryId) {
      _favoriteStoryIds.add(storyId);
    }

    notifyListeners();
  }

  // ===============================
  // FAVORITE STORIES
  // ===============================
  Future<void> fetchFavoriteStories() async {
    if (_favoriteLibraryId == null) return;

    try {
      final res = await _api.libraryStories(_favoriteLibraryId!);

      _favoriteStoryIds
        ..clear()
        ..addAll(res.map((e) => e.story.id));

      _libStories[_favoriteLibraryId!] = res;
      _libStoriesTimestamp[_favoriteLibraryId!] = DateTime.now();
    } catch (e) {
      debugPrint('Fetch favorite error: $e');
    }

    notifyListeners();
  }

  bool isFavorite(String storyId) {
    return _favoriteStoryIds.contains(storyId);
  }

  Future<void> addToFavorite(String storyId) async {
    if (_favoriteLibraryId == null) {
      await fetchLibraries();
    }

    _favoriteStoryIds.add(storyId);

    if (_libStories.containsKey(_favoriteLibraryId!)) {
      _libStories.remove(_favoriteLibraryId!);
      _libStoriesTimestamp.remove(_favoriteLibraryId!);
    }

    notifyListeners();

    try {
      await _api.addStoryToLibrary(
        libraryId: _favoriteLibraryId!,
        storyId: storyId,
      );
    } catch (e) {
      _favoriteStoryIds.remove(storyId);

      _libStories.remove(_favoriteLibraryId!);
      _libStoriesTimestamp.remove(_favoriteLibraryId!);

      notifyListeners();
    }
  }

  Future<void> removeStoryFromLibrary({
    required String libraryId,
    required String storyId,
  }) async {
    debugPrint(
      '[LibraryStore] removeStoryFromLibrary → libraryId=$libraryId, storyId=$storyId',
    );

    // ===== LƯU STATE CŨ ĐỂ ROLLBACK =====
    final prevStories = _libStories[libraryId];
    final prevFavoriteIds = Set<String>.from(_favoriteStoryIds);

    try {
      // ===== CALL API =====
      await _api.removeStoryFromLibrary(libraryId: libraryId, storyId: storyId);

      // ===== UPDATE LOCAL STATE =====
      _libStories.remove(libraryId);
      _libStoriesTimestamp.remove(libraryId);

      if (libraryId == _favoriteLibraryId) {
        _favoriteStoryIds.remove(storyId);
      }

      debugPrint(
        '[LibraryStore] removeStoryFromLibrary SUCCESS → storyId=$storyId',
      );

      notifyListeners();
    } catch (e, stack) {
      // ===== LOG ERROR =====
      debugPrint(
        '[LibraryStore][ERROR] removeStoryFromLibrary FAILED\n'
        'libraryId=$libraryId\n'
        'storyId=$storyId\n'
        'error=$e',
      );
      debugPrintStack(stackTrace: stack);

      // ===== ROLLBACK STATE =====
      if (prevStories != null) {
        _libStories[libraryId] = prevStories;
      }
      _favoriteStoryIds
        ..clear()
        ..addAll(prevFavoriteIds);

      notifyListeners();

      // 👉 optional: rethrow nếu UI cần bắt lỗi
      // rethrow;
    }
  }

  Future<void> removeFromFavorite(String storyId) async {
    if (_favoriteLibraryId == null) return;

    _favoriteStoryIds.remove(storyId);

    if (_libStories.containsKey(_favoriteLibraryId!)) {
      final cachedStories = _libStories[_favoriteLibraryId!];
      if (cachedStories != null) {
        cachedStories.removeWhere((libStory) => libStory.story.id == storyId);
        _libStoriesTimestamp[_favoriteLibraryId!] = DateTime.now();
      }
    }

    notifyListeners();

    try {
      await _api.removeStoryFromLibrary(
        libraryId: _favoriteLibraryId!,
        storyId: storyId,
      );
    } catch (e) {
      _favoriteStoryIds.add(storyId);

      _libStories.remove(_favoriteLibraryId!);
      _libStoriesTimestamp.remove(_favoriteLibraryId!);

      notifyListeners();
    }
  }

  Future<List<LibraryStory>> getLibraryStories(
    String libraryId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _libStories.containsKey(libraryId)) {
      final cachedTime = _libStoriesTimestamp[libraryId];
      final now = DateTime.now();

      if (cachedTime != null && now.difference(cachedTime).inMinutes < 5) {
        return _libStories[libraryId]!;
      }
    }

    try {
      final res = await _api.libraryStories(libraryId);

      _libStories[libraryId] = res;
      _libStoriesTimestamp[libraryId] = DateTime.now();

      return res;
    } catch (e) {
      debugPrint('Get library stories error: $e');

      return _libStories[libraryId] ?? [];
    }
  }

  void clearCache() {
    _libStories.clear();
    _libStoriesTimestamp.clear();
    notifyListeners();
  }

  void clearLibraryCache(String libraryId) {
    _libStories.remove(libraryId);
    _libStoriesTimestamp.remove(libraryId);
    notifyListeners();
  }

  List<LibraryStory>? getCachedLibraryStories(String libraryId) {
    return _libStories[libraryId];
  }

  Library? getLibraryById(String libraryId) {
    try {
      return _libraries.firstWhere((lib) => lib.id == libraryId);
    } catch (e) {
      return null;
    }
  }

  Future<void> refreshLibraryStories(String libraryId) async {
    await getLibraryStories(libraryId, forceRefresh: true);
  }

  Future<void> deleteLibrary(String libraryId) async {
    await _api.removeLibrary(libraryId);

    _libraries.removeWhere((lib) => lib.id == libraryId);
    _libStories.remove(libraryId);
    _libStoriesTimestamp.remove(libraryId);

    notifyListeners();
  }
}
