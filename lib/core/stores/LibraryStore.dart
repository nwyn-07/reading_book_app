import 'package:flutter/material.dart';
import 'package:reading_book_app/core/models/Library.dart';
import 'package:reading_book_app/core/models/LibraryStory.dart';
import 'package:reading_book_app/core/services/api/CoreService.dart';

class LibraryStore extends ChangeNotifier {
  final _api = CoreServices.instance;

  // ===== DATA =====
  List<Library> _libraries = [];
  final Set<String> _favoriteStoryIds = {};

  String? _favoriteLibraryId;
  bool _loading = false;
  String? _error;

  // ===== GETTERS =====
  bool get isLoading => _loading;
  String? get error => _error;

  List<Library> get libraries => _libraries;
  Set<String> get favoriteStoryIds => _favoriteStoryIds;
  // ===============================
  // INIT
  // ===============================
  Future<void> init() async {
    await fetchLibraries();
    await fetchFavoriteStories();
  }

  // ===============================
  // LIBRARIES
  // ===============================
  Future<void> fetchLibraries() async {
    _loading = true;
    notifyListeners();

    try {
      _libraries = await _api.library();

      final fav = _libraries.firstWhere(
        (e) => e.name == 'Yêu thích',
        orElse: () => throw 'Chưa có thư viện Yêu thích',
      );

      _favoriteLibraryId = fav.id;
      _error = null;
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
    } catch (e) {
      debugPrint('Fetch favorite error: $e');
    }

    notifyListeners();
  }

  bool isFavorite(String storyId) {
    return _favoriteStoryIds.contains(storyId);
  }

  // ===============================
  // ADD / REMOVE FAVORITE
  // ===============================
  Future<void> addToFavorite(String storyId) async {
    if (_favoriteLibraryId == null) {
      await fetchLibraries();
    }

    // ✅ UPDATE LOCAL NGAY
    _favoriteStoryIds.add(storyId);
    notifyListeners();

    try {
      await _api.addStoryToLibrary(
        libraryId: _favoriteLibraryId!,
        storyId: storyId,
      );
    } catch (e) {
      // rollback nếu lỗi
      _favoriteStoryIds.remove(storyId);
      notifyListeners();
    }
  }

  Future<void> removeFromFavorite(String storyId) async {
    if (_favoriteLibraryId == null) return;

    // ✅ UPDATE LOCAL NGAY
    _favoriteStoryIds.remove(storyId);
    notifyListeners();

    try {
      await _api.removeStoryFromLibrary(
        libraryId: _favoriteLibraryId!,
        storyId: storyId,
      );
    } catch (e) {
      // rollback
      _favoriteStoryIds.add(storyId);
      notifyListeners();
    }
  }

  // ===============================
  // GET LIBRARY STORIES
  // ===============================
  Future<List<LibraryStory>> getLibraryStories(String libraryId) async {
    try {
      final res = await _api.libraryStories(libraryId);
      return res;
    } catch (e) {
      debugPrint('Get library stories error: $e');
      return [];
    }
  }
}
