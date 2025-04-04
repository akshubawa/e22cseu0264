// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_meida_analytics/screens/trending_post_screen.dart';
import 'api/api_client.dart';
import 'services/social_media_service.dart';
import 'screens/auth_screen.dart';
import 'screens/top_users_screen.dart';
import 'screens/feed_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Media Analytics',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isAuthenticated = false;
  late ApiClient _apiClient;
  late SocialMediaService _socialMediaService;

  void _onAuthenticated(String clientId, String clientSecret) {
    _apiClient = ApiClient(
      clientId: clientId,
      clientSecret: clientSecret,
    );
    
    _socialMediaService = SocialMediaService(_apiClient);
    
    // Initialize service data
    _socialMediaService.initialize().then((_) {
      setState(() {
        _isAuthenticated = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return AuthScreen(onAuthenticated: _onAuthenticated);
    }

    return ChangeNotifierProvider.value(
      value: _socialMediaService,
      child: const SocialMediaDashboard(),
    );
  }
}

class SocialMediaDashboard extends StatefulWidget {
  const SocialMediaDashboard({Key? key}) : super(key: key);

  @override
  State<SocialMediaDashboard> createState() => _SocialMediaDashboardState();
}

class _SocialMediaDashboardState extends State<SocialMediaDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    TopUsersScreen(),
    TrendingPostsScreen(),
    FeedScreen(),
  ];

  final List<String> _titles = [
    'Top Users',
    'Trending Posts',
    'Feed',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final service = Provider.of<SocialMediaService>(context, listen: false);
              service.fetchUsers();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Refreshing data...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Top Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Trending',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dynamic_feed),
            label: 'Feed',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}