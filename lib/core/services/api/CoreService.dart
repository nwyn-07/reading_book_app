import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:reading_book_app/core/models/Library.dart';
import 'package:reading_book_app/core/models/LibraryStory.dart';
import 'package:reading_book_app/core/models/ReadingStatsItem.dart';
import 'package:reading_book_app/core/services/api/Endpoint.dart';
import 'package:reading_book_app/core/services/api/FetchApi.dart';

class CoreServices {
  CoreServices._();
  static final CoreServices instance = CoreServices._();
  final FetchApi _api = FetchApi();

  /* =========================
   * AUTH
   * ========================= */
  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _api.post(
      Endpoint.login,
      body: {"email": email, "password": password},
    );

    return res as Map<String, dynamic>;
  }

  /* =========================
 * AUTH
 * ========================= */
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String fullName,
  ) async {
    final res = await _api.post(
      Endpoint.register,
      body: {"email": email, "password": password, "fullName": fullName},
    );
    return res as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> me() async {
    final res = await _api.get(Endpoint.me);
    return res as Map<String, dynamic>;
  }

  /* =========================
 * USER
 * ========================= */

  Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    File? avatarFile,
  }) async {
    final uri = Uri.parse(Endpoint.updateProfile);

    final request = http.MultipartRequest('PUT', uri);

    if (fullName != null && fullName.isNotEmpty) {
      request.fields['fullName'] = fullName;
    }

    if (avatarFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('avatar', avatarFile.path),
      );
    }

    final res = await _api.put(Endpoint.updateProfile, body: request);

    return res as Map<String, dynamic>;
  }

  /* =========================
 * ADMIN
 * ========================= */
  Future<List> adminUsers() async {
    final res = await _api.get(Endpoint.adminUsers);
    return res as List;
  }

  Future<List> adminStories() async {
    final res = await _api.get(Endpoint.adminStories);
    return res as List;
  }

  Future<List> adminChapters() async {
    final res = await _api.get(Endpoint.adminChapters);
    return res as List;
  }

  Future<Map<String, dynamic>> adminDashboard() async {
    final res = await _api.get(Endpoint.adminDashboard);
    return res as Map<String, dynamic>;
  }

  /* =========================
 * STORY
 * ========================= */
  Future<List> stories({int page = 1, int size = 10}) async {
    final res = await _api.get(
      Endpoint.stories,
      query: {"page": page.toString(), "size": size.toString()},
    );
    return res as List;
  }

  Future<Map<String, dynamic>> storyDetail(String id) async {
    final res = await _api.get(Endpoint.storyDetail(id));
    return res as Map<String, dynamic>;
  }

  Future<List> searchStory(String keyword) async {
    final res = await _api.get(Endpoint.storySearch(keyword));
    return res as List;
  }

  Future<Map<String, dynamic>> createStory(Map<String, dynamic> body) async {
    final res = await _api.post(Endpoint.storyCreate, body: body);
    return res as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateStory(
    String id,
    Map<String, dynamic> body,
  ) async {
    final res = await _api.put(Endpoint.storyUpdate(id), body: body);
    return res as Map<String, dynamic>;
  }

  Future<void> deleteStory(String id) async {
    await _api.delete(Endpoint.storyDelete(id));
  }

  Future<List> storyChapters(String storyId) async {
    final res = await _api.get(Endpoint.storyChapters(storyId));
    return res as List;
  }

  /* =========================
 * CHAPTER
 * ========================= */
  Future<Map<String, dynamic>> chapterDetail(String chapterId) async {
    final res = await _api.get(Endpoint.chapterDetail(chapterId));
    return res as Map<String, dynamic>;
  }

  /* =========================
 * LIBRARY
 * ========================= */
  Future<List<Library>> library() async {
    final res = await _api.get(Endpoint.library);

    return (res as List).map((e) => Library.fromJson(e)).toList();
  }

  Future<void> addLibrary(String name) async {
    await _api.post(Endpoint.libraryAdd, body: {"name": name});
  }

  Future<void> removeLibrary(String libraryId) async {
    await _api.delete(Endpoint.libraryRemove(libraryId));
  }

  Future<List<LibraryStory>> libraryStories(String libraryId) async {
    final res = await _api.post(
      Endpoint.libraryStories,
      body: {"libraryId": libraryId},
    );

    return (res as List).map((e) => LibraryStory.fromJson(e)).toList();
  }

  Future<void> addStoryToLibrary({
    required String libraryId,
    required String storyId,
  }) async {
    await _api.post(
      Endpoint.libraryStoryAdd,
      body: {'libraryId': libraryId, 'storyId': storyId},
    );
  }

  Future<void> removeStoryFromLibrary({
    required String libraryId,
    required String storyId,
  }) async {
    await _api.delete(
      Endpoint.libraryStoryRemove,
      body: {'libraryId': libraryId, 'storyId': storyId},
    );
  }

  /* =========================
 * BOOKMARK
 * ========================= */
  Future<List> bookmarks() async {
    final res = await _api.get(Endpoint.bookmarks);
    return res as List;
  }

  Future<void> addBookmark(String chapterId) async {
    await _api.post(Endpoint.bookmarkAdd, body: {"chapterId": chapterId});
  }

  Future<void> removeBookmark(String chapterId) async {
    await _api.post(Endpoint.bookmarkRemove, body: {"chapterId": chapterId});
  }

  /* =========================
 * HISTORY
 * ========================= */

  Future<void> updateHistory({
    required String chapterId,
    required int lastPosition,
    required int totalTimeSeconds,
  }) async {
    await _api.post(
      Endpoint.updateHistory,
      body: {
        "chapterId": chapterId,
        "lastPosition": lastPosition,
        "totalTimeSeconds": totalTimeSeconds,
      },
    );
  }

  Future<List<Map<String, dynamic>>> history() async {
    final res = await _api.get(Endpoint.historyList);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> clearHistory() async {
    await _api.post(Endpoint.clearHistory);
  }

  /* =========================
 * READING
 * ========================= */
  Future<void> startReading(String chapterId) async {
    await _api.post(
      Endpoint.startReading,
      body: {"chapterId": chapterId, "startPosition": 0},
    );
  }

  Future<void> updateReading({
    required String chapterId,
    required int lastPosition,
    required int totalTimeSeconds,
  }) async {
    await _api.post(
      Endpoint.updateReading,
      body: {
        "chapterId": chapterId,
        "lastPosition": lastPosition,
        "totalTimeSeconds": totalTimeSeconds,
      },
    );
  }

  Future<void> finishReading({
    required String storyId,
    required int durationSeconds,
  }) async {
    await _api.post(
      Endpoint.finishReading,
      body: {"storyId": storyId, "durationSeconds": durationSeconds},
    );
  }

  /* =========================
 * STATS
 * ========================= */
  Future<List<ReadingStatsItem>> statsDay(int count) async {
    final res = await _api.get(
      Endpoint.readingStatsByDay,
      body: {"count": count},
    );

    return (res as List).map((e) => ReadingStatsItem.fromJson(e)).toList();
  }

  Future<List<ReadingStatsItem>> statsMonth(int count) async {
    final res = await _api.get(
      Endpoint.readingStatsByMonth,
      body: {"count": count},
    );

    return (res as List).map((e) => ReadingStatsItem.fromJson(e)).toList();
  }

  Future<List<ReadingStatsItem>> statsYear(int count) async {
    final res = await _api.get(
      Endpoint.readingStatsByYear,
      body: {"count": count},
    );

    return (res as List).map((e) => ReadingStatsItem.fromJson(e)).toList();
  }

  /* =========================
 * SLEEP TIMER
 * ========================= */
  Future<void> setSleepTimer(int minutes) async {
    await _api.post(Endpoint.sleepTimerSet, body: {"minutes": minutes});
  }

  Future<void> cancelSleepTimer() async {
    await _api.post(Endpoint.sleepTimerCancel);
  }

  Future<Map<String, dynamic>> sleepTimerStatus() async {
    final res = await _api.get(Endpoint.sleepTimerStatus);
    return res as Map<String, dynamic>;
  }

  /* =========================
 * OFFLINE
 * ========================= */
  Future<void> offlineDownload(String storyId) async {
    await _api.post(Endpoint.offlineDownload, body: {"storyId": storyId});
  }

  Future<List> offlineList() async {
    final res = await _api.get(Endpoint.offlineList);
    return res as List;
  }

  Future<void> offlineRemove(String storyId) async {
    await _api.post(Endpoint.offlineRemove, body: {"storyId": storyId});
  }

  /* =========================
 * FILE
 * ========================= */
  Future<Map<String, dynamic>> uploadFile(String base64) async {
    final res = await _api.post(Endpoint.uploadFile, body: {"file": base64});
    return res as Map<String, dynamic>;
  }
}
