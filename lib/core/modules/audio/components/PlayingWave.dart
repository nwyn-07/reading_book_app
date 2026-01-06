import 'package:flutter/material.dart';

class PlayingWave extends StatefulWidget {
  final bool isPlaying;
  const PlayingWave({super.key, required this.isPlaying});

  @override
  State<PlayingWave> createState() => _PlayingWaveState();
}

class _PlayingWaveState extends State<PlayingWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant PlayingWave oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.isPlaying ? _controller.repeat(reverse: true) : _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _bar(heightFactor: 0.7, inverse: true),
          _bar(heightFactor: 1.0, inverse: false),
          _bar(heightFactor: 1.0, inverse: true),
        ],
      ),
    );
  }

  Widget _bar({required double heightFactor, required bool inverse}) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        final value = inverse ? 1 - _controller.value : _controller.value;

        final height = 7 + 10 * value * heightFactor;

        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 4,
            height: height,
            decoration: BoxDecoration(
              color: Colors.orangeAccent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      },
    );
  }
}
