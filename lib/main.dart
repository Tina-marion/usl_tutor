import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'constants/app_theme.dart';
import 'services/theme_service.dart';
import 'screens/home_screen.dart';
import 'screens/learning_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_creation_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/practice_screen.dart';
import 'screens/quiz_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeService = ThemeService();
  await themeService.init();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  runApp(
    ChangeNotifierProvider<ThemeService>.value(
      value: themeService,
      child: const USLTutorApp(),
    ),
  );
}

class USLTutorApp extends StatelessWidget {
  const USLTutorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          title: 'USL Tutor',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeService.themeMode,
          home: const SplashScreen(),
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/profile-creation': (context) => const ProfileCreationScreen(),
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
      },
    );
  }
}
