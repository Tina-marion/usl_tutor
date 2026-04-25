import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants/app_constants.dart';
import '../services/user_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _userService = UserService();

  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await _userService.init();
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final user = _userService.getUserProfile();
    if (user.name == 'USL Learner') {
      Navigator.pushReplacementNamed(context, '/profile-creation');
    } else {
      Navigator.pushReplacementNamed(
          context, '/onboarding'); // or '/home' if you prefer
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Big Animated Logo
            _buildAnimatedLogo(),

            const SizedBox(height: 40),

            // App Name
            Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.87),
                letterSpacing: -1,
              ),
            )
                .animate()
                .fadeIn(duration: 700.ms, delay: 200.ms)
                .slideY(begin: 0.4, end: 0, curve: Curves.easeOutCubic),

            const SizedBox(height: 12),

            // Tagline
            Text(
              AppConstants.appTagline,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(duration: 700.ms, delay: 500.ms)
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 80),

            // Loading Indicator
            _buildLoadingIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.25),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.sign_language,
          size: 110,
          color: Colors.green.shade600,
        ),
      ),
    )
        .animate()
        .scale(
          duration: 800.ms,
          curve: Curves.elasticOut,
        )
        .then()
        .shimmer(duration: 1200.ms, delay: 300.ms)
        .fadeIn();
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        const SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            strokeWidth: 4.5,
            valueColor: AlwaysStoppedAnimation(Colors.green),
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .rotate(duration: 1800.ms),
        const SizedBox(height: 24),
        Text(
          AppConstants.loadingMessage,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ).animate().fadeIn(delay: 600.ms),
      ],
    );
  }
}
