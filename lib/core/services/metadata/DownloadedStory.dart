class DownloadedStory {
  final String id;
  final String title;
  final String? coverImageUrl;
  final String? author;
  final int totalChapters;
  final int downloadedChapters;
  final int totalSize;
  final DateTime lastModified;
  final List<String> chapterIds;

  DownloadedStory({
    required this.id,
    required this.title,
    this.coverImageUrl,
    this.author,
    required this.totalChapters,
    required this.downloadedChapters,
    required this.totalSize,
    required this.lastModified,
    required this.chapterIds,
  });

  factory DownloadedStory.fromJson(Map<String, dynamic> json) {
    return DownloadedStory(
      id: json['id'],
      title: json['title'],
      coverImageUrl: json['coverImageUrl'],
      author: json['author'],
      totalChapters: json['totalChapters'],
      downloadedChapters: json['downloadedChapters'],
      totalSize: json['totalSize'],
      lastModified: DateTime.parse(json['lastModified']),
      chapterIds: List<String>.from(json['chapterIds']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'coverImageUrl': coverImageUrl,
      'author': author,
      'totalChapters': totalChapters,
      'downloadedChapters': downloadedChapters,
      'totalSize': totalSize,
      'lastModified': lastModified.toIso8601String(),
      'chapterIds': chapterIds,
    };
  }
}
