// lib/api/api_endpoints.dart
class ApiEndpoints {
  static const String baseUrl = 'http://20.244.56.144/evaluation-service';
  
  // Registration endpoints
  static const String register = '$baseUrl/register';
  static const String auth = '$baseUrl/auth';
  
  // Social media endpoints
  static const String users = '$baseUrl/users';
  static String userPosts(String userId) => '$baseUrl/users/$userId/posts';
  static String postComments(String postId) => '$baseUrl/posts/$postId/comments';
}