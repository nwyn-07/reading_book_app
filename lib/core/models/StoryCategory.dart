class StoryCategory {
  final int id;
  final String title;

  /// 👇 value gửi lên BE (StoryType)
  final String value;

  final bool isSelected;

  const StoryCategory({
    required this.id,
    required this.title,
    required this.value,
    this.isSelected = false,
  });

  StoryCategory copyWith({
    int? id,
    String? title,
    String? value,
    bool? isSelected,
  }) {
    return StoryCategory(
      id: id ?? this.id,
      title: title ?? this.title,
      value: value ?? this.value,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  /// =========================
  /// MOCK DATA (mapping BE)
  /// =========================
  static const List<StoryCategory> mockData = [
    StoryCategory(id: 0, title: 'Tất cả', value: 'ALL'),
    StoryCategory(id: 1, title: 'Cổ tích', value: 'FAIRY_TALE'),
    StoryCategory(id: 2, title: 'Thần thoại', value: 'MYTH'),
    StoryCategory(id: 3, title: 'Dân gian', value: 'FOLKTALE'),
    StoryCategory(id: 4, title: 'Ngụ ngôn', value: 'FABLE'),
    StoryCategory(id: 5, title: 'Câu chuyện', value: 'STORY'),
  ];
}
