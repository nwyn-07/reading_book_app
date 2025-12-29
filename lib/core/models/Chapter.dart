import 'package:reading_book_app/core/models/Book.dart';

class Chapter {
  final String id;
  final String title;
  final String content;
  final String audioUrl;
  final int chapterIndex;
  final int durationSeconds;
  final Book story;

  Chapter({
    required this.id,
    required this.title,
    required this.content,
    required this.audioUrl,
    required this.chapterIndex,
    required this.durationSeconds,
    required this.story,
  });

  /// =========================
  /// FROM JSON
  /// =========================
  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      audioUrl: json['audioUrl'] ?? '',
      chapterIndex: json['chapterIndex'] ?? 0,
      durationSeconds: json['durationSeconds'] ?? 0,
      story: Book.fromJson(json['story'] as Map<String, dynamic>),
    );
  }

  /// =========================
  /// TO JSON
  /// =========================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'chapterIndex': chapterIndex,
      'durationSeconds': durationSeconds,
      'audioUrl': audioUrl,
      'story': story.toJson(),
    };
  }
}
