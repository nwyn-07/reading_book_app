class StoryCategory {
  final int id;
  final String title;
  final bool isSelected;

  const StoryCategory({
    required this.id,
    required this.title,
    this.isSelected = false,
  });

  StoryCategory copyWith({int? id, String? title, bool? isSelected}) {
    return StoryCategory(
      id: id ?? this.id,
      title: title ?? this.title,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

final List<StoryCategory> storyCategories = [
  StoryCategory(id: 1, title: 'Tất cả'),
  StoryCategory(id: 2, title: 'Truyện cổ tích'),
  StoryCategory(id: 3, title: 'Câu chuyện'),
  StoryCategory(id: 4, title: 'Câu chuyện thần thoại'),
  StoryCategory(id: 5, title: 'Truyện dân gian'),
  StoryCategory(id: 6, title: 'Truyện ngụ ngôn'),
];
