import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui' show ImageFilter;

import '../constants/app_constants.dart';
import '../services/progress_service.dart';
import '../services/user_service.dart';
import '../widgets/activity_item.dart';
import '../widgets/quick_action_card.dart';   // we'll enhance this too

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Demo/default state values to prevent undefined name errors.
  // Replace or initialize these from your real user/progress services as needed.
  String userName = 'Student';
  int signsLearnedThisWeek = 5;
  String greeting = 'Hello';
  String dailyChallenge = 'Basic Greetings';
  double dailyChallengeProgress = 0.2;

  // ... (your existing state variables and methods remain the same)
  // Keep _initializeServices, _onBottomNavTap, _addTestActivities, greeting, etc.

  // Progress service instance used throughout the screen
  final ProgressService _progressService = ProgressService();

  // Loading flag used by the build method
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0B2E), // Deep playful indigo background
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : RefreshIndicator(
              onRefresh: () async {
                await _progressService.init();
                setState(() {});
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WelcomeSection(
                      userName: userName,
                      signsLearned: signsLearnedThisWeek,
                      greeting: greeting,
                    ),
                    const SizedBox(height: 40),
                    _DailyChallengeCard(
                      dailyChallenge: dailyChallenge,
                      progress: dailyChallengeProgress,
                    ),
                    const SizedBox(height: 40),
                    _QuickActionsSection(),
                    const SizedBox(height: 40),
                    _RecentActivitySection(progressService: _progressService),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/practice'),
        icon: const Icon(Icons.videocam_rounded, size: 28),
        label: const Text('Start Video Practice', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.pinkAccent,
        elevation: 10,
      ).animate().scale(duration: 400.ms),
    );
  }

  // AppBar and BottomNav remain mostly the same (you can make title more colourful if you want)
  // Simple implementations to ensure methods exist and compile.

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'USL Tutor',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {
            // placeholder - add notification handling if needed
          },
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    // Minimal bottom bar to avoid undefined method error; replace with your full implementation if needed.
    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.school_rounded, color: Colors.white),
              onPressed: () => Navigator.pushNamed(context, '/learning'),
            ),
            IconButton(
              icon: const Icon(Icons.videocam_rounded, color: Colors.white),
              onPressed: () => Navigator.pushNamed(context, '/practice'),
            ),
            IconButton(
              icon: const Icon(Icons.person_rounded, color: Colors.white),
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== Playful & Colourful Widgets =====================

class _WelcomeSection extends StatelessWidget {
  final String userName;
  final int signsLearned;
  final String greeting;

  const _WelcomeSection({required this.userName, required this.signsLearned, required this.greeting});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                '$greeting, $userName! ',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontSize: 34,
                ),
              ).animate().fadeIn().slideX(begin: -0.4),
            ),
            const Text('✨👋').animate(
              onPlay: (controller) => controller.repeat(reverse: true, period: 800.ms),
            ).scale(begin: const Offset(0.7, 0.7), end: const Offset(1.25, 1.25)),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          "You've learned **$signsLearned** signs this week! 🔥",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.yellowAccent,
          ),
        ).animate().fadeIn(delay: 200.ms).shimmer(duration: 1200.ms),
      ],
    );
  }
}

class _DailyChallengeCard extends StatelessWidget {
  final String dailyChallenge;
  final double progress;

  const _DailyChallengeCard({required this.dailyChallenge, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.pink.withOpacity(0.4), blurRadius: 25, offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.emoji_events_rounded, color: Colors.white, size: 36),
              SizedBox(width: 12),
              Text('Daily Challenge', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Master "$dailyChallenge" today!',
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text("${(progress * 100).toInt()}% done — You're crushing it! 💪", style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/learning'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFFF6B6B),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Go Practice Now →', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.92, 0.92));
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _GlassQuickActionCard(
                icon: Icons.school_rounded,
                label: 'Learn',
                color: Colors.purpleAccent,
                onTap: () => Navigator.pushNamed(context, '/learning'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _GlassQuickActionCard(
                icon: Icons.videocam_rounded,
                label: 'Practice',
                color: Colors.cyanAccent,
                onTap: () => Navigator.pushNamed(context, '/practice'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _GlassQuickActionCard(
                icon: Icons.quiz_rounded,
                label: 'Quiz',
                color: Colors.orangeAccent,
                onTap: () => Navigator.pushNamed(context, '/quiz'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _GlassQuickActionCard(
                icon: Icons.bar_chart_rounded,
                label: 'Progress',
                color: Colors.greenAccent,
                onTap: () => Navigator.pushNamed(context, '/profile'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// New Glassmorphic Quick Action Card
class _GlassQuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _GlassQuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),        // semi-transparent
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),   // Glass blur effect
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0.15), Colors.transparent],
                  begin: Alignment.topLeft,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 48, color: color)
                      .animate()
                      .scale(duration: 400.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate().fadeIn().scale(begin: const Offset(0.85, 0.85)).then().shimmer(duration: 800.ms),
    );
  }
}

// Simple Recent Activity section to satisfy reference from HomeScreen.
// Replace the mock loading and sample data with real ProgressService usage as needed.
class _RecentActivitySection extends StatefulWidget {
  final ProgressService progressService;

  const _RecentActivitySection({Key? key, required this.progressService}) : super(key: key);

  @override
  State<_RecentActivitySection> createState() => _RecentActivitySectionState();
}

class _RecentActivitySectionState extends State<_RecentActivitySection> {
  List<String> _activities = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    // Simulated load; replace with actual widget.progressService calls if available.
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _activities = [
        'Practiced "Hello" — 5m',
        'Completed Quiz: Greetings — 8/10',
        'Watched tutorial: Fingerspelling — 12m',
      ];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        if (_loading)
          const Center(child: CircularProgressIndicator(color: Colors.white))
        else if (_activities.isEmpty)
          const Text('No recent activity yet.', style: TextStyle(color: Colors.white70))
        else
          Column(
            children: _activities
                .map(
                  (a) => Card(
                    color: Colors.white12,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.history, color: Colors.white70),
                      title: Text(a, style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}