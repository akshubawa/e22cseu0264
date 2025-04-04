// lib/api/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_endpoints.dart';

class ApiClient {
  String? _accessToken;
  final String _clientId;
  final String _clientSecret;
  
  ApiClient({
    required String clientId,
    required String clientSecret,
  }) : _clientId = clientId,
       _clientSecret = clientSecret;
  
  // Register your application
  Future<Map<String, dynamic>> register({
    required String email,
    required String name,
    required String mobileNo,
    required String githubUsername,
    required String rollNo,
    required String collegeName,
    required String accessCode,
  }) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'name': name,
        'mobileNo': mobileNo,
        'githubUsername': githubUsername,
        'rollNo': rollNo,
        'collegeName': collegeName,
        'accessCode': accessCode,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }
  
  // Get authorization token
  Future<void> getAuthToken({
    required String email,
    required String name,
    required String rollNo,
    required String accessCode,
  }) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.auth),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'name': name,
        'rollNo': rollNo,
        'accessCode': accessCode,
        'clientID': _clientId,
        'clientSecret': _clientSecret,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['access_token'];
    } else {
      throw Exception('Failed to get auth token: ${response.body}');
    }
  }
  
  // Helper method to check if token is available
  Future<void> _ensureToken() async {
    if (_accessToken == null) {
      throw Exception('Authorization token not available. Please authenticate first.');
    }
  }
  
  // Get all users
  Future<Map<String, dynamic>> getUsers() async {
    await _ensureToken();
    
    final response = await http.get(
      Uri.parse(ApiEndpoints.users),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch users: ${response.body}');
    }
  }
  
  // Get posts by user ID
  Future<Map<String, dynamic>> getUserPosts(String userId) async {
    await _ensureToken();
    
    final response = await http.get(
      Uri.parse(ApiEndpoints.userPosts(userId)),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch posts: ${response.body}');
    }
  }
  
  // Get comments by post ID
  Future<Map<String, dynamic>> getPostComments(String postId) async {
    await _ensureToken();
    
    final response = await http.get(
      Uri.parse(ApiEndpoints.postComments(postId)),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch comments: ${response.body}');
    }
  }
}