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

  // TODO: replace with real data sources
  String userName = 'User';
  final int signsLearnedThisWeek = 15;
  final String dailyChallenge = 'Good Morning';
  final double dailyChallengeProgress = 0.8;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu),
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
          onPressed: () => Navigator.pushNamed(context, '/profile'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          const SizedBox(height: AppConstants.paddingLarge),
          _buildDailyChallengeCard(),
          const SizedBox(height: AppConstants.paddingLarge),
          _buildQuickActionsSection(),
          const SizedBox(height: AppConstants.paddingLarge),
          _buildRecentActivitySection(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AppConstants.welcomeMessage}, $userName! 👋',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
        const SizedBox(height: 8),
        Text(
          "You've learned $signsLearnedThisWeek signs this week",
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

  Widget _buildDailyChallengeCard() {
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
              value: dailyChallengeProgress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(dailyChallengeProgress * 100).toInt()}% complete',
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

  Widget _buildQuickActionsSection() {
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

  Widget _buildRecentActivitySection() {
    final activities = _progressService.getActivities();
    
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
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          child: Column(
            children: List.generate(
              activities.length < 3 ? activities.length : 3,
              (index) {
                final activity = activities[index];
                return Column(
                  children: [
                    _buildActivityItemFromData(activity),
                    if (index < 2) const Divider(height: 1),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItemFromData(Map<String, dynamic> activity) {
    final type = activity['type'] as String;
    late IconData icon;
    late Color iconColor;

    switch (type) {
      case 'mastered':
        icon = Icons.check_circle;
        iconColor = AppConstants.accentColor;
        break;
      case 'learned':
        icon = Icons.lightbulb;
        iconColor = AppConstants.primaryColor;
        break;
      case 'quiz':
        icon = Icons.quiz;
        iconColor = AppConstants.warningColor;
        break;
      case 'practiced':
      default:
        icon = Icons.refresh;
        iconColor = AppConstants.textSecondary;
    }

    final timestamp = activity['timestamp'] as DateTime;
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    String timeAgo;
    if (difference.inDays > 0) {
      timeAgo = '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      timeAgo = '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      timeAgo = '${difference.inMinutes}m ago';
    } else {
      timeAgo = 'Just now';
    }

    return ActivityItem(
      icon: icon,
      iconColor: iconColor,
      title: activity['title'] as String,
      time: timeAgo,
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
          BottomNavigationBarItem(
              icon: Icon(Icons.videocam), label: 'Practice'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Me'),
        ],
      ),
    );
  }
}
