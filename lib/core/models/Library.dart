import 'User.dart';

class Library {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final User user;

  Library({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.user,
  });

  factory Library.fromJson(Map<String, dynamic> json) {
    return Library(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      user: User.fromJson(json['user']),
    );
  }
}
