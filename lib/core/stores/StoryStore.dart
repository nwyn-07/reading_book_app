import 'package:flutter/material.dart';
import 'package:reading_book_app/core/services/api/CoreService.dart';
import 'package:reading_book_app/core/models/Book.dart';

class StoryStore extends ChangeNotifier {
  final CoreServices _api = CoreServices.instance;

  final List<Book> _allStories = [];

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
      _allStories.clear();
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
        _allStories.addAll(books);
        _stories = List.from(_allStories);
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

  void searchStories(String keyword) {
    final query = keyword.trim().toLowerCase();

    if (query.isEmpty) {
      _stories = List.from(_allStories);
      _hasMore = true;
      notifyListeners();
      return;
    }

    _stories = _allStories.where((book) {
      return book.title.toLowerCase().contains(query) ||
          (book.author.toLowerCase().contains(query));
    }).toList();

    _hasMore = false;
    notifyListeners();
  }

  Future<void> resetAndFetch() async {
    _allStories.clear();
    _stories.clear();
    _page = 1;
    _hasMore = true;
    _initialized = false;
    notifyListeners();
    await fetchStories(refresh: true);
  }

  Future<Book?> fetchStoryDetail(String storyId) async {
    _setLoading(true);

    try {
      final Map<String, dynamic> res = await _api.storyDetail(storyId);
      final book = Book.fromJson(res);

      _currentStory = book;
      _setError(null);
      return book;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  void clear() {
    _allStories.clear();
    _stories.clear();
    _currentStory = null;
    _page = 1;
    _hasMore = true;
    _error = null;
    _initialized = false;
    notifyListeners();
  }
}
