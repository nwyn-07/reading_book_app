import 'package:flutter/material.dart';
import 'package:reading_book_app/core/models/Library.dart';
import 'package:reading_book_app/core/models/LibraryStory.dart';
import 'package:reading_book_app/core/services/api/CoreService.dart';

class LibraryStore extends ChangeNotifier {
  final _api = CoreServices.instance;

  List<Library> _libraries = [];
  final Set<String> _favoriteStoryIds = {};

  final Map<String, List<LibraryStory>> _libStories = {};

  final Map<String, DateTime> _libStoriesTimestamp = {};

  String? _favoriteLibraryId;
  bool _loading = false;
  String? _error;

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
    debugPrint('[LibraryStore] fetchLibraries → START');
    _loading = true;
    notifyListeners();

    try {
      _libraries = await _api.library();
      debugPrint('[LibraryStore] Loaded libraries: ${_libraries.length}');

      // Load stories cho từng library
      for (final lib in _libraries) {
        debugPrint('[LibraryStore] Fetch stories for lib=${lib.id}');
        final stories = await _api.libraryStories(lib.id);
        debugPrint('[LibraryStore] lib=${lib.id} stories=${stories.length}');

        _libStories[lib.id] = stories;
        _libStoriesTimestamp[lib.id] = DateTime.now();
      }

      // ================= FAVORITE =================
      Library? favorite;

      try {
        favorite = _libraries.firstWhere((e) => e.name == 'Yêu thích');
        debugPrint('[LibraryStore] Favorite library FOUND');
      } catch (_) {
        debugPrint('[LibraryStore] Favorite library NOT FOUND → creating');
        await _api.addLibrary('Yêu thích');

        _libraries = await _api.library();
        favorite = _libraries.firstWhere((e) => e.name == 'Yêu thích');
      }

      _favoriteLibraryId = favorite.id;
      debugPrint('[LibraryStore] Favorite library id=$_favoriteLibraryId');

      await fetchFavoriteStories();

      _error = null;
    } catch (e, stack) {
      _error = e.toString();
      debugPrint('[LibraryStore][ERROR] fetchLibraries FAILED: $e');
      debugPrintStack(stackTrace: stack);
    } finally {
      _loading = false;
      notifyListeners();
      debugPrint('[LibraryStore] fetchLibraries → END');
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

    _libStories.remove(libraryId);
    _libStoriesTimestamp.remove(libraryId);

    if (libraryId == _favoriteLibraryId) {
      _favoriteStoryIds.add(storyId);
    }

    notifyListeners();
  }

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
    final prevStories = _libStories[libraryId];
    final prevFavoriteIds = Set<String>.from(_favoriteStoryIds);

    try {
      await _api.removeStoryFromLibrary(libraryId: libraryId, storyId: storyId);

      _libStories.remove(libraryId);
      _libStoriesTimestamp.remove(libraryId);

      if (libraryId == _favoriteLibraryId) {
        _favoriteStoryIds.remove(storyId);
      }

      notifyListeners();
    } catch (e, stack) {
      debugPrint(
        '[LibraryStore][ERROR] removeStoryFromLibrary FAILED\n'
        'libraryId=$libraryId\n'
        'storyId=$storyId\n'
        'error=$e',
      );
      debugPrintStack(stackTrace: stack);

      if (prevStories != null) {
        _libStories[libraryId] = prevStories;
      }
      _favoriteStoryIds
        ..clear()
        ..addAll(prevFavoriteIds);

      notifyListeners();
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
