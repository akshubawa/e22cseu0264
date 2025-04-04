class Comment {
  final String id;
  final String postId;
  final String content;

  Comment({
    required this.id,
    required this.postId,
    required this.content,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'].toString(),
      postId: json['postid'].toString(),
      content: json['content'],
    );
  }
}