// lib/services/social_media_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../models/comment.dart';

class SocialMediaService extends ChangeNotifier {
  final ApiClient _apiClient;
  
  // Data storage
  List<User> _users = [];
  Map<String, List<Post>> _userPosts = {};
  Map<String, List<Comment>> _postComments = {};
  
  // Streaming controllers for real-time updates
  final _feedController = StreamController<List<Post>>.broadcast();
  Stream<List<Post>> get feedStream => _feedController.stream;
  
  // Track loaded data
  bool _usersLoaded = false;
  Set<String> _loadedUserPosts = {};
  Set<String> _loadedPostComments = {};
  
  // Top users and trending posts
  List<User> _topUsers = [];
  List<Post> _trendingPosts = [];
  
  // Getters
  List<User> get users => _users;
  List<User> get topUsers => _topUsers;
  List<Post> get trendingPosts => _trendingPosts;
  
  SocialMediaService(this._apiClient);
  
  // Load initial data
  Future<void> initialize() async {
    await fetchUsers();
    _startFeedPolling();
  }
  
  // Fetch all users
  Future<void> fetchUsers() async {
    if (_usersLoaded) return;
    
    try {
      final response = await _apiClient.getUsers();
      final usersMap = response['users'] as Map<String, dynamic>;
      
      _users = usersMap.entries.map((entry) {
        return User.fromJson(entry.key, entry.value);
      }).toList();
      
      _usersLoaded = true;
      
      // Start loading posts for all users
      for (var user in _users) {
        fetchUserPosts(user.id);
      }
      
      _updateTopUsers();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching users: $e');
      }
    }
  }
  
  // Fetch posts for a specific user
  Future<void> fetchUserPosts(String userId) async {
    if (_loadedUserPosts.contains(userId)) return;
    
    try {
      final response = await _apiClient.getUserPosts(userId);
      final postsJson = response['posts'] as List<dynamic>;
      
      final posts = postsJson.map((json) => Post.fromJson(json as Map<String, dynamic>)).toList();
      _userPosts[userId] = posts;
      _loadedUserPosts.add(userId);
      
      // Update user post count
      final user = _users.firstWhere((user) => user.id == userId);
      user.postCount = posts.length;
      
      // Fetch comments for each post
      for (var post in posts) {
        fetchPostComments(post.id);
      }
      
      _updateTrendingPosts();
      _updateFeed();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching posts for user $userId: $e');
      }
    }
  }
  
  // Fetch comments for a specific post
  Future<void> fetchPostComments(String postId) async {
    if (_loadedPostComments.contains(postId)) return;
    
    try {
      final response = await _apiClient.getPostComments(postId);
      final commentsJson = response['comments'] as List<dynamic>;
      
      final comments = commentsJson
          .map((json) => Comment.fromJson(json as Map<String, dynamic>))
          .toList();
      
      _postComments[postId] = comments;
      _loadedPostComments.add(postId);
      
      // Update post comment count
      for (var userPosts in _userPosts.values) {
        for (var post in userPosts) {
          if (post.id == postId) {
            post.commentCount = comments.length;
            break;
          }
        }
      }
      
      _updateTrendingPosts();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching comments for post $postId: $e');
      }
    }
  }
  
  // Update top users based on post count
  void _updateTopUsers() {
    _topUsers = List.from(_users)
      ..sort((a, b) => b.postCount.compareTo(a.postCount));
    
    if (_topUsers.length > 5) {
      _topUsers = _topUsers.sublist(0, 5);
    }
  }
  
  // Update trending posts based on comment count
  void _updateTrendingPosts() {
    List<Post> allPosts = [];
    for (var posts in _userPosts.values) {
      allPosts.addAll(posts);
    }
    
    _trendingPosts = List.from(allPosts)
      ..sort((a, b) => b.commentCount.compareTo(a.commentCount));
    
    // If multiple posts have the same max comment count, include all of them
    if (_trendingPosts.isNotEmpty) {
      final maxComments = _trendingPosts.first.commentCount;
      _trendingPosts = _trendingPosts
          .where((post) => post.commentCount == maxComments)
          .toList();
    }
  }
  
  // Update feed with all posts, newest first
  void _updateFeed() {
    List<Post> allPosts = [];
    for (var posts in _userPosts.values) {
      allPosts.addAll(posts);
    }
    
    // Sort by ID (assuming higher ID means newer post)
    allPosts.sort((a, b) => int.parse(b.id).compareTo(int.parse(a.id)));
    
    _feedController.add(allPosts);
  }
  
  // Poll for new data regularly
  void _startFeedPolling() {
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      // Refresh users occasionally
      await fetchUsers();
      
      // Refresh posts for each user
      for (var user in _users) {
        _loadedUserPosts.remove(user.id); // Force reload
        await fetchUserPosts(user.id);
      }
    });
  }
  
  // Get user by ID
  User? getUserById(String id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Get posts for a user
  List<Post> getPostsForUser(String userId) {
    return _userPosts[userId] ?? [];
  }
  
  // Get comments for a post
  List<Comment> getCommentsForPost(String postId) {
    return _postComments[postId] ?? [];
  }
  
  @override
  void dispose() {
    _feedController.close();
    super.dispose();
  }
}