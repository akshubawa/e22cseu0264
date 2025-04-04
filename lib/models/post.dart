class Post {
  final String id;
  final String userId;
  final String content;
  int commentCount = 0;

  Post({
    required this.id,
    required this.userId,
    required this.content,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'].toString(),
      userId: json['userid'].toString(),
      content: json['content'],
    );
  }
}