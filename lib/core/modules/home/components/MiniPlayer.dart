import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:reading_book_app/core/stores/AudioStore.dart';
import 'package:reading_book_app/core/theme/AppColors.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioStore>(
      builder: (_, audio, _) {
        if (!audio.isMiniVisible || audio.currentChapter == null) {
          return const SizedBox.shrink();
        }

        final story = audio.currentStory!;
        final chapter = audio.currentChapter!;
        final player = audio.player;

        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/audio',
              arguments: {'story': story, 'chapter': chapter},
            );
          },
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        chapter.title,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                StreamBuilder<PlayerState>(
                  stream: player.playerStateStream,
                  builder: (_, snapshot) {
                    final playing = snapshot.data?.playing ?? false;
                    return IconButton(
                      icon: SvgPicture.asset(
                        playing
                            ? 'assets/icons/pause.svg'
                            : 'assets/icons/play-1003-svgrepo-com.svg',
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          AppColors.iconActive,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: playing ? audio.pause : audio.resume,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
