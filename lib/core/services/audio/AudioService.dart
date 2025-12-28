import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:reading_book_app/core/models/Chapter.dart';

class AudioService extends ChangeNotifier {
  final AudioPlayer player = AudioPlayer();

  String? currentStory;
  Chapter? currentChapter;
  bool isMiniVisible = false;
  bool _isInitialized = false;

  AudioService() {
    _init();
  }

  Future<void> _init() async {
    if (!_isInitialized) {
      // Xử lý khi audio kết thúc
      player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          // Có thể tự động chuyển chapter tiếp theo ở đây
        }
      });
      _isInitialized = true;
    }
  }

  Future<void> playChapter({
    required String story,
    required Chapter chapter,
  }) async {
    try {
      if (currentChapter?.id == chapter.id && player.playing) {
        return;
      }

      currentStory = story;
      currentChapter = chapter;
      isMiniVisible = true;

      notifyListeners();

      await player.stop();
      await player.setUrl(chapter.audioUrl);
      await player.play();
    } catch (e) {
      debugPrint('Error playing audio: $e');
      rethrow;
    }
  }

  void pause() {
    player.pause();
    notifyListeners();
  }

  void resume() {
    player.play();
    notifyListeners();
  }

  void stop() {
    player.stop();
    isMiniVisible = false;
    currentStory = null;
    currentChapter = null;
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (player.playing) {
      pause();
    } else {
      if (player.playerState.processingState == ProcessingState.idle) {
        // Nếu player đang idle, cần load lại audio
        if (currentChapter != null) {
          await playChapter(story: currentStory!, chapter: currentChapter!);
        }
      } else {
        resume();
      }
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
