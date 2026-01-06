import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import 'package:reading_book_app/core/models/Book.dart';
import 'package:reading_book_app/core/models/Chapter.dart';
import 'package:reading_book_app/core/stores/HistoryStore.dart';
import 'package:reading_book_app/core/stores/ReadingStore.dart';

class AudioStore extends ChangeNotifier with WidgetsBindingObserver {
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

  bool _isLooping = false;
  bool get isLooping => _isLooping;

  final Set<String> _downloadedChapters = {};
  final Set<String> _downloadedStories = {};

  Set<String> get downloadedStories => _downloadedStories;
  Set<String> get downloadedChapters => _downloadedChapters;

  bool get isPlaying => _player.playing;
  AudioPlayer get player => _player;

  HistoryStore? _historyStore;
  Timer? _historyTimer;
  Duration _lastSavedPosition = Duration.zero;

  ReadingStore? _readingStore;

  bool _initialized = false;

  AudioStore() {
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  void _init() {
    if (_initialized) return;
    _initialized = true;

    _player.positionStream.listen((p) {
      position = p;

      _historyTimer ??= Timer.periodic(
        const Duration(seconds: 10),
        (_) => _saveHistory(),
      );
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
        _saveHistory(force: true);
        _readingStore?.finishReading();
        playNext();
      }
    });

    initTracking();
  }

  void attachReadingStore(ReadingStore readingStore) {
    _readingStore = readingStore;
  }

  void attachHistoryStore(HistoryStore historyStore) {
    _historyStore = historyStore;
  }

  Future<void> _saveHistory({bool force = false}) async {
    if (_historyStore == null) return;
    if (currentChapter == null) return;
    if (duration.inSeconds == 0) return;

    if (!force && (position - _lastSavedPosition).inSeconds < 5) {
      return;
    }

    _lastSavedPosition = position;

    try {
      _historyStore!.updateHistoryDebounced(
        chapterId: currentChapter!.id,
        lastPosition: position.inSeconds,
        totalTimeSeconds: duration.inSeconds,
      );
    } catch (_) {
      // silent
    }
  }

  Future<void> toggleLoop() async {
    _isLooping = !_isLooping;
    await player.setLoopMode(_isLooping ? LoopMode.one : LoopMode.off);
    notifyListeners();
  }

  Future<void> setLoop(bool value) async {
    _isLooping = value;
    await player.setLoopMode(value ? LoopMode.one : LoopMode.off);
    notifyListeners();
  }

  void setChapters(List<Chapter> chapters) {
    _chapters = chapters;
  }

  bool get hasNext => _currentIndex < _chapters.length - 1;
  bool get hasPrevious => _currentIndex > 0;

  Future<void> playChapter({
    required Book story,
    required Chapter chapter,
    int? resumePositionSeconds,
    int? resumeTotalSeconds,
  }) async {
    // 1️⃣ Lưu & đóng session cũ
    await _saveHistory(force: true);
    await _readingStore?.finishReading();

    currentStory = story;
    currentChapter = chapter;
    isMiniVisible = true;

    _currentIndex = _chapters.indexWhere((c) => c.id == chapter.id);

    final file = await _getLocalFile(chapter.id);

    notifyListeners();

    try {
      await _player.stop();

      // 2️⃣ START hoặc RESUME reading (🔥 BẮT BUỘC)
      if (resumePositionSeconds != null && resumePositionSeconds > 0) {
        await _readingStore?.resumeReading(
          chapterId: chapter.id,
          storyId: story.id,
          progress: resumePositionSeconds,
          totalSeconds: resumeTotalSeconds ?? 0,
        );
      } else {
        await _readingStore?.startReading(
          chapterId: chapter.id,
          storyId: story.id,
        );
      }

      // 3️⃣ Load audio
      if (await file.exists()) {
        _downloadedChapters.add(chapter.id);
        _downloadedStories.add(story.id);
        await _player.setFilePath(file.path);
      } else {
        await _player.setUrl(chapter.audioUrl);
      }

      // 4️⃣ Seek nếu resume
      if (resumePositionSeconds != null && resumePositionSeconds > 5) {
        await _player.seek(Duration(seconds: resumePositionSeconds));
      }

      await _player.play();
    } catch (e) {
      debugPrint('AudioStore play error: $e');
    }
  }

  Future<void> playNext() async {
    if (!hasNext || currentStory == null) return;
    final nextChapter = _chapters[_currentIndex + 1];
    await playChapter(story: currentStory!, chapter: nextChapter);
  }

  Future<void> playPrevious() async {
    if (!hasPrevious || currentStory == null) return;
    final prevChapter = _chapters[_currentIndex - 1];
    await playChapter(story: currentStory!, chapter: prevChapter);
  }

  Future<void> downloadChapter(Chapter chapter) async {
    final file = await _getLocalFile(chapter.id, storyId: chapter.story.id);

    if (await file.exists()) {
      _downloadedChapters.add(chapter.id);
      _downloadedStories.add(chapter.story.id);
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
      _downloadedStories.add(chapter.story.id);
    } catch (e) {
      debugPrint('Download error: $e');
      if (await file.exists()) {
        await file.delete();
      }
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

  bool isStoryDownloaded(String storyId) {
    return _downloadedStories.contains(storyId);
  }

  Future<bool> checkDownloaded(String chapterId) async {
    final file = await _getLocalFile(chapterId);
    return file.exists();
  }

  void pause() {
    _player.pause();
    _saveHistory(force: true);
    _readingStore?.pause();
    notifyListeners();
  }

  void resume() {
    _player.play();

    if (currentChapter != null && currentStory != null) {
      _readingStore?.resumeReading(
        chapterId: currentChapter!.id,
        storyId: currentStory!.id,
        progress: position.inSeconds,
        totalSeconds: position.inSeconds, // hoặc lấy từ history
      );
    }

    notifyListeners();
  }

  Future<void> seek(Duration d) async {
    await _player.seek(d);
    position = d;
    await _saveHistory(force: true);
    notifyListeners();
  }

  void stop() {
    _saveHistory(force: true);
    _player.stop();
    _readingStore?.finishReading();
    position = Duration.zero;
    duration = Duration.zero;
    notifyListeners();
  }

  Future<File> _getLocalFile(String chapterId, {String? storyId}) async {
    final dir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${dir.path}/audio');

    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }

    final storyIdToUse = storyId ?? currentStory?.id ?? 'unknown';
    return File('${audioDir.path}/${storyIdToUse}_$chapterId.mp3');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _saveHistory(force: true);
      _readingStore?.pause();
    }
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
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(7, (i) {
      final day = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day + i,
      );
      return _listenedHours[day] ?? 0.0;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _historyTimer?.cancel();
    _saveHistory(force: true);
    _player.dispose();
    super.dispose();
  }

  void reset() {
    player.stop();
    currentChapter = null;
    currentStory = null;
    notifyListeners();
  }

  List<Chapter> getDownloadedChapters() {
    final downloaded = <Chapter>[];
    for (final chapterId in _downloadedChapters) {
      final chapter = _chapters.firstWhere((c) => c.id == chapterId);
      downloaded.add(chapter);
    }
    return downloaded;
  }

  Set<String> get downloadedChapterIds => _downloadedChapters;

  List<Chapter> get downloadedChapter {
    return _chapters
        .where((chapter) => _downloadedChapters.contains(chapter.id))
        .toList();
  }
}
