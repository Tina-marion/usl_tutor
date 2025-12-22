import '../models/user_profile.dart';

/// Service to manage user profile and statistics
class UserProfileService {
  // Mock user profile
  static UserProfile getUserProfile() {
    return UserProfile(
      id: 'user_001',
      name: 'John Doe',
      email: 'john.doe@example.com',
      joinedDate: DateTime.now().subtract(const Duration(days: 45)),
      level: 3,
      xp: 450,
      currentStreak: 12,
      longestStreak: 15,
      lastActiveDate: DateTime.now(),
    );
  }

  // Mock user statistics
  static UserStatistics getUserStatistics() {
    return const UserStatistics(
      signsLearned: 45,
      signsMastered: 12,
      totalPracticeTime: 180, // 3 hours
      quizzesTaken: 8,
      averageQuizScore: 87.5,
      perfectQuizzes: 2,
      categoryProgress: {
        'Greetings': 10,
        'Family': 8,
        'Numbers': 10,
        'Food': 7,
        'Colors': 5,
        'Actions': 5,
      },
    );
  }

  // Mock achievements
  static List<Achievement> getAchievements() {
    return const [
      Achievement(
        id: 'first_sign',
        name: 'First Sign',
        description: 'Complete your first gesture',
        icon: '🎯',
        isUnlocked: true,
        unlockedDate: null,
      ),
      Achievement(
        id: 'practice_10',
        name: 'Dedicated Learner',
        description: 'Practice 10 times',
        icon: '📚',
        isUnlocked: true,
        unlockedDate: null,
      ),
      Achievement(
        id: 'perfect_5',
        name: 'Perfect Streak',
        description: '5 perfect signs in a row',
        icon: '⭐',
        isUnlocked: true,
        unlockedDate: null,
      ),
      Achievement(
        id: 'quiz_master',
        name: 'Quiz Master',
        description: 'Pass 5 quizzes',
        icon: '🏆',
        isUnlocked: true,
        unlockedDate: null,
      ),
      Achievement(
        id: 'week_streak',
        name: '7-Day Streak',
        description: 'Practice for 7 days straight',
        icon: '🔥',
        isUnlocked: true,
        unlockedDate: null,
      ),
      Achievement(
        id: 'master_10',
        name: 'Sign Master',
        description: 'Master 10 signs',
        icon: '👑',
        isUnlocked: true,
        unlockedDate: null,
      ),
      Achievement(
        id: 'perfect_quiz',
        name: 'Perfect Score',
        description: 'Get 100% on a quiz',
        icon: '💯',
        isUnlocked: false,
      ),
      Achievement(
        id: 'month_streak',
        name: '30-Day Streak',
        description: 'Practice for 30 days straight',
        icon: '🎖️',
        isUnlocked: false,
      ),
      Achievement(
        id: 'category_master',
        name: 'Category Master',
        description: 'Complete all signs in a category',
        icon: '🌟',
        isUnlocked: false,
      ),
      Achievement(
        id: 'speed_learner',
        name: 'Speed Learner',
        description: 'Learn 5 signs in one day',
        icon: '⚡',
        isUnlocked: false,
      ),
    ];
  }

  // Mock recent activities
  static List<LearningActivity> getRecentActivities() {
    final now = DateTime.now();
    return [
      LearningActivity(
        id: 'act_1',
        type: 'mastered',
        title: '"Hello" - Mastered',
        timestamp: now.subtract(const Duration(hours: 2)),
        gestureName: 'Hello',
      ),
      LearningActivity(
        id: 'act_2',
        type: 'quiz',
        title: 'Quiz completed',
        timestamp: now.subtract(const Duration(hours: 5)),
        score: 85,
      ),
      LearningActivity(
        id: 'act_3',
        type: 'learned',
        title: '"Thank You" - Learned',
        timestamp: now.subtract(const Duration(days: 1)),
        gestureName: 'Thank You',
      ),
      LearningActivity(
        id: 'act_4',
        type: 'practiced',
        title: 'Practice session',
        timestamp: now.subtract(const Duration(days: 1, hours: 3)),
      ),
      LearningActivity(
        id: 'act_5',
        type: 'quiz',
        title: 'Quiz completed',
        timestamp: now.subtract(const Duration(days: 2)),
        score: 90,
      ),
      LearningActivity(
        id: 'act_6',
        type: 'learned',
        title: '"Please" - Learned',
        timestamp: now.subtract(const Duration(days: 2, hours: 5)),
        gestureName: 'Please',
      ),
    ];
  }

  // Mock weekly progress data
  static List<WeeklyProgress> getWeeklyProgress() {
    return const [
      WeeklyProgress(day: 'Mon', signsLearned: 3),
      WeeklyProgress(day: 'Tue', signsLearned: 5),
      WeeklyProgress(day: 'Wed', signsLearned: 2),
      WeeklyProgress(day: 'Thu', signsLearned: 7),
      WeeklyProgress(day: 'Fri', signsLearned: 4),
      WeeklyProgress(day: 'Sat', signsLearned: 6),
      WeeklyProgress(day: 'Sun', signsLearned: 3),
    ];
  }
}
