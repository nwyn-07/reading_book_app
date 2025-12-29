import 'package:flutter/material.dart';
import 'package:reading_book_app/core/services/download/DownloadService.dart';
import 'package:reading_book_app/core/models/Chapter.dart';

class DownloadStore extends ChangeNotifier {
  final DownloadService _service = DownloadService();

  final Map<String, double> _progress = {};
  final Map<String, String> _localPaths = {};
  final Map<String, Chapter> _chapterInfo = {};

  Map<String, String> get localPaths => _localPaths;
  List<String> get downloadedIds => _localPaths.keys.toList();

  double progressOf(String chapterId) => _progress[chapterId] ?? 0;
  bool isDownloaded(String chapterId) => _localPaths.containsKey(chapterId);
  String? localPathOf(String chapterId) => _localPaths[chapterId];

  void addChapterInfo(Chapter chapter) {
    _chapterInfo[chapter.id] = chapter;
  }

  Chapter? getChapterInfo(String chapterId) => _chapterInfo[chapterId];

  Future<void> downloadChapter({
    required String chapterId,
    required String audioUrl,
  }) async {
    _progress[chapterId] = 0;
    notifyListeners();

    final file = await _service.downloadAudio(
      url: audioUrl,
      fileName: '$chapterId.mp3',
      onProgress: (p) {
        _progress[chapterId] = p;
        notifyListeners();
      },
    );

    _localPaths[chapterId] = file.path;
    _progress.remove(chapterId);
    notifyListeners();
  }
}
