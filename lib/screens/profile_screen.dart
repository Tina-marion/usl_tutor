import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_constants.dart';
import '../models/user.dart';
import '../screens/edit_profile_screen.dart';
import '../services/progress_service.dart';
import '../services/theme_service.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _progressService = ProgressService();
  final _userService = UserService();
  Map<String, dynamic> _stats = {};
  late UserProfile _user;
  bool _isLoading = true;

  Color get _surfaceColor => Theme.of(context).cardColor;
  Color get _primaryTextColor => Theme.of(context).colorScheme.onSurface;
  Color get _secondaryTextColor =>
      Theme.of(context).colorScheme.onSurfaceVariant;
  Color get _shadowColor {
    final alpha = Theme.of(context).brightness == Brightness.dark ? 0.30 : 0.05;
    return Colors.black.withValues(alpha: alpha);
  }

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    await _userService.init();
    await _progressService.init();

    setState(() {
      _user = _userService.getUserProfile();
      _stats = _progressService.getStats();
      _isLoading = false;
    });
  }

  Future<void> _loadStats() async {
    setState(() {
      _user = _userService.getUserProfile();
      _stats = _progressService.getStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: AppConstants.paddingLarge),
                    _buildStatsCards(),
                    const SizedBox(height: AppConstants.paddingLarge),
                    _buildProgressChart(),
                    const SizedBox(height: AppConstants.paddingLarge),
                    _buildAchievements(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: _shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
            child: Icon(
              Icons.person,
              size: 50,
              color: AppConstants.primaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            _user.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _primaryTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _user.email.isNotEmpty ? _user.email : 'No email set',
            style: TextStyle(
              fontSize: 14,
              color: _secondaryTextColor,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Level ${_user.level}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingSmall),
                    Icon(
                      Icons.star,
                      size: 20,
                      color: AppConstants.primaryColor.withOpacity(0.7),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _user.progressToNextLevel,
                    minHeight: 6,
                    backgroundColor: AppConstants.dividerColor,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppConstants.accentColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_user.xp}/${_user.xpForNextLevel} XP',
                  style: TextStyle(
                    fontSize: 12,
                    color: _secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppConstants.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: 18,
                  color: AppConstants.warningColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_stats['dailyStreak'] ?? 0} day streak',
                  style: TextStyle(
                    color: _primaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          // Edit Profile Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _editProfile,
              icon: Icon(Icons.edit),
              label: Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.school,
            value: '${_stats['learnedCount'] ?? 0}',
            label: 'Learned',
            color: AppConstants.accentColor,
          ),
        ),
        const SizedBox(width: AppConstants.paddingMedium),
        Expanded(
          child: _buildStatCard(
            icon: Icons.star,
            value: '${_stats['masteredCount'] ?? 0}',
            label: 'Mastered',
            color: AppConstants.warningColor,
          ),
        ),
        const SizedBox(width: AppConstants.paddingMedium),
        Expanded(
          child: _buildStatCard(
            icon: Icons.access_time,
            value: '${_stats['practiceTime'] ?? 0}m',
            label: 'Practice',
            color: AppConstants.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: _shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: AppConstants.fontSizeSmall,
              color: _secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart() {
    final values = _progressService.getWeeklyProgress();

    // Calculate max Y value dynamically
    final maxValue =
        values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 1;
    final maxY = (maxValue + 1).toDouble();

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: _shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Progress',
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: _primaryTextColor,
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun'
                        ];
                        return Text(
                          days[value.toInt() % 7],
                          style: TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 0 ? (maxY / 4).ceilToDouble() : 1,
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(7, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: values[index].toDouble(),
                        color: AppConstants.primaryColor,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    final achievements = [
      {
        'icon': Icons.emoji_events,
        'title': 'First Steps',
        'desc': 'Learn 5 gestures'
      },
      {
        'icon': Icons.military_tech,
        'title': 'Dedicated',
        'desc': '7 day streak'
      },
      {'icon': Icons.star, 'title': 'Master', 'desc': 'Master 10 gestures'},
    ];

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: _shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Achievements',
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: _primaryTextColor,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          ...achievements.map((achievement) {
            final isUnlocked =
                _checkAchievement(achievement['title'] as String);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isUnlocked
                          ? AppConstants.warningColor.withOpacity(0.1)
                          : AppConstants.dividerColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      achievement['icon'] as IconData,
                      color: isUnlocked
                          ? AppConstants.warningColor
                          : _secondaryTextColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          achievement['title'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isUnlocked
                                ? _primaryTextColor
                                : _secondaryTextColor,
                          ),
                        ),
                        Text(
                          achievement['desc'] as String,
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeSmall,
                            color: _secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isUnlocked)
                    Icon(
                      Icons.check_circle,
                      color: AppConstants.accentColor,
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  bool _checkAchievement(String title) {
    switch (title) {
      case 'First Steps':
        return (_stats['learnedCount'] as int? ?? 0) >= 5;
      case 'Dedicated':
        return (_stats['dailyStreak'] as int? ?? 0) >= 7;
      case 'Master':
        return (_stats['masteredCount'] as int? ?? 0) >= 10;
      default:
        return false;
    }
  }

  void _showSettings() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notifications'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
              ),
            ),
            ListTile(
              leading: Icon(Icons.dark_mode),
              title: Text('Dark Mode'),
              trailing: Consumer<ThemeService>(
                builder: (context, themeService, child) {
                  return Switch(
                    value: themeService.isDarkMode,
                    onChanged: (value) {
                      themeService.setDarkMode(value);
                    },
                  );
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.delete_forever,
                  color: AppConstants.errorColor),
              title: Text('Reset Progress',
                  style: TextStyle(color: AppConstants.errorColor)),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Reset Progress?'),
                    content: Text(
                        'This will delete all your progress. This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.errorColor,
                        ),
                        child: Text('Reset'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && mounted) {
                  await _progressService.resetAllProgress();
                  await _userService.reset();
                  await _loadProfileData();
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Progress reset successfully')),
                    );
                  }
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: AppConstants.errorColor),
              title: Text('Logout',
                  style: TextStyle(color: AppConstants.errorColor)),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Logout?'),
                    content: Text(
                        'You will need to create a new profile when you log back in.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.errorColor,
                        ),
                        child: Text('Logout'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && mounted) {
                  await _userService.reset();
                  await _progressService.resetAllProgress();
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/splash',
                      (route) => false,
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editProfile() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(user: _user),
      ),
    );

    if (result == true && mounted) {
      await _loadProfileData();
    }
  }
}
