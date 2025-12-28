import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reading_book_app/core/models/Book.dart';
import 'package:reading_book_app/core/modules/MainShell.dart';
import 'package:reading_book_app/core/modules/audio/screens/AudioScreen.dart';
import 'package:reading_book_app/core/modules/auth/screens/SplashScreen.dart';
import 'package:reading_book_app/core/modules/chapter/ChapterScreen.dart';
import 'package:reading_book_app/core/stores/AudioStore.dart';
import 'package:reading_book_app/core/stores/ChapterStore.dart';
import 'package:reading_book_app/core/stores/DownloadStore.dart';
import 'package:reading_book_app/core/stores/LibraryStore.dart';
import 'package:reading_book_app/core/utils/Utils.dart';

import 'package:reading_book_app/core/stores/AuthStore.dart';
import 'package:reading_book_app/core/modules/auth/screens/LoginScreen.dart';
import 'package:reading_book_app/core/stores/StoryStore.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthStore()..init()),
        ChangeNotifierProvider(create: (_) => StoryStore()),
        ChangeNotifierProvider(create: (_) => ChapterStore()),
        ChangeNotifierProvider(create: (_) => AudioStore()),
        ChangeNotifierProvider(create: (_) => LibraryStore()),
        ChangeNotifierProvider(create: (_) => DownloadStore()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthStore>(
      builder: (context, auth, _) {
        return MaterialApp(
          navigatorKey: Utils.navigatorKey,
          title: 'Reading Book App',
          debugShowCheckedModeBanner: false,

          home: _buildHome(auth),

          routes: {
            '/home': (_) => MainShell(),
            '/audio': (_) => AudioScreen(),
            '/chapter': (context) {
              final args =
                  ModalRoute.of(context)!.settings.arguments
                      as Map<String, dynamic>;
              final Book story = args['story'] as Book;

              return ChapterScreen(story: story);
            },
          },
        );
      },
    );
  }

  /// =========================
  /// Root decision
  /// =========================
  Widget _buildHome(AuthStore auth) {
    if (auth.isLoading) {
      return const SplashScreen();
    }

    if (auth.isAuthenticated) {
      return MainShell();
    }

    return LoginScreen();
  }
}
