class Endpoint {
  Endpoint._();

  /// =========================
  /// Base
  /// =========================
  static const String baseUrl = "http://10.0.2.2:8080";
  static const String api = "$baseUrl/api";

  /// =========================
  /// AuthController
  /// /api/auth
  /// =========================
  static const String login = "$api/auth/login";
  static const String register = "$api/auth/register";
  static const String refreshToken = "$api/auth/refresh";
  static const String me = "$api/auth/me";
  static const String logout = "$api/auth/logout";

  /// =========================
  /// UserController
  /// /api/user
  /// =========================
  static const String updateProfile = "$api/users/update-profile";

  /// =========================
  /// AdminController
  /// /api/admin
  /// =========================
  static const String adminUsers = "$api/admin/users";
  static const String adminStories = "$api/admin/stories";
  static const String adminChapters = "$api/admin/chapters";
  static const String adminDashboard = "$api/admin/dashboard";

  /// =========================
  /// LibraryController
  /// /api/library
  /// =========================
  static const String library = "$api/library";
  static const String libraryAdd = "$api/library";
  static const String libraryRemove = "$api/library";

  /// =========================
  /// LibraryStoryController
  /// /api/library-story
  /// =========================
  static const String libraryStories = "$api/library/story/list";
  static const String libraryStoryAdd = "$api/library/story";
  static const String libraryStoryRemove = "$api/library/story";

  /// =========================
  /// BookmarkController
  /// /api/bookmark
  /// =========================
  static const String bookmarks = "$api/bookmark";
  static const String bookmarkAdd = "$api/bookmark/add";
  static const String bookmarkRemove = "$api/bookmark/remove";

  /// =========================
  /// HistoryController
  /// /api/history
  /// =========================
  static const String historyList = "$api/history";
  static const String clearHistory = "$api/history/clear";
  static const String updateHistory = "$api/history";

  /// =========================
  /// ReadingController
  /// /api/reading
  /// =========================
  static const String startReading = "$api/reading/start";
  static const String updateReading = "$api/reading/update";
  static const String finishReading = "$api/reading/finish";

  /// =========================
  /// ChapterController
  /// /api/chapters
  /// =========================
  static const String chapters = "$api/chapters";
  static String chapterDetail(String chapterId) => "$api/chapters/$chapterId";

  /// =========================
  /// FileController
  /// /api/files
  /// =========================
  static const String uploadFile = "$api/files/upload";
  static String getFile(String fileName) => "$api/files/$fileName";

  /// =========================
  /// OfflineDownloadController
  /// /api/offline
  /// =========================
  static const String offlineDownload = "$api/offline/download";
  static const String offlineList = "$api/offline/list";
  static const String offlineRemove = "$api/offline/remove";

  /// =========================
  /// SleepTimerController
  /// /api/sleep-timer
  /// =========================
  static const String sleepTimerSet = "$api/sleep-timer/set";
  static const String sleepTimerCancel = "$api/sleep-timer/cancel";
  static const String sleepTimerStatus = "$api/sleep-timer/status";

  /// =========================
  /// StatsController
  /// /api/stats
  /// =========================
  static const String readingStats = "$api/stats/reading";
  static const String readingStatsByDay = "$api/stats/reading/day";
  static const String readingStatsByMonth = "$api/stats/reading/month";
  static const String readingStatsByYear = "$api/stats/reading/year";

  /// =========================
  /// StoryController
  /// /api/stories
  /// =========================
  static const String stories = "$api/stories";
  static const String storyCreate = "$api/stories/create";

  static String storyDetail(String storyId) => "$api/stories/$storyId";

  static String storyUpdate(String storyId) => "$api/stories/$storyId/update";

  static String storyDelete(String storyId) => "$api/stories/$storyId/delete";

  static String storyChapters(String storyId) =>
      "$api/stories/$storyId/chapters";

  static String storySearch(String keyword) =>
      "$api/stories/search?keyword=$keyword";
}
