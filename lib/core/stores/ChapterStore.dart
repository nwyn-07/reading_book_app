import 'package:flutter/material.dart';
import 'package:reading_book_app/core/models/Chapter.dart';
import 'package:reading_book_app/core/services/api/CoreService.dart';

class ChapterStore extends ChangeNotifier {
  final CoreServices _api = CoreServices.instance;

  List<Chapter> _chapters = [];
  Chapter? _currentChapter;

  bool _loading = false;
  String? _error;

  List<Chapter> get chapters => _chapters;
  Chapter? get currentChapter => _currentChapter;

  bool get isLoading => _loading;
  String? get error => _error;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  Future<void> fetchChapters(String storyId) async {
    _setLoading(true);

    try {
      final List res = await _api.storyChapters(storyId);

      _chapters = res
          .map((e) => Chapter.fromJson(e as Map<String, dynamic>))
          .toList();

      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchChapterDetail(String chapterId) async {
    _setLoading(true);

    try {
      final Map<String, dynamic> res = await _api.chapterDetail(chapterId);

      _currentChapter = Chapter.fromJson(res);
      _error = null;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void setCurrentChapter(Chapter chapter) {
    _currentChapter = chapter;
    notifyListeners();
  }

  void clear() {
    _chapters = [];
    _currentChapter = null;
    _error = null;
    notifyListeners();
  }
}
