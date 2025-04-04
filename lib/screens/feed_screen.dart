// lib/screens/feed_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/social_media_service.dart';
import '../widgets/post_card.dart';
import '../widgets/loading_indicator.dart';
import '../models/post.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<SocialMediaService>(context, listen: false);
    
    return StreamBuilder<List<Post>>(
      stream: service.feedStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const LoadingIndicator(message: 'Loading feed...');
        }

        final posts = snapshot.data!;

        return RefreshIndicator(
          onRefresh: () async {
            // Force refresh of users and their posts
            await service.fetchUsers();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Recent Posts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      final user = service.getUserById(post.userId);
                      
                      return PostCard(
                        post: post,
                        user: user,
                        onTap: () {
                          // Could navigate to post details
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}