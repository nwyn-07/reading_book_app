import 'dart:async';
import 'package:flutter/material.dart';
import 'package:reading_book_app/core/services/api/CoreService.dart';

class ReadingStore extends ChangeNotifier {
  final CoreServices _core = CoreServices.instance;

  String? _chapterId;
  String? _storyId;

  int _progress = 0;
  int _totalSeconds = 0;

  bool _isReading = false;
  bool _isLoading = false;

  Timer? _timer; // đếm thời gian đọc
  Timer? _updateTimer; // debounce updateReading

  // ================= GETTERS =================
  String? get chapterId => _chapterId;
  String? get storyId => _storyId;
  int get progress => _progress;
  int get totalSeconds => _totalSeconds;
  bool get isReading => _isReading;
  bool get isLoading => _isLoading;

  Future<void> startReading({
    required String chapterId,
    required String storyId,
  }) async {
    if (_isReading && _chapterId == chapterId) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _core.startReading(chapterId);

      _chapterId = chapterId;
      _storyId = storyId;
      _progress = 0;
      _totalSeconds = 0;
      _isReading = true;

      _startTimer();
      _startUpdateTimer();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateProgress(int progress) {
    if (!_isReading || _chapterId == null) return;

    _progress = progress;
    notifyListeners();
  }

  Future<void> resumeReading({
    required String chapterId,
    required String storyId,
    required int progress,
    required int totalSeconds,
  }) async {
    if (_isReading && _chapterId == chapterId) return;

    _chapterId = chapterId;
    _storyId = storyId;
    _progress = progress;
    _totalSeconds = totalSeconds;
    _isReading = true;

    _startTimer();
    _startUpdateTimer();
    notifyListeners();
  }

  Future<void> pause() async {
    if (!_isReading || _chapterId == null) return;

    _isReading = false;
    _timer?.cancel();
    _updateTimer?.cancel();

    await _core.updateReading(
      chapterId: _chapterId!,
      lastPosition: _progress,
      totalTimeSeconds: _totalSeconds,
    );

    await _core.updateHistory(
      chapterId: _chapterId!,
      lastPosition: _progress,
      totalTimeSeconds: _totalSeconds,
    );

    notifyListeners();
  }

  Future<void> finishReading() async {
    if (_chapterId == null || _storyId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _timer?.cancel();
      _updateTimer?.cancel();

      await _core.finishReading(
        storyId: _storyId!,
        durationSeconds: _totalSeconds,
      );

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

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isReading) {
        _totalSeconds++;
      }
    });
  }

  void _startUpdateTimer() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_isReading && _chapterId != null) {
        _core.updateReading(
          chapterId: _chapterId!,
          lastPosition: _progress,
          totalTimeSeconds: _totalSeconds,
        );
      }
    });
  }

  void _reset() {
    _chapterId = null;
    _storyId = null;
    _progress = 0;
    _totalSeconds = 0;
    _isReading = false;
    _isLoading = false;
    _timer?.cancel();
    _updateTimer?.cancel();
    _timer = null;
    _updateTimer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _updateTimer?.cancel();
    super.dispose();
  }
}
