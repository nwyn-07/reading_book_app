import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingLottie extends StatelessWidget {
  final double size;
  final String asset;

  const LoadingLottie({
    super.key,
    this.size = double.infinity,
    this.asset = 'assets/lottie/loading.json',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(asset, width: size, height: size, repeat: true),
    );
  }
}
