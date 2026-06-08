import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants/app_constants.dart';
import '../services/progress_service.dart';
import '../services/user_service.dart';
import '../widgets/app_logo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = 'Buddy';
  int signsLearnedThisWeek = 12;
  int currentStreak = 7;
  String greeting = 'Hello';
  int level = 1;
  int xp = 0;
  int xpForNextLevel = 100;

  final ProgressService _progressService = ProgressService();
  final UserService _userService = UserService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _openAndRefresh(String route) async {
    await Navigator.pushNamed(context, route);
    if (!mounted) return;
    await _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    await _progressService.init();
    await _userService.init();
    final stats = _progressService.getStats();
    final streakData = await _progressService.recalculateStreakFromActivities();
    await _userService.updateStreakData(
      currentStreak: streakData['currentStreak'] as int,
      longestStreak: streakData['longestStreak'] as int,
      lastActiveDate: streakData['lastActiveDate'] as DateTime?,
    );
    final userProfile = _userService.getUserProfile();
    final profileName = userProfile.name.trim();

    if (!mounted) return;

    setState(() {
      userName = profileName.isEmpty ? 'Buddy' : profileName;
      signsLearnedThisWeek = stats['learnedCount'] as int? ?? 0;
      currentStreak = userProfile.currentStreak;
      level = userProfile.level;
      xp = userProfile.xp;
      xpForNextLevel = userProfile.xpForNextLevel;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(color: AppConstants.primaryColor),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await _loadHomeData();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WelcomeSection(
                      userName: userName,
                      signsLearned: signsLearnedThisWeek,
                      greeting: greeting,
                      streak: currentStreak,
                    ),
                    const SizedBox(height: 32),
                    _DailyChallengeCard(
                      level: level,
                      xp: xp,
                      xpForNextLevel: xpForNextLevel,
                      onStartChallenge: () => _openAndRefresh('/learning'),
                    ),
                    const SizedBox(height: 36),
                    _QuickActionsSection(onOpenRoute: _openAndRefresh),
                    const SizedBox(height: 40),
                    _RecentActivitySection(progressService: _progressService),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAndRefresh('/practice'),
        icon: Icon(Icons.videocam_rounded, size: 28),
        label: Text('Start Video Practice',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.primaryColor,
        elevation: 8,
      ).animate().scale(duration: 400.ms),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppLogoMark(size: 30),
          const SizedBox(width: 10),
          Text(
            'USL Tutor',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: const Color.fromARGB(255, 15, 118, 110),
              fontSize: 24,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.87)),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      color: Theme.of(context).cardColor,
      elevation: 12,
      shape: const AutomaticNotchedShape(
        RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
                icon: Icon(Icons.school_rounded,
                    color: AppConstants.primaryColor, size: 28),
                onPressed: () => _openAndRefresh('/learning')),
            IconButton(
                icon: Icon(Icons.videocam_rounded,
                    color: AppConstants.primaryColor, size: 28),
                onPressed: () => _openAndRefresh('/practice')),
            IconButton(
                icon: Icon(Icons.person_rounded,
                    color: AppConstants.primaryColor, size: 28),
                onPressed: () => _openAndRefresh('/profile')),
          ],
        ),
      ),
    );
  }
}

// ===================== Enhanced Sections =====================

class _WelcomeSection extends StatelessWidget {
  final String userName;
  final int signsLearned;
  final String greeting;
  final int streak;

