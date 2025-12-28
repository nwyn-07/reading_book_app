import 'package:flutter/material.dart';
import 'package:reading_book_app/core/auth/screens/UserScreen.dart';
import 'package:reading_book_app/core/home/screens/HomeScreen.dart';
import 'package:reading_book_app/core/sleep_story/screens/StoryScreen.dart';
import 'package:reading_book_app/core/widgets/BottomNavBar.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _pages = const [
    HomeScreen(),
    HomeScreen(),
    StoryScreen(),
    HomeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
