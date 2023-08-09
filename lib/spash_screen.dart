import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:diary_journal/views/home/home_view.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
        splash: Image.asset('assets/images/diary_logo.png'),
        splashIconSize: 100,
        duration: 3000,
        nextScreen: const HomeView());
  }
}
