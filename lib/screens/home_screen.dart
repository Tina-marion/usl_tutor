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

    // Fetch dynamic data
    setState(() {
      userName = _userService.getUserProfile().name;
      // Compute signs learned this week from activities if ProgressService doesn't expose a direct method.
      final activities = _progressService.getActivities();
      signsLearnedThisWeek = activities.where((activity) {
        final timestamp = activity['timestamp'] as DateTime;
        final type = activity['type'] as String?;
        final withinWeek = DateTime.now().difference(timestamp).inDays < 7;
        return withinWeek && (type == 'learned' || type == 'mastered');
      }).length;

      // Derive daily challenge from activities (fall back to a sensible default)
      String challengeTitle = AppConstants.dailyChallenge;
      double challengeProgressVal = 0.0;
      try {
        final challengeActivity = activities.firstWhere((activity) {
          final type = activity['type'] as String?;
          return type == 'daily_challenge' || type == 'challenge';
        });
        challengeTitle = challengeActivity['title'] as String? ?? challengeTitle;
        final progressVal = challengeActivity['progress'];
        if (progressVal is num) {
          challengeProgressVal = progressVal.toDouble();
        } else if (progressVal is String) {
          challengeProgressVal = double.tryParse(progressVal) ?? challengeProgressVal;
        }
      } catch (_) {
        // No explicit daily challenge found in activities; keep defaults.
      }

      dailyChallenge = challengeTitle;
      dailyChallengeProgress = challengeProgressVal;
      _isLoading = false;
    });
  }

  void _onBottomNavTap(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 1:
        Navigator.pushNamed(context, '/learning');
        break;
      case 2:
        Navigator.pushNamed(context, '/practice');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
      default:
        break;
    }
  }

  Future<void> _addTestActivities() async {
    await _progressService.addTestActivities();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Test activities added! Scroll down to see them.')),
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
                // Re-initialize the progress service to refresh loaded activities
                await _progressService.init();
                setState(() {});
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WelcomeSection(userName: userName, signsLearned: signsLearnedThisWeek, greeting: greeting),
                    const SizedBox(height: AppConstants.paddingLarge),
                    _DailyChallengeCard(
                      dailyChallenge: dailyChallenge,
                      progress: dailyChallengeProgress,
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),
                    _QuickActionsSection(),
                    const SizedBox(height: AppConstants.paddingLarge),
                    _RecentActivitySection(progressService: _progressService),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        tooltip: 'Menu',
        onPressed: () {},
      ),
      title: const Text(
        AppConstants.appName,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          tooltip: 'Add Test Activities',
          onPressed: _addTestActivities,
        ),
        IconButton(
          icon: CircleAvatar(
            backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
            child: Icon(
              Icons.person,
              color: AppConstants.primaryColor,
            ),
          ),
          tooltip: 'Profile',
          onPressed: () => Navigator.pushNamed(context, '/profile'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: AppConstants.textSecondary,
        selectedFontSize: AppConstants.fontSizeSmall,
        unselectedFontSize: AppConstants.fontSizeSmall,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Learn'),
          BottomNavigationBarItem(icon: Icon(Icons.videocam), label: 'Practice'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Me'),
        ],
      ),
    );
  }
}

// ===================== WIDGETS =====================

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
        Text(
          '$greeting, $userName! 👋',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideX(begin: -0.2, end: 0),
        const SizedBox(height: 8),
        Text(
          "You've learned $signsLearned signs this week",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppConstants.textSecondary,
              ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 100.ms)
            .slideX(begin: -0.2, end: 0),
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
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: AppConstants.primaryGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.emoji_events, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                AppConstants.dailyChallenge,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppConstants.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Learn "$dailyChallenge"',
            style: const TextStyle(
              color: Colors.white,
              fontSize: AppConstants.fontSizeNormal,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ).animate().fadeIn().slideX(),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toInt()}% complete',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: AppConstants.fontSizeSmall,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/learning'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppConstants.primaryColor,
                elevation: 0,
              ),
              child: const Text(
                '${AppConstants.continueButton} →',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 200.ms)
        .slideY(begin: 0.2, end: 0);
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                icon: Icons.school,
                label: 'Learn\nMode',
                color: AppConstants.primaryColor,
                onTap: () => Navigator.pushNamed(context, '/learning'),
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: QuickActionCard(
                icon: Icons.videocam,
                label: 'Practice\nMode',
                color: AppConstants.secondaryColor,
                onTap: () => Navigator.pushNamed(context, '/practice'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                icon: Icons.quiz,
                label: 'Quiz\nMode',
                color: AppConstants.accentColor,
                onTap: () => Navigator.pushNamed(context, '/quiz'),
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: QuickActionCard(
                icon: Icons.bar_chart,
                label: 'Progress',
                color: AppConstants.warningColor,
                onTap: () => Navigator.pushNamed(context, '/profile'),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }
}

class _RecentActivitySection extends StatelessWidget {
  final ProgressService progressService;
  const _RecentActivitySection({required this.progressService});

  static const Map<String, IconData> activityIcons = {
    'mastered': Icons.check_circle,
    'learned': Icons.lightbulb,
    'quiz': Icons.quiz,
    'practiced': Icons.refresh,
  };

  static const Map<String, Color> activityColors = {
    'mastered': AppConstants.accentColor,
    'learned': AppConstants.primaryColor,
    'quiz': AppConstants.warningColor,
    'practiced': AppConstants.textSecondary,
  };

  @override
  Widget build(BuildContext context) {
    final activities = progressService.getActivities();

    if (activities.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: Text(
              'No recent activities yet. Start learning to see your progress here!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppConstants.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length < 3 ? activities.length : 3,
          itemBuilder: (context, index) {
            final activity = activities[index];
            return Column(
              children: [
                ActivityItem(
                  icon: activityIcons[activity['type']] ?? Icons.help,
                  iconColor: activityColors[activity['type']] ?? Colors.grey,
                  title: activity['title'] as String,
                  time: _formatTimeAgo(activity['timestamp'] as DateTime),
                ).animate().fadeIn(duration: 300.ms, delay: (index * 100).ms),
                if (index < activities.length - 1) const Divider(height: 1),
              ],
            );
          },
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }
}