import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reading_book_app/core/stores/ReadingStore.dart';
import 'package:reading_book_app/core/stores/StatsStore.dart';

import 'package:reading_book_app/core/utils/Utils.dart';

// ===== STORES =====
import 'package:reading_book_app/core/stores/AuthStore.dart';
import 'package:reading_book_app/core/stores/UserStore.dart';
import 'package:reading_book_app/core/stores/StoryStore.dart';
import 'package:reading_book_app/core/stores/ChapterStore.dart';
import 'package:reading_book_app/core/stores/LibraryStore.dart';
import 'package:reading_book_app/core/stores/DownloadStore.dart';
import 'package:reading_book_app/core/stores/HistoryStore.dart';
import 'package:reading_book_app/core/stores/AudioStore.dart';

// ===== SCREENS / MODULES =====
import 'package:reading_book_app/core/modules/MainShell.dart';
import 'package:reading_book_app/core/modules/audio/screens/AudioScreen.dart';
import 'package:reading_book_app/core/modules/chapter/ChapterScreen.dart';
import 'package:reading_book_app/core/modules/auth/screens/LoginScreen.dart';
import 'package:reading_book_app/core/modules/auth/screens/SplashScreen.dart';
import 'package:reading_book_app/core/modules/auth/screens/HistoryScreen.dart';
import 'package:reading_book_app/core/modules/auth/screens/DownloadScreen.dart';
import 'package:reading_book_app/core/modules/auth/screens/PlaylistScreen.dart';

// ===== MODELS =====
import 'package:reading_book_app/core/models/Book.dart';
import 'package:reading_book_app/core/models/Library.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthStore()..init()),
        ChangeNotifierProvider(create: (_) => StoryStore()),
        ChangeNotifierProvider(create: (_) => ChapterStore()),
        ChangeNotifierProvider(create: (_) => LibraryStore()),
        ChangeNotifierProvider(create: (_) => DownloadStore()),
        ChangeNotifierProvider(create: (_) => UserStore()),
        ChangeNotifierProvider(create: (_) => StatsStore()),
        ChangeNotifierProvider(create: (_) => ReadingStore()),
        ChangeNotifierProvider(create: (_) => HistoryStore()),
        ChangeNotifierProxyProvider<HistoryStore, AudioStore>(
          create: (_) => AudioStore(),
          update: (_, historyStore, audioStore) {
            audioStore ??= AudioStore();
            audioStore.attachHistoryStore(historyStore);
            return audioStore;
          },
        ),
        ChangeNotifierProvider(create: (_) => ReadingStore()),
        ChangeNotifierProxyProvider<ReadingStore, AudioStore>(
          create: (_) => AudioStore(),
          update: (_, readingStore, audioStore) {
            audioStore!.attachReadingStore(readingStore);
            return audioStore;
          },
        ),
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
            '/home': (context) {
              final args = ModalRoute.of(context)?.settings.arguments as Map?;
              final int index = args?['tab'] ?? 0;
              return MainShell(initialIndex: index);
            },
            '/audio': (_) => const AudioScreen(),
            '/chapter': (context) {
              final args =
                  ModalRoute.of(context)!.settings.arguments
                      as Map<String, dynamic>;
              final Book story = args['story'] as Book;
              return ChapterScreen(story: story);
            },
            '/history': (_) => const HistoryScreen(),
            '/download': (_) => const DownloadScreen(),
            '/playlist': (context) {
              final library =
                  ModalRoute.of(context)?.settings.arguments as Library?;

              if (library != null) {
                return PlaylistScreen(
                  library: library,
                  isFavorite: library.name == 'Yêu thích',
                );
              }

              final libraryStore = context.read<LibraryStore>();
              Library? favoriteLibrary;

              try {
                favoriteLibrary = libraryStore.libraries.firstWhere(
                  (lib) => lib.name == 'Yêu thích',
                );
              } catch (_) {
                return PlaylistScreen(library: null, isFavorite: true);
              }

              return PlaylistScreen(library: favoriteLibrary, isFavorite: true);
            },
          },
        );
      },
    );
  }

  /// =========================
  /// ROOT DECISION
  /// =========================
  Widget _buildHome(AuthStore auth) {
    if (auth.isLoading) {
      return const SplashScreen();
    }

    if (auth.isAuthenticated) {
      return const MainShell();
    }

    return const LoginScreen();
  }
}
