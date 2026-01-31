import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../journal/ui/timeline_screen.dart';
import '../../ai_chat/screens/ai_chat_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../profile/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    TimelineScreen(),
    DashboardScreen(),
    AIChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: _currentIndex == 3 // Hide on Profile
          ? null
          : FloatingActionButton(
              onPressed: () => context.push('/editor'),
              child: const Icon(Icons.add_rounded),
              tooltip: 'New Entry',
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).cardColor,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_stories_outlined),
              activeIcon: Icon(Icons.auto_stories),
              label: 'Journal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insights_outlined),
              activeIcon: Icon(Icons.insights),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.forum_outlined),
              activeIcon: Icon(Icons.forum),
              label: 'AI Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined),
              activeIcon: Icon(Icons.account_circle),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
