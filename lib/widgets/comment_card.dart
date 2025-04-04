// lib/widgets/comment_card.dart
import 'package:flutter/material.dart';
import '../models/comment.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;

  const CommentCard({
    super.key,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              comment.content,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Comment ID: ${comment.id}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}