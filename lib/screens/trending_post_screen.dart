// lib/screens/trending_posts_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/social_media_service.dart';
import '../widgets/post_card.dart';
import '../widgets/comment_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_display.dart';

class TrendingPostsScreen extends StatelessWidget {
  const TrendingPostsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SocialMediaService>(
      builder: (context, service, child) {
        if (service.users.isEmpty) {
          return const LoadingIndicator(message: 'Loading trending posts...');
        }

        final trendingPosts = service.trendingPosts;

        if (trendingPosts.isEmpty) {
          return const ErrorDisplay(
            message: 'No trending posts found or could not load post data.',
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Posts with Most Comments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: trendingPosts.length,
                  itemBuilder: (context, index) {
                    final post = trendingPosts[index];
                    final user = service.getUserById(post.userId);
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PostCard(
                          post: post,
                          user: user,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 16, top: 8),
                          child: Text(
                            'Comments:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...service.getCommentsForPost(post.id).map(
                          (comment) => CommentCard(comment: comment),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}