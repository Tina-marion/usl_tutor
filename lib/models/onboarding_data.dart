import 'package:flutter/material.dart';

class OnboardingPage {
  final String title;
  final String description;
  final String image;
  final String? lottieAnimation;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
    this.lottieAnimation,
  });
}

class OnboardingData {
  static const List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Learn Sign Language\nAnytime, Anywhere',
      description:
          'Master USL through interactive lessons and real-time practice with our AI-powered tutor.',
      image: '📚',
    ),
    OnboardingPage(
      title: 'Practice with AI\nGet Instant Feedback',
      description:
          'Our AI recognizes your signs and helps you improve with personalized corrections.',
      image: '🎥',
    ),
    OnboardingPage(
      title: 'Track Your Progress\nEarn Achievements',
      description:
          'Monitor your learning journey and celebrate milestones as you master new signs.',
      image: '📊',
    ),
  ];
}
