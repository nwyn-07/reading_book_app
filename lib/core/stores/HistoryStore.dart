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
    print('=== HISTORY STORE: loadHistory() called ===');
    try {
      print('Calling API: _api.history()');
      final res = await _api.history();

      print('API response type: ${res.runtimeType}');
      print('API response length: ${res.length}');
      if (res.isNotEmpty) {
        print('First item in response: ${res.first}');
      }

      _cache.clear();
      for (final item in res) {
        try {
          final h = ReadingHistory.fromJson(item);
          print(
            'Parsed history item: chapterId=${h.chapterId}, lastPosition=${h.lastPosition}, updatedAt=${h.updatedAt}',
          );
          _cache[h.chapterId] = h;
        } catch (e) {
          print('Error parsing history item $item: $e');
        }
      }

      print('Total items in cache after load: ${_cache.length}');
      print('Cache content:');
      _cache.forEach((key, value) {
        print(
          '  $key: ${value.lastPosition}s/${value.totalTimeSeconds}s (${value.updatedAt})',
        );
      });

      notifyListeners();
      print('Notified listeners about history update');
    } catch (e) {
      print('Error in loadHistory: $e');
      print('Stack trace: ${e.toString()}');
      rethrow; // Để debug thấy lỗi
    }
  }

  void updateHistoryDebounced({
    required String chapterId,
    required int lastPosition,
    required int totalTimeSeconds,
  }) {
    print('HistoryStore: updateHistoryDebounced called for $chapterId');
    _debounceTimer?.cancel();
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
    print('HistoryStore: forceUpdate called for $chapterId');
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
    print('HistoryStore: _sendHistory for $chapterId');
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
      print('History updated for $chapterId');
    } catch (e) {
      print('Error sending history: $e');
    }
  }

  int? getResumePosition(String chapterId) {
    final position = _cache[chapterId]?.lastPosition;
    print('getResumePosition for $chapterId: $position');
    return position;
  }

  void clear() {
    print('HistoryStore: clear() called');
    _cache.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    print('HistoryStore: dispose() called');
    _debounceTimer?.cancel();
    super.dispose();
  }
}
