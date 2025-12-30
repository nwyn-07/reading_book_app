import 'dart:async';
import 'package:flutter/material.dart';
import 'package:reading_book_app/core/services/api/CoreService.dart';

class ReadingStore extends ChangeNotifier {
  final CoreServices _core = CoreServices.instance;

  String? _chapterId;
  int _progress = 0;
  int _totalSeconds = 0;

  bool _isReading = false;
  bool _isLoading = false;

  Timer? _timer;

  // ================= GETTERS =================
  String? get chapterId => _chapterId;
  int get progress => _progress;
  int get totalSeconds => _totalSeconds;
  bool get isReading => _isReading;
  bool get isLoading => _isLoading;

  // ================= ACTIONS =================

  /// 🚀 Bắt đầu đọc
  Future<void> startReading(String chapterId) async {
    if (_isReading && _chapterId == chapterId) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _core.startReading(chapterId);

      _chapterId = chapterId;
      _progress = 0;
      _totalSeconds = 0;
      _isReading = true;

      _startTimer();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🔄 Update progress (scroll / page)
  Future<void> updateReading(int progress) async {
    if (!_isReading || _chapterId == null) return;

    _progress = progress;
    notifyListeners();

    await _core.updateReading(_chapterId!, progress);
  }

  /// ⏱ Tick mỗi giây để tính thời gian đọc
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _totalSeconds++;
    });
  }

  /// ⏸ Pause (app background)
  Future<void> pause() async {
    if (!_isReading || _chapterId == null) return;

    _timer?.cancel();

    await _core.updateHistory(
      chapterId: _chapterId!,
      lastPosition: _progress,
      totalTimeSeconds: _totalSeconds,
    );
  }

  /// ✅ Kết thúc đọc
  Future<void> finishReading() async {
    if (!_isReading || _chapterId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _timer?.cancel();

      await _core.finishReading(_chapterId!);

      // lưu history lần cuối
      await _core.updateHistory(
        chapterId: _chapterId!,
        lastPosition: _progress,
        totalTimeSeconds: _totalSeconds,
      );
    } finally {
      _reset();
      notifyListeners();
    }
  }

  // ================= HELPERS =================

  void _reset() {
    _chapterId = null;
    _progress = 0;
    _totalSeconds = 0;
    _isReading = false;
    _isLoading = false;
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
