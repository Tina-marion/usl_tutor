import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/learning_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/stubs.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const USLTutorApp());
}

class USLTutorApp extends StatelessWidget {
  const USLTutorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'USL Tutor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
        '/learning': (context) => const LearningScreen(),
        '/practice': (context) => const PracticeScreen(),
        '/quiz': (context) => const QuizScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }
}
