import 'dart:async';
import 'package:flutter/material.dart';
import 'package:reading_book_app/core/services/api/CoreService.dart';
import '../models/ReadingHistory.dart';

class HistoryStore extends ChangeNotifier {
  final CoreServices _api = CoreServices.instance;

  final Map<String, ReadingHistory> _cache = {};
  Timer? _debounceTimer;

  Map<String, ReadingHistory> get cache => _cache;

  Future<void> loadHistory() async {
    try {
      final res = await _api.history();

      final List<ReadingHistory> list = [];

      for (final item in res) {
        try {
          list.add(ReadingHistory.fromJson(item));
        } catch (e) {
          debugPrint('Error parsing history item $item: $e');
        }
      }

      list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      _cache.clear();
      for (final h in list) {
        _cache[h.chapterId] = h;
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void updateHistoryDebounced({
    required String chapterId,
    required int lastPosition,
    required int totalTimeSeconds,
  }) {
    _debounceTimer = Timer(
      const Duration(seconds: 10),
      () => _sendHistory(
        chapterId: chapterId,
        lastPosition: lastPosition,
        totalTimeSeconds: totalTimeSeconds,
      ),
    );
  }

  Future<void> forceUpdate({
    required String chapterId,
    required int lastPosition,
    required int totalTimeSeconds,
  }) async {
    await _sendHistory(
      chapterId: chapterId,
      lastPosition: lastPosition,
      totalTimeSeconds: totalTimeSeconds,
    );
  }

  Future<void> _sendHistory({
    required String chapterId,
    required int lastPosition,
    required int totalTimeSeconds,
  }) async {
    try {
      await _api.updateHistory(
        chapterId: chapterId,
        lastPosition: lastPosition,
        totalTimeSeconds: totalTimeSeconds,
      );

      _cache[chapterId] = ReadingHistory(
        chapterId: chapterId,
        lastPosition: lastPosition,
        totalTimeSeconds: totalTimeSeconds,
        updatedAt: DateTime.now(),
      );

      notifyListeners();
    } catch (e) {}
  }

  int? getResumePosition(String chapterId) {
    final position = _cache[chapterId]?.lastPosition;
    return position;
  }

  void clear() {
    _cache.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
