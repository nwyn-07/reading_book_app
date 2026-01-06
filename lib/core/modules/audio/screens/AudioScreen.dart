import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:reading_book_app/core/modules/library/sheet/LibraryPickerSheet.dart';

import 'package:reading_book_app/core/stores/AudioStore.dart';
import 'package:reading_book_app/core/stores/LibraryStore.dart';
import 'package:reading_book_app/core/models/SleepOptions.dart';
import 'package:reading_book_app/core/theme/AppColors.dart';
import '../components/SleepTimerWidget.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  Timer? _sleepTimer;
  SleepOption? _currentSleepOption;

  late AudioStore _audio;

  @override
  void initState() {
    super.initState();
    _audio = context.read<AudioStore>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LibraryStore>().fetchLibraries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Consumer<AudioStore>(
            builder: (_, audio, _) {
              final chapter = audio.currentChapter;
              final story = audio.currentStory;

              if (chapter == null || story == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white54,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        GestureDetector(
                          onTap: _showSleepTimer,
                          child: SvgPicture.asset(
                            'assets/icons/clock.svg',
                            width: 22,
                            colorFilter: const ColorFilter.mode(
                              Colors.white54,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 70),

                  Column(
                    children: [
                      Text(
                        chapter.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        chapter.content,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white60),
                      ),
                    ],
                  ),

                  const Spacer(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Consumer<AudioStore>(
                        builder: (context, audioStore, _) {
                          final hasPrevious = audioStore.hasPrevious;
                          return GestureDetector(
                            onTap: hasPrevious ? audioStore.playPrevious : null,
                            child: SvgPicture.asset(
                              'assets/icons/previous-stroke-rounded.svg',
                              width: 30,
                              colorFilter: ColorFilter.mode(
                                hasPrevious
                                    ? AppColors
                                          .textPrimary // Có thể nhấn
                                    : AppColors.iconInactive, // Không thể nhấn
                                BlendMode.srcIn,
                              ),
                            ),
                          );
                        },
                      ),

                      GestureDetector(
                        onTap: audio.isPlaying ? audio.pause : audio.resume,
                        child: SvgPicture.asset(
                          audio.isPlaying
                              ? 'assets/icons/pause.svg'
                              : 'assets/icons/play-1003-svgrepo-com.svg',
                          width: 48,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),

                      Consumer<AudioStore>(
                        builder: (context, audioStore, _) {
                          final hasNext = audioStore.hasNext;
                          return GestureDetector(
                            onTap: hasNext ? audioStore.playNext : null,
                            child: SvgPicture.asset(
                              'assets/icons/next-stroke-rounded.svg',
                              width: 30,
                              colorFilter: ColorFilter.mode(
                                hasNext
                                    ? AppColors.textPrimary
                                    : AppColors.iconInactive,
                                BlendMode.srcIn,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 70),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(
                          _format(audio.position),
                          style: const TextStyle(color: Colors.white60),
                        ),
                        Expanded(
                          child: Slider(
                            value: audio.position.inSeconds
                                .clamp(
                                  0,
                                  audio.duration.inSeconds > 0
                                      ? audio.duration.inSeconds
                                      : 1,
                                )
                                .toDouble(),
                            min: 0,
                            max:
                                (audio.duration.inSeconds > 0
                                        ? audio.duration.inSeconds
                                        : 1)
                                    .toDouble(),
                            activeColor: Colors.orangeAccent,
                            inactiveColor: Colors.white24,
                            onChanged: (v) {
                              audio.seek(Duration(seconds: v.toInt()));
                            },
                          ),
                        ),
                        Text(
                          _format(audio.duration),
                          style: const TextStyle(color: Colors.white60),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          final story = context.read<AudioStore>().currentStory;
                          if (story == null) return;

                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) =>
                                LibraryPickerSheet(storyId: story.id),
                          );
                        },
                        child: _icon('menu-01-stroke-rounded.svg'),
                      ),

                      Consumer<AudioStore>(
                        builder: (_, audio, _) {
                          String icon;
                          Color color;

                          switch (audio.loopMode) {
                            case AudioLoopMode.one:
                              icon =
                                  'assets/icons/repeat-one-01-stroke-rounded.svg';
                              color = AppColors.textPrimary;
                              break;
                            case AudioLoopMode.all:
                              icon = 'assets/icons/repeat-stroke-rounded.svg';
                              color = AppColors.textPrimary;
                              break;
                            default:
                              icon = 'assets/icons/repeat-stroke-rounded.svg';
                              color = AppColors.iconInactive;
                          }

                          return GestureDetector(
                            onTap: audio.toggleLoopMode,
                            child: SvgPicture.asset(
                              icon,
                              width: 30,
                              colorFilter: ColorFilter.mode(
                                color,
                                BlendMode.srcIn,
                              ),
                            ),
                          );
                        },
                      ),

                      Consumer<LibraryStore>(
                        builder: (_, lib, _) {
                          final isFav = lib.isFavorite(story.id);

                          return GestureDetector(
                            onTap: () async {
                              if (isFav) {
                                await lib.removeFromFavorite(story.id);
                              } else {
                                await lib.addToFavorite(story.id);
                              }
                            },
                            child: SvgPicture.asset(
                              isFav
                                  ? 'assets/icons/favourite-filled.svg'
                                  : 'assets/icons/favourite-stroke-rounded.svg',
                              width: 30,
                              colorFilter: ColorFilter.mode(
                                isFav
                                    ? Colors.redAccent
                                    : AppColors.iconInactive,
                                BlendMode.srcIn,
                              ),
                            ),
                          );
                        },
                      ),

                      Consumer<AudioStore>(
                        builder: (_, audio, _) {
                          final chapterId = chapter.id;
                          if (audio.isDownloading) {
                            return SizedBox(
                              width: 25,
                              height: 25,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: audio.downloadProgress,
                                    strokeWidth: 3,
                                    color: AppColors.accent,
                                    backgroundColor: AppColors.iconInactive
                                        .withOpacity(0.3),
                                  ),
                                ],
                              ),
                            );
                          }

                          return FutureBuilder<bool>(
                            future: audio.checkDownloaded(chapterId),
                            builder: (_, snapshot) {
                              final downloaded = snapshot.data ?? false;

                              return GestureDetector(
                                onTap: () async {
                                  if (downloaded) {
                                    await audio.removeDownloadedChapter(
                                      chapter,
                                    );
                                  } else {
                                    await audio.downloadChapter(chapter);
                                  }
                                },
                                child: SvgPicture.asset(
                                  downloaded
                                      ? 'assets/icons/cloud-download-filled.svg'
                                      : 'assets/icons/cloud-download-stroke-rounded.svg',
                                  width: 30,
                                  colorFilter: ColorFilter.mode(
                                    downloaded
                                        ? AppColors.accent
                                        : AppColors.iconInactive,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _icon(String name) {
    return SvgPicture.asset(
      'assets/icons/$name',
      width: 30,
      colorFilter: ColorFilter.mode(AppColors.iconInactive, BlendMode.srcIn),
    );
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _startSleepTimer(Duration duration) {
    _sleepTimer?.cancel();
    _sleepTimer = Timer(duration, _audio.pause);
    _currentSleepOption = sleepOptions.firstWhere(
      (e) => e.duration == duration,
    );
  }

  void _cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _currentSleepOption = null;
  }

  void _showSleepTimer() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SleepTimerWidget(
        initialOption: _currentSleepOption,
        onSelected: (d) =>
            d == null ? _cancelSleepTimer() : _startSleepTimer(d),
        onCancel: _cancelSleepTimer,
      ),
    );
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    super.dispose();
  }
}
