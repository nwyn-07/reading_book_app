import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:just_audio/just_audio.dart';
import 'package:reading_book_app/core/audio/components/RecommendedWidget.dart';
import 'package:reading_book_app/core/theme/AppColors.dart';
import '../components/SleepTimerWidget.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  final AudioPlayer _player = AudioPlayer();

  Duration _duration = Duration.zero;
  Timer? _sleepTimer;
  bool _isRecommendedExpanded = false;
  int _currentStoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _player.durationStream.listen((d) {
      if (d != null && mounted) {
        setState(() => _duration = d);
      }
    });
    _changeStory(0);
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
          child: Column(
            children: [
              const SizedBox(height: 16),

              /// HEADER
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
                      onPressed: () async {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
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
              //INFO
              Column(
                children: [
                  Text(
                    'Story ${_currentStoryIndex + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              /// PLAY / PAUSE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SvgPicture.asset(
                    'assets/icons/previous-stroke-rounded.svg',
                    width: 36,
                    colorFilter: ColorFilter.mode(
                      AppColors.iconInactive,
                      BlendMode.srcIn,
                    ),
                  ),
                  StreamBuilder<PlayerState>(
                    stream: _player.playerStateStream,
                    builder: (context, snapshot) {
                      final playing = snapshot.data?.playing ?? false;
                      return GestureDetector(
                        onTap: () => playing ? _player.pause() : _player.play(),
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
                  SvgPicture.asset(
                    'assets/icons/next-stroke-rounded.svg',
                    width: 36,
                    colorFilter: ColorFilter.mode(
                      AppColors.iconInactive,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 70),

              /// SLIDER
              StreamBuilder<Duration>(
                stream: _player.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;

                  final maxSeconds = _duration.inSeconds > 0
                      ? _duration.inSeconds.toDouble()
                      : 1.0;

                  final valueSeconds = position.inSeconds
                      .clamp(0, maxSeconds)
                      .toDouble();

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
                            value: valueSeconds,
                            min: 0,
                            max: maxSeconds,
                            activeColor: Colors.orangeAccent,
                            inactiveColor: Colors.white24,
                            onChanged: (v) {
                              _player.seek(Duration(seconds: v.toInt()));
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
              //ACTIONS + RECOMMENDED
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,

                children: [
                  SvgPicture.asset(
                    'assets/icons/menu-01-stroke-rounded.svg',
                    width: 30,
                    colorFilter: const ColorFilter.mode(
                      Colors.white54,
                      BlendMode.srcIn,
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/icons/repeat-stroke-rounded.svg',
                    width: 30,
                    colorFilter: ColorFilter.mode(
                      AppColors.iconInactive,
                      BlendMode.srcIn,
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/icons/favourite-stroke-rounded.svg',
                    width: 30,
                    colorFilter: ColorFilter.mode(
                      AppColors.iconInactive,
                      BlendMode.srcIn,
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/icons/cloud-download-stroke-rounded.svg',
                    width: 30,
                    colorFilter: const ColorFilter.mode(
                      Colors.white54,
                      BlendMode.srcIn,
                    ),
                  ),
                  // const SizedBox(width: 32),
                ],
              ),
              const SizedBox(height: 50),

              /// RECOMMENDED
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: RecommendedWidget(
                  isExpanded: _isRecommendedExpanded,
                  onToggle: () {
                    setState(() {
                      _isRecommendedExpanded = !_isRecommendedExpanded;
                    });
                  },
                  stories: const ['Story 1', 'Story 2', 'Story 3', 'Story 4'],
                  onStorySelected: (index) {
                    _changeStory(index);
                  },
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Future<void> _initAudio() async {
  //   await _player.stop();
  //   await _player.setAsset('assets/audio/test.mp3');

  //   _player.durationStream.listen((d) {
  //     if (d != null && mounted) {
  //       setState(() => _duration = d);
  //     }
  //   });
  // }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _startSleepTimer(Duration duration) {
    _sleepTimer?.cancel();
    _sleepTimer = Timer(duration, () {
      _player.pause();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã hẹn giờ ${duration.inMinutes} phút'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã huỷ hẹn giờ'),
        duration: Duration(seconds: 2),
      ),
    );
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
            _sleepTimer?.cancel();
            _sleepTimer = null;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chạy không giới hạn')),
            );
          } else {
            _startSleepTimer(duration);
          }
        },
        onCancel: _cancelSleepTimer,
      ),
    );
  }

  Future<void> _changeStory(int index) async {
    if (_currentStoryIndex == index) return;

    _sleepTimer?.cancel();

    await _player.stop();

    setState(() {
      _currentStoryIndex = index;
      _duration = Duration.zero;
    });

    await _player.setAudioSource(AudioSource.asset('assets/audio/test.mp3'));
    await _player.load();
    await _player.play();
  }

  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final int newIndex = args?['storyIndex'] ?? 0;

      _changeStory(newIndex);
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _player.pause();
    _player.dispose();
    super.dispose();
  }
}