  const _WelcomeSection({
    required this.userName,
    required this.signsLearned,
    required this.greeting,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$greeting, $userName!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.87),
                  height: 1.1,
                ),
              ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
            ),
            if (streak > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppConstants.warningColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_fire_department,
                        color: AppConstants.warningColor, size: 22),
                    const SizedBox(width: 6),
                    Text(
                      '$streak day streak',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppConstants.warningColor,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Start learning USL today 👋',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _DailyChallengeCard extends StatelessWidget {
  final int level;
  final int xp;
  final int xpForNextLevel;
  final Future<void> Function() onStartChallenge;

  const _DailyChallengeCard({
    required this.level,
    required this.xp,
    required this.xpForNextLevel,
    required this.onStartChallenge,
  });

  @override
  Widget build(BuildContext context) {
    final progress = xpForNextLevel == 0 ? 0.0 : (xp / xpForNextLevel);
    final clampedProgress = progress.clamp(0.0, 1.0);
    final remainingXp = (xpForNextLevel - xp).clamp(0, xpForNextLevel);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryColor.withOpacity(0.95),
            AppConstants.primaryColor.withOpacity(0.85)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
              color: AppConstants.primaryColor.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events_rounded,
                color: Colors.white,
                size: AppConstants.iconSizeLarge,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Daily Challenge',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Reach Level ${level + 1}',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white70),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: clampedProgress,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                  'Level $level • ${(clampedProgress * 100).round()}% complete',
                  style: TextStyle(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStartChallenge,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppConstants.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999)),
                elevation: 0,
              ),
              child: Text('Continue',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  final Future<void> Function(String route) onOpenRoute;

  const _QuickActionsSection({required this.onOpenRoute});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.87)),
        ),
        const SizedBox(
          height: 12,
        ),
        Row(
          children: [
            Expanded(
                child: _SimpleActionCard(
                    icon: Icons.school_rounded,
                    label: 'Learn',
                    color: AppConstants.secondaryColor,
                    route: '/learning',
                    onOpenRoute: onOpenRoute)),
            const SizedBox(width: 12),
            Expanded(
                child: _SimpleActionCard(
                    icon: Icons.videocam_rounded,
                    label: 'Practice',
                    color: AppConstants.errorColor,
                    route: '/practice',
                    onOpenRoute: onOpenRoute)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _SimpleActionCard(
                    icon: Icons.quiz_rounded,
                    label: 'Quiz',
                    color: AppConstants.accentColor,
                    route: '/quiz',
                    onOpenRoute: onOpenRoute)),
            const SizedBox(width: 12),
            Expanded(
                child: _SimpleActionCard(
                    icon: Icons.bar_chart_rounded,
                    label: 'Progress',
                    color: AppConstants.successColor,
                    route: '/profile',
                    onOpenRoute: onOpenRoute)),
          ],
        ),
      ],
    );
  }
}

class _SimpleActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String route;
  final Future<void> Function(String route) onOpenRoute;

  const _SimpleActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
    required this.onOpenRoute,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onOpenRoute(route),
      child: Container(
        height: 116,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          boxShadow: [
            BoxShadow(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.055),
                blurRadius: 10,
                offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.87)),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 450.ms)
          .scale(begin: const Offset(0.95, 0.95)),
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  final ProgressService progressService;

  const _RecentActivitySection({required this.progressService});

  IconData _iconForType(String type) {
    switch (type) {
      case 'mastered':
        return Icons.workspace_premium;
      case 'learned':
        return Icons.check;
      case 'quiz':
        return Icons.quiz;
      case 'practiced':
        return Icons.play_arrow;
      default:
        return Icons.history;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'mastered':
        return AppConstants.accentColor;
      case 'learned':
        return AppConstants.successColor;
      case 'quiz':
        return AppConstants.secondaryColor;
      case 'practiced':
        return AppConstants.primaryColor;
      default:
        return AppConstants.textSecondary;
    }
  }

  String _timeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) {
      final minutes = diff.inMinutes;
      return '$minutes minute${minutes == 1 ? '' : 's'} ago';
    }
    if (diff.inDays < 1) {
      final hours = diff.inHours;
      return '$hours hour${hours == 1 ? '' : 's'} ago';
    }
    final days = diff.inDays;
    return '$days day${days == 1 ? '' : 's'} ago';
  }

  @override
  Widget build(BuildContext context) {
    final activities = progressService.getActivities().take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.87)),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.07),
                  blurRadius: 18,
                  offset: const Offset(0, 8)),
            ],
          ),
          child: activities.isEmpty
              ? Text(
                  'No activity yet. Start learning or practice to see updates here.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )
              : Column(
                  children: [
                    for (int i = 0; i < activities.length; i++) ...[
                      Builder(
                        builder: (context) {
                          final activity = activities[i];
                          final type =
                              (activity['type'] as String? ?? '').trim();
                          final title =
                              (activity['title'] as String? ?? 'Activity')
                                  .trim();
                          final timestamp = activity['timestamp'] as DateTime?;
                          final subtitle = timestamp == null
                              ? 'recently'
                              : _timeAgo(timestamp);

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: _colorForType(type),
                              child: Icon(
                                _iconForType(type),
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              subtitle,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          );
                        },
                      ),
                      if (i != activities.length - 1) const Divider(height: 24),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}
