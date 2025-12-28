import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:reading_book_app/core/models/Chapter.dart';
import 'package:reading_book_app/core/services/audio/AudioService.dart';
import 'package:reading_book_app/core/theme/AppColors.dart';
import '../components/SleepTimerWidget.dart';

class AudioScreen extends StatefulWidget {
  final String storyTitle;
  final Chapter chapter;

  const AudioScreen({
    super.key,
    required this.storyTitle,
    required this.chapter,
  });

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  Timer? _sleepTimer;
  Duration _duration = Duration.zero;

  late AudioService _audio;

  @override
  void initState() {
    super.initState();

    _audio = context.read<AudioService>();

    _audio.player.durationStream.listen((d) {
      if (d != null && mounted) {
        setState(() => _duration = d);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _audio.playChapter(story: widget.storyTitle, chapter: widget.chapter);
    });
  }

  @override
  Widget build(BuildContext context) {
    final player = _audio.player;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
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
                    widget.chapter.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.chapter.content,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white60),
                  ),
                ],
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _icon('previous-stroke-rounded.svg'),
                  StreamBuilder<PlayerState>(
                    stream: player.playerStateStream,
                    builder: (_, snapshot) {
                      final playing = snapshot.data?.playing ?? false;
                      return GestureDetector(
                        onTap: () => playing ? _audio.pause() : _audio.resume(),
                        child: SvgPicture.asset(
                          playing
                              ? 'assets/icons/pause.svg'
                              : 'assets/icons/play-1003-svgrepo-com.svg',
                          width: 48,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      );
                    },
                  ),
                  _icon('next-stroke-rounded.svg'),
                ],
              ),

              const SizedBox(height: 70),

              StreamBuilder<Duration>(
                stream: player.positionStream,
                builder: (_, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final max = _duration.inSeconds > 0 ? _duration.inSeconds : 1;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(
                          _format(position),
                          style: const TextStyle(color: Colors.white60),
                        ),
                        Expanded(
                          child: Slider(
                            value: position.inSeconds.clamp(0, max).toDouble(),
                            min: 0,
                            max: max.toDouble(),
                            activeColor: Colors.orangeAccent,
                            inactiveColor: Colors.white24,
                            onChanged: (v) {
                              player.seek(Duration(seconds: v.toInt()));
                            },
                          ),
                        ),
                        Text(
                          _format(_duration),
                          style: const TextStyle(color: Colors.white60),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _icon('menu-01-stroke-rounded.svg'),
                  _icon('repeat-stroke-rounded.svg'),
                  _icon('favourite-stroke-rounded.svg'),
                  _icon('cloud-download-stroke-rounded.svg'),
                ],
              ),

              const SizedBox(height: 40),
            ],
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
    _sleepTimer = Timer(duration, () => _audio.pause());
  }

  void _cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
  }

  void _showSleepTimer() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SleepTimerWidget(
        onSelected: (duration) {
          if (duration == null) {
            _cancelSleepTimer();
          } else {
            _startSleepTimer(duration);
          }
        },
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
