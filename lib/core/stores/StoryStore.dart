import 'package:flutter/material.dart';
import 'package:reading_book_app/core/services/api/CoreService.dart';
import 'package:reading_book_app/core/models/Book.dart';

class StoryStore extends ChangeNotifier {
  final CoreServices _api = CoreServices.instance;

  List<Book> _stories = [];
  Book? _currentStory;

  bool _loading = false;
  bool _initialized = false;
  String? _error;

  int _page = 1;
  final int _size = 10;
  bool _hasMore = true;

  List<Book> get stories => _stories;
  Book? get currentStory => _currentStory;

  bool get isLoading => _loading;
  bool get isInitialized => _initialized;
  String? get error => _error;
  bool get hasMore => _hasMore;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  Future<void> fetchStories({bool refresh = false}) async {
    if (_loading) return;

    if (refresh) {
      _page = 1;
      _hasMore = true;
      _stories.clear();
    }

    if (!_hasMore) return;

    _setLoading(true);

    try {
      final List<dynamic> res = await _api.stories(page: _page, size: _size);

      final List<Book> books = res
          .map<Book>((e) => Book.fromJson(e as Map<String, dynamic>))
          .toList();

      if (books.isEmpty) {
        _hasMore = false;
      } else {
        _stories.addAll(books);
        _page++;
      }

      _initialized = true;
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchStoryDetail(String storyId) async {
    _setLoading(true);

    try {
      final Map<String, dynamic> res = await _api.storyDetail(storyId);

      _currentStory = Book.fromJson(res);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchStories(String keyword) async {
    _setLoading(true);

    try {
      final List<dynamic> res = await _api.searchStory(keyword);

      _stories = res
          .map<Book>((e) => Book.fromJson(e as Map<String, dynamic>))
          .toList();

      _hasMore = false;
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void clear() {
    _stories.clear();
    _currentStory = null;
    _page = 1;
    _hasMore = true;
    _error = null;
    notifyListeners();
  }
}
