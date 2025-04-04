class User {
  final String id;
  final String name;
  int postCount = 0;

  User({
    required this.id,
    required this.name,
  });

  factory User.fromJson(String id, String name) {
    return User(
      id: id,
      name: name,
    );
  }
}