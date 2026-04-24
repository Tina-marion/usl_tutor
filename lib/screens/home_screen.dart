import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants/app_constants.dart';
import '../services/progress_service.dart';

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
  String dailyChallenge = 'Basic Greetings';
  double dailyChallengeProgress = 0.65;

  final ProgressService _progressService = ProgressService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : RefreshIndicator(
              onRefresh: () async {
                await _progressService.init();
                setState(() {});
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
                    _StreakCard(streak: currentStreak),
                    const SizedBox(height: 32),
                    _DailyChallengeCard(
                      dailyChallenge: dailyChallenge,
                      progress: dailyChallengeProgress,
                    ),
                    const SizedBox(height: 36),
                    _QuickActionsSection(),
                    const SizedBox(height: 40),
                    _RecentActivitySection(progressService: _progressService),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/practice'),
        icon: const Icon(Icons.videocam_rounded, size: 28),
        label: const Text('Start Video Practice', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        elevation: 8,
      ).animate().scale(duration: 400.ms),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'USL Tutor',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: Colors.black87,
          fontSize: 24,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.black87),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      color: Colors.white,
      elevation: 12,
      shape: const AutomaticNotchedShape(
        RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: const Icon(Icons.school_rounded, color: Color.fromARGB(255, 43, 14, 41), size: 28), onPressed: () => Navigator.pushNamed(context, '/learning')),
            IconButton(icon: const Icon(Icons.videocam_rounded, color: Color.fromARGB(255, 43, 14, 41), size: 28), onPressed: () => Navigator.pushNamed(context, '/practice')),
            IconButton(icon: const Icon(Icons.person_rounded, color: Color.fromARGB(255, 43, 14, 41), size: 28), onPressed: () => Navigator.pushNamed(context, '/profile')),
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
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                  height: 1.1,
                ),
              ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orange, size: 22),
                  const SizedBox(width: 6),
                  Text(
                    '$streak day streak',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
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
          "You've learned $signsLearned signs this week! 🔥",
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 99, 51, 109),
          ),
        ),
      ],
    );
  }
}

class _StreakCard extends StatelessWidget {
  final int streak;

  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.whatshot_rounded, color: Colors.orange, size: 42),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "You're on a roll!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$streak day learning streak',
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'Keep it up!',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded, color: Color.fromARGB(255, 243, 210, 25), size: 38),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Daily Challenge',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Master "$dailyChallenge" today!',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 22),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 14,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation(Color.fromARGB(255, 248, 110, 17)),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${(progress * 100).toInt()}% completed", style: const TextStyle(color: Colors.grey)),
              const Text("Keep going!", style: TextStyle(color: Color.fromARGB(255, 44, 23, 71), fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/learning'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 44, 28, 71),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                elevation: 3,
              ),
              child: const Text('Start Challenge →', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
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
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 20,),
        Row(
          children: [
            Expanded(child: _SimpleActionCard(icon: Icons.school_rounded, label: 'Learn', color: Colors.blue, route: '/learning')),
            const SizedBox(width: 16),
            Expanded(child: _SimpleActionCard(icon: Icons.videocam_rounded, label: 'Practice', color: const Color.fromARGB(255, 97, 43, 97), route: '/practice')),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _SimpleActionCard(icon: Icons.quiz_rounded, label: 'Quiz', color: Colors.orange, route: '/quiz')),
            const SizedBox(width: 16),
            Expanded(child: _SimpleActionCard(icon: Icons.bar_chart_rounded, label: 'Progress', color: Colors.green, route: '/profile')),
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

  const _SimpleActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        height: 158,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 52, color: color),
            const SizedBox(height: 14),
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.92, 0.92)),
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  final ProgressService progressService;

  const _RecentActivitySection({required this.progressService});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 18, offset: const Offset(0, 8)),
            ],
          ),
          child: const Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.check, color: Colors.white)),
                title: Text('Completed "Hello"', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                subtitle: Text('2 days ago', style: TextStyle(color: Colors.grey)),
              ),
              Divider(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.play_arrow, color: Colors.white)),
                title: Text('Practice Session', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                subtitle: Text('4 days ago', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}