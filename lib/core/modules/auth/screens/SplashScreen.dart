import 'package:flutter/material.dart';
import 'package:reading_book_app/core/components/LoadingLottie.dart';
import 'package:reading_book_app/core/theme/AppColors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: AppColors.background),
        child: const Center(child: LoadingLottie()),
      ),
    );
  }
}
