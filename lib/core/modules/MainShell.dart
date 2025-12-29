import 'package:flutter/material.dart';
import 'package:reading_book_app/core/modules/library/screens/LibraryScreen.dart';
import 'package:reading_book_app/core/modules/auth/screens/UserScreen.dart';
import 'package:reading_book_app/core/modules/home/screens/HomeScreen.dart';
import 'package:reading_book_app/core/modules/sleep_story/screens/StoryScreen.dart';
import 'package:reading_book_app/core/widgets/BottomNavBar.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;

  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index;

  final _pages = const [
    HomeScreen(),
    StoryScreen(),
    LibraryScreen(),
    UserScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

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
