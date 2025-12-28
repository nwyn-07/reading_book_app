import 'Book.dart';
import 'Library.dart';

class LibraryStory {
  final Library library;
  final Book story;

  LibraryStory({required this.library, required this.story});

  factory LibraryStory.fromJson(Map<String, dynamic> json) {
    return LibraryStory(
      library: Library.fromJson(json['library']),
      story: Book.fromJson(json['story']),
    );
  }
}
