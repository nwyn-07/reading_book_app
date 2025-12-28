import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reading_book_app/core/models/Chapter.dart';
import 'package:reading_book_app/core/models/Book.dart';
import 'package:reading_book_app/core/stores/AudioStore.dart';
import 'package:reading_book_app/core/stores/ChapterStore.dart';

class ChapterScreen extends StatefulWidget {
  final Book story;

  const ChapterScreen({super.key, required this.story});

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final chapterStore = context.read<ChapterStore>();
      await chapterStore.fetchChapters(widget.story.id);
      context.read<AudioStore>().setChapters(chapterStore.chapters);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.story.title),
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
            separatorBuilder: (_, _) => const Divider(height: 1),
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
                  final audio = context.read<AudioStore>();

                  audio.playChapter(story: widget.story, chapter: chapter);

                  Navigator.of(context).pushNamed('/audio');
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
