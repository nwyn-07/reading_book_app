import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reading_book_app/core/models/Chapter.dart';
import 'package:reading_book_app/core/stores/ChapterStore.dart';

class ChapterScreen extends StatefulWidget {
  final String storyId;
  final String storyTitle;

  const ChapterScreen({
    super.key,
    required this.storyId,
    required this.storyTitle,
  });

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChapterStore>().fetchChapters(widget.storyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.storyTitle),
        backgroundColor: Colors.black,
      ),
      body: Consumer<ChapterStore>(
        builder: (context, store, _) {
          if (store.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (store.error != null) {
            return Center(child: Text(store.error!));
          }

          if (store.chapters.isEmpty) {
            return const Center(child: Text('Chưa có chương'));
          }

          return ListView.separated(
            itemCount: store.chapters.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, index) {
              final Chapter chapter = store.chapters[index];

              return ListTile(
                title: Text(
                  'Chương ${chapter.chapterIndex}: ${chapter.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(_formatDuration(chapter.durationSeconds)),
                trailing: const Icon(Icons.play_arrow),
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/audio',
                    arguments: {
                      'storyTitle': widget.storyTitle,
                      'chapter': chapter,
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
