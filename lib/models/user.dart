/// Model for a user profile and progress
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final DateTime joinedDate;
  final int level;
  final int xp;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActiveDate;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl = '',
    required this.joinedDate,
    this.level = 1,
    this.xp = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
  });

  // Calculate XP needed for next level
  int get xpForNextLevel => level * 100;

  // Calculate progress to next level (0..1)
  double get progressToNextLevel =>
      xpForNextLevel == 0 ? 0 : xp / xpForNextLevel;

  // Get member duration
  Duration get memberDuration => DateTime.now().difference(joinedDate);

  // Check if streak is active today
  bool get hasStreakToday {
    if (lastActiveDate == null) return false;
    final today = DateTime.now();
    final lastActive = lastActiveDate!;
    return today.year == lastActive.year &&
        today.month == lastActive.month &&
        today.day == lastActive.day;
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    DateTime? joinedDate,
    int? level,
    int? xp,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActiveDate,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      joinedDate: joinedDate ?? this.joinedDate,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }
}

/// Model for user statistics
class UserStatistics {
  final int signsLearned;
  final int signsMastered;
  final int totalPracticeTime; // in minutes
  final int quizzesTaken;
  final double averageQuizScore;
  final int perfectQuizzes;
  final Map<String, int> categoryProgress; // category -> signs learned

  const UserStatistics({
    this.signsLearned = 0,
    this.signsMastered = 0,
    this.totalPracticeTime = 0,
    this.quizzesTaken = 0,
    this.averageQuizScore = 0.0,
    this.perfectQuizzes = 0,
    this.categoryProgress = const {},
  });

  // Calculate total signs available (mock)
  int get totalSignsAvailable => 50;

  // Calculate learning percentage (0..1)
  double get learningPercentage =>
      totalSignsAvailable > 0 ? signsLearned / totalSignsAvailable : 0.0;
}

/// Model for achievement
class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final bool isUnlocked;
  final DateTime? unlockedDate;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    this.unlockedDate,
  });
}

/// Model for learning activity
class LearningActivity {
  final String id;
  final String type; // 'learned', 'practiced', 'quiz', 'mastered'
  final String title;
  final DateTime timestamp;
  final String? gestureName;
  final int? score;

  const LearningActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.timestamp,
    this.gestureName,
    this.score,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Model for weekly progress data point
class WeeklyProgress {
  final String day;
  final int signsLearned;

  const WeeklyProgress({
    required this.day,
    required this.signsLearned,
  });
}
