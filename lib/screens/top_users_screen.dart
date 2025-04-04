// lib/screens/top_users_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/social_media_service.dart';
import '../widgets/user_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_display.dart';

class TopUsersScreen extends StatelessWidget {
  const TopUsersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SocialMediaService>(
      builder: (context, service, child) {
        if (service.users.isEmpty) {
          return const LoadingIndicator(message: 'Loading users...');
        }

        final topUsers = service.topUsers;

        if (topUsers.isEmpty) {
          return const ErrorDisplay(
            message: 'No users found or could not load user data.',
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
                  'Top 5 Users by Post Count',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: topUsers.length,
                  itemBuilder: (context, index) {
                    final user = topUsers[index];
                    return UserCard(
                      user: user,
                      onTap: () {
                        // Could navigate to user details
                      },
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