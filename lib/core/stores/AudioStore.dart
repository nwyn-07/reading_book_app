import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:reading_book_app/core/models/Book.dart';
import 'package:reading_book_app/core/models/Chapter.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class AudioStore extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final Dio _dio = Dio();
  Map<DateTime, double> _listenedHours = {};
  DateTime? _currentDay;
  Duration _lastPosition = Duration.zero;

  Book? currentStory;
  Chapter? currentChapter;

  List<Chapter> _chapters = [];
  int _currentIndex = -1;

  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  bool isMiniVisible = false;

  bool isDownloading = false;
  double downloadProgress = 0.0;
  final Set<String> _downloadedChapters = {};

  bool get isPlaying => _player.playing;
  AudioPlayer get player => _player;

  bool _initialized = false;

  AudioStore() {
    _init();
  }

  void _init() {
    if (_initialized) return;
    _initialized = true;

    _player.positionStream.listen((p) {
      position = p;
      notifyListeners();
    });

    _player.durationStream.listen((d) {
      if (d != null) {
        duration = d;
        notifyListeners();
      }
    });

    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        playNext();
      }
    });
    initTracking();
  }

  void setChapters(List<Chapter> chapters) {
    _chapters = chapters;
  }

  Future<void> playChapter({
    required Book story,
    required Chapter chapter,
  }) async {
    currentStory = story;
    currentChapter = chapter;
    isMiniVisible = true;

    _currentIndex = _chapters.indexWhere((c) => c.id == chapter.id);

    final file = await _getLocalFile(chapter.id);

    notifyListeners();

    try {
      await _player.stop();

      if (await file.exists()) {
        _downloadedChapters.add(chapter.id);
        await _player.setFilePath(file.path);
      } else {
        await _player.setUrl(chapter.audioUrl);
      }

      await _player.play();
    } catch (e) {
      debugPrint('AudioStore play error: $e');
    }
  }

  Future<void> playNext() async {
    if (_currentIndex < 0 || _currentIndex >= _chapters.length - 1) return;

    final nextChapter = _chapters[_currentIndex + 1];
    await playChapter(story: currentStory!, chapter: nextChapter);
  }

  Future<void> playPrevious() async {
    if (_currentIndex <= 0) return;

    final prevChapter = _chapters[_currentIndex - 1];
    await playChapter(story: currentStory!, chapter: prevChapter);
  }

  bool get hasNext => _currentIndex < _chapters.length - 1;
  bool get hasPrevious => _currentIndex > 0;

  Future<void> downloadChapter(Chapter chapter) async {
    final file = await _getLocalFile(chapter.id);

    if (await file.exists()) {
      _downloadedChapters.add(chapter.id);
      notifyListeners();
      return;
    }

    isDownloading = true;
    downloadProgress = 0;
    notifyListeners();

    try {
      await _dio.download(
        chapter.audioUrl,
        file.path,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            downloadProgress = received / total;
            notifyListeners();
          }
        },
      );

      _downloadedChapters.add(chapter.id);
    } catch (e) {
      debugPrint('Download error: $e');
    } finally {
      isDownloading = false;
      notifyListeners();
    }
  }

  Future<void> removeDownloadedChapter(Chapter chapter) async {
    final file = await _getLocalFile(chapter.id);
    if (await file.exists()) {
      await file.delete();
      _downloadedChapters.remove(chapter.id);
      notifyListeners();
    }
  }

  bool isDownloaded(String chapterId) {
    return _downloadedChapters.contains(chapterId);
  }

  Future<bool> checkDownloaded(String chapterId) async {
    final file = await _getLocalFile(chapterId);
    return file.exists();
  }

  void pause() {
    _player.pause();
    notifyListeners();
  }

  void resume() {
    _player.play();
    notifyListeners();
  }

  Future<void> seek(Duration d) async {
    await _player.seek(d);
    position = d;
    notifyListeners();
  }

  void stop() {
    _player.stop();
    position = Duration.zero;
    duration = Duration.zero;
    notifyListeners();
  }

  Future<File> _getLocalFile(String chapterId) async {
    final dir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${dir.path}/audio');

    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return File('${audioDir.path}/$chapterId.mp3');
  }

  void initTracking() {
    _player.positionStream.listen((p) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (_currentDay == null || _currentDay != today) {
        _currentDay = today;
        _lastPosition = p;
        _listenedHours.putIfAbsent(today, () => 0.0);
      } else {
        final diff = (p - _lastPosition).inMinutes / 60.0;
        if (diff > 0) {
          _listenedHours[today] = (_listenedHours[today] ?? 0.0) + diff;
          _lastPosition = p;
          notifyListeners();
        }
      }
    });
  }

  List<double> getWeeklyHours() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Thứ 2

    return List.generate(7, (i) {
      final day = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day + i,
      );
      return _listenedHours[day] ?? 0.0;
    });
  }

  /// Fake dữ liệu tuần này cho test chart
  void fakeWeeklyData() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Thứ 2

    for (int i = 0; i < 7; i++) {
      final day = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day + i,
      );
      // Tạo số giờ nghe giả, ví dụ 0.5 -> 2.0 giờ mỗi ngày
      _listenedHours[day] = 2 + i * 0.2;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
