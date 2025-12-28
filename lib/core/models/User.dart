class User {
  final String id;
  final String email;
  final String fullName;
  final String? avatarUrl;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      fullName: json['fullName'],
      avatarUrl: json['avatarUrl'],
    );
  }
}
