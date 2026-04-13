import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants/app_constants.dart';
import '../services/progress_service.dart';
import '../services/user_service.dart';
import '../widgets/activity_item.dart';
import '../widgets/quick_action_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _userService = UserService();
  final _progressService = ProgressService();

  String userName = '';
  int signsLearnedThisWeek = 0;
  String dailyChallenge = '';
  double dailyChallengeProgress = 0.0;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _userService.init();
    await _userService.initializeUser();
    await _progressService.init();

    setState(() {
      userName = _userService.getUserProfile().name;

      final activities = _progressService.getActivities();
      signsLearnedThisWeek = activities.where((activity) {
        final timestamp = activity['timestamp'] as DateTime;
        final type = activity['type'] as String?;
        return DateTime.now().difference(timestamp).inDays < 7 &&
            (type == 'learned' || type == 'mastered');
      }).length;

      // Daily challenge logic (unchanged)
      String challengeTitle = AppConstants.dailyChallenge;
      double progressVal = 0.0;
      try {
        final challengeActivity = activities.firstWhere(
          (a) => ['daily_challenge', 'challenge'].contains(a['type']),
        );
        challengeTitle = challengeActivity['title'] as String? ?? challengeTitle;
        final p = challengeActivity['progress'];
        progressVal = (p is num) ? p.toDouble() : double.tryParse(p.toString()) ?? 0.0;
      } catch (_) {}

      dailyChallenge = challengeTitle;
      dailyChallengeProgress = progressVal;
      _isLoading = false;
    });
  }

  void _onBottomNavTap(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 1: Navigator.pushNamed(context, '/learning'); break;
      case 2: Navigator.pushNamed(context, '/practice'); break;
      case 3: Navigator.pushNamed(context, '/profile'); break;
    }
  }

  Future<void> _addTestActivities() async {
    await _progressService.addTestActivities();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Test activities added!')),
    );
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _progressService.init();
                setState(() {});
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WelcomeSection(
                      userName: userName,
                      signsLearned: signsLearnedThisWeek,
                      greeting: greeting,
                    ),
                    const SizedBox(height: 32),
                    _DailyChallengeCard(
                      dailyChallenge: dailyChallenge,
                      progress: dailyChallengeProgress,
                    ),
                    const SizedBox(height: 32),
                    _QuickActionsSection(),
                    const SizedBox(height: 32),
                    _RecentActivitySection(progressService: _progressService),
                    const SizedBox(height: 80), // space for floating button
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/practice'),
        icon: const Icon(Icons.videocam),
        label: const Text('Start Practice'),
        backgroundColor: AppConstants.primaryColor,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
      title: Text(AppConstants.appName, style: const TextStyle(fontWeight: FontWeight.bold)),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: _addTestActivities,
        ),
        IconButton(
          icon: CircleAvatar(
            backgroundColor: AppConstants.primaryColor.withOpacity(0.15),
            child: Icon(Icons.person, color: AppConstants.primaryColor),
          ),
          onPressed: () => Navigator.pushNamed(context, '/profile'),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onBottomNavTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppConstants.primaryColor,
      unselectedItemColor: AppConstants.textSecondary,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Learn'),
        BottomNavigationBarItem(icon: Icon(Icons.videocam), label: 'Practice'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Me'),
      ],
    );
  }
}

// ===================== Enhanced Widgets =====================

class _WelcomeSection extends StatelessWidget {
  final String userName;
  final int signsLearned;
  final String greeting;

  const _WelcomeSection({
    required this.userName,
    required this.signsLearned,
    required this.greeting,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$greeting, $userName! ',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn().slideX(begin: -0.3),
            const Text('👋').animate(
              onPlay: (controller) => controller.repeat(reverse: true),
            ).scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 800.ms),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          "You've learned **$signsLearned** signs this week 🔥",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.w600,
              ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
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
        gradient: AppConstants.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        // Glassmorphism effect
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Text(
                'Daily Challenge',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Learn "$dailyChallenge"',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toInt()}% Complete',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/learning'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppConstants.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Continue Challenge →', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.95, 0.95));
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                icon: Icons.school,
                label: 'Learn',
                color: AppConstants.primaryColor,
                onTap: () => Navigator.pushNamed(context, '/learning'),
              ).animate().fadeIn(delay: 100.ms).scale(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: QuickActionCard(
                icon: Icons.videocam,
                label: 'Practice',
                color: AppConstants.secondaryColor,
                onTap: () => Navigator.pushNamed(context, '/practice'),
              ).animate().fadeIn(delay: 200.ms).scale(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                icon: Icons.quiz,
                label: 'Quiz',
                color: AppConstants.accentColor,
                onTap: () => Navigator.pushNamed(context, '/quiz'),
              ).animate().fadeIn(delay: 300.ms).scale(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: QuickActionCard(
                icon: Icons.bar_chart,
                label: 'Progress',
                color: AppConstants.warningColor,
                onTap: () => Navigator.pushNamed(context, '/profile'),
              ).animate().fadeIn(delay: 400.ms).scale(),
            ),
          ],
        ),
      ],
    );
  }
}

// _RecentActivitySection remains mostly the same but you can add .animate().shimmer() or scale on tap if you want more flair.

class _RecentActivitySection extends StatelessWidget {
  final ProgressService progressService;
  const _RecentActivitySection({required this.progressService});

  @override
  Widget build(BuildContext context) {
    final activities = progressService.getActivities();
    final recent = activities.isNotEmpty ? activities.reversed.take(5).toList() : <dynamic>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (recent.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'No recent activity yet. Start learning to see progress here!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppConstants.textSecondary),
            ),
          )
        else
          Column(
            children: recent.map((a) {
              final title = (a['title'] as String?) ?? (a['type'] as String?) ?? 'Activity';
              final timestamp = a['timestamp'] is DateTime ? a['timestamp'] as DateTime : null;
              final timeText = timestamp != null ? MaterialLocalizations.of(context).formatFullDate(timestamp) : '';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: const Icon(Icons.history, color: AppConstants.primaryColor),
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(timeText, style: TextStyle(color: AppConstants.textSecondary)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // optionally navigate to a detail screen for the activity
                  },
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}