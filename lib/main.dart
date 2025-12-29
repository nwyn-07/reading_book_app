import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reading_book_app/core/models/Book.dart';
import 'package:reading_book_app/core/models/Library.dart';
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
import 'package:reading_book_app/core/modules/auth/screens/HistoryScreen.dart';
import 'package:reading_book_app/core/modules/auth/screens/DownloadScreen.dart';
import 'package:reading_book_app/core/modules/auth/screens/PlaylistScreen.dart';

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
            '/home': (context) {
              final args = ModalRoute.of(context)?.settings.arguments as Map?;
              final int index = args?['tab'] ?? 0;
              return MainShell(initialIndex: index);
            },
            '/audio': (_) => AudioScreen(),
            '/chapter': (context) {
              final args =
                  ModalRoute.of(context)!.settings.arguments
                      as Map<String, dynamic>;
              final Book story = args['story'] as Book;

              return ChapterScreen(story: story);
            },
            //'/favourite': (_) => FavouriteScreen(),
            '/history': (_) => HistoryScreen(),
            '/download': (_) => DownloadScreen(),
            // TRONG routes
            '/playlist': (_) {
              return Builder(
                builder: (context) {
                  // Tự động lấy favorite library từ store
                  final libraryStore = context.read<LibraryStore>();

                  // Tìm favorite library
                  Library? favoriteLibrary;
                  try {
                    favoriteLibrary = libraryStore.libraries.firstWhere(
                      (lib) => lib.name == 'Yêu thích',
                    );
                  } catch (_) {
                    // Nếu chưa có, có thể trả về empty state
                  }

                  return PlaylistScreen(
                    library: favoriteLibrary,
                    isFavorite: true,
                  );
                },
              );
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
