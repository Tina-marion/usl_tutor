import 'package:shared_preferences/shared_preferences.dart';

/// Service for persisting user progress, favorites, and stats
class ProgressService {
  static const String _learnedGesturesKey = 'learned_gestures';
  static const String _masteredGesturesKey = 'mastered_gestures';
  static const String _favoriteGesturesKey = 'favorite_gestures';
  static const String _totalPracticeTimeKey = 'total_practice_time';
  static const String _dailyStreakKey = 'daily_streak';
  static const String _lastPracticeDateKey = 'last_practice_date';
  static const String _quizScoresKey = 'quiz_scores';
  static const String _activitiesKey = 'activities';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Learned Gestures
  Future<void> markGestureAsLearned(String gestureId) async {
    final learned = getLearnedGestures();
    if (!learned.contains(gestureId)) {
      learned.add(gestureId);
      await _prefs.setStringList(_learnedGesturesKey, learned);
      // Log activity
      await addActivity(
        type: 'learned',
        title: '$gestureId - Learned',
        gestureName: gestureId,
      );
    }
  }

  Future<void> unmarkGestureAsLearned(String gestureId) async {
    final learned = getLearnedGestures();
    learned.remove(gestureId);
    await _prefs.setStringList(_learnedGesturesKey, learned);
  }

  List<String> getLearnedGestures() {
    return _prefs.getStringList(_learnedGesturesKey) ?? [];
  }

  bool isGestureLearned(String gestureId) {
    return getLearnedGestures().contains(gestureId);
  }

  // Mastered Gestures
  Future<void> markGestureAsMastered(String gestureId) async {
    final mastered = getMasteredGestures();
    if (!mastered.contains(gestureId)) {
      mastered.add(gestureId);
      await _prefs.setStringList(_masteredGesturesKey, mastered);
      // Log activity
      await addActivity(
        type: 'mastered',
        title: '$gestureId - Mastered',
        gestureName: gestureId,
      );
    }
    await markGestureAsLearned(gestureId);
  }

  List<String> getMasteredGestures() {
    return _prefs.getStringList(_masteredGesturesKey) ?? [];
  }

  bool isGestureMastered(String gestureId) {
    return getMasteredGestures().contains(gestureId);
  }

  // Favorites
  Future<void> toggleFavorite(String gestureId) async {
    final favorites = getFavorites();
    if (favorites.contains(gestureId)) {
      favorites.remove(gestureId);
    } else {
      favorites.add(gestureId);
    }
    await _prefs.setStringList(_favoriteGesturesKey, favorites);
  }

  List<String> getFavorites() {
    return _prefs.getStringList(_favoriteGesturesKey) ?? [];
  }

  bool isFavorite(String gestureId) {
    return getFavorites().contains(gestureId);
  }

  // Practice Time
  Future<void> addPracticeTime(int minutes) async {
    final total = getTotalPracticeTime();
    await _prefs.setInt(_totalPracticeTimeKey, total + minutes);
    // Log activity
    await addActivity(
      type: 'practiced',
      title: 'Practiced for $minutes minutes',
    );
    await updateDailyStreak();
  }

  int getTotalPracticeTime() {
    return _prefs.getInt(_totalPracticeTimeKey) ?? 0;
  }

  // Daily Streak
  Future<void> updateDailyStreak() async {
    final today = DateTime.now();
    final lastPractice = getLastPracticeDate();

    if (lastPractice == null) {
      await _prefs.setInt(_dailyStreakKey, 1);
    } else {
      final difference = today.difference(lastPractice).inDays;
      if (difference == 0) {
        // Same day, no change
      } else if (difference == 1) {
        // Next day, increment streak
        final streak = getDailyStreak();
        await _prefs.setInt(_dailyStreakKey, streak + 1);
      } else {
        // Streak broken, reset
        await _prefs.setInt(_dailyStreakKey, 1);
      }
    }

    await _prefs.setString(
      _lastPracticeDateKey,
      today.toIso8601String(),
    );
  }

  int getDailyStreak() {
    return _prefs.getInt(_dailyStreakKey) ?? 0;
  }

  DateTime? getLastPracticeDate() {
    final dateStr = _prefs.getString(_lastPracticeDateKey);
    return dateStr != null ? DateTime.parse(dateStr) : null;
  }

  // Quiz Scores
  Future<void> saveQuizScore(String lessonId, int score) async {
    final scores = getQuizScores();
    scores[lessonId] = score;
    await _prefs.setString(_quizScoresKey, _encodeMap(scores));
    // Log activity
    await addActivity(
      type: 'quiz',
      title: '$lessonId Quiz - Score: $score%',
      score: score,
    );
  }

  Map<String, int> getQuizScores() {
    final encoded = _prefs.getString(_quizScoresKey);
    if (encoded == null) return {};
    return _decodeMap(encoded);
  }

  int? getQuizScore(String lessonId) {
    return getQuizScores()[lessonId];
  }

  // Helper methods for encoding/decoding map
  String _encodeMap(Map<String, int> map) {
    return map.entries.map((e) => '${e.key}:${e.value}').join(',');
  }

  Map<String, int> _decodeMap(String encoded) {
    if (encoded.isEmpty) return {};
    final map = <String, int>{};
    for (final entry in encoded.split(',')) {
      final parts = entry.split(':');
      if (parts.length == 2) {
        map[parts[0]] = int.tryParse(parts[1]) ?? 0;
      }
    }
    return map;
  }

  // Stats
  Map<String, dynamic> getStats() {
    return {
      'learnedCount': getLearnedGestures().length,
      'masteredCount': getMasteredGestures().length,
      'favoritesCount': getFavorites().length,
      'practiceTime': getTotalPracticeTime(),
      'dailyStreak': getDailyStreak(),
      'quizScores': getQuizScores(),
    };
  }

  // Reset (for testing or user request)
  Future<void> resetAllProgress() async {
    await _prefs.clear();
  }

  // Activity tracking
  Future<void> addActivity({
    required String type, // 'learned', 'mastered', 'practiced', 'quiz'
    required String title,
    String? gestureName,
    int? score,
  }) async {
    final activities = getActivities();
    activities.insert(
      0,
      {
        'type': type,
        'title': title,
        'gestureName': gestureName,
        'score': score,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    // Keep only last 50 activities
    if (activities.length > 50) {
      activities.removeRange(50, activities.length);
    }
    await _prefs.setStringList(
      _activitiesKey,
      activities.map((a) => _encodeActivity(a)).toList(),
    );
  }

  List<Map<String, dynamic>> getActivities() {
    final encoded = _prefs.getStringList(_activitiesKey) ?? [];
    return encoded.map((e) => _decodeActivity(e)).toList();
  }

  String _encodeActivity(Map<String, dynamic> activity) {
    final parts = [
      activity['type'] ?? '',
      activity['title'] ?? '',
      activity['gestureName'] ?? '',
      activity['score']?.toString() ?? '',
      activity['timestamp'] ?? '',
    ];
    return parts.join('|');
  }

  Map<String, dynamic> _decodeActivity(String encoded) {
    final parts = encoded.split('|');
    return {
      'type': parts[0],
      'title': parts[1],
      'gestureName': parts[2].isEmpty ? null : parts[2],
      'score': parts[3].isEmpty ? null : int.tryParse(parts[3]),
      'timestamp': DateTime.parse(parts[4]),
    };
  }

  // Test/Demo method
  Future<void> addTestActivities() async {
    final now = DateTime.now();
    await addActivityDirect(
      type: 'mastered',
      title: '"Hello" - Mastered',
      timestamp: now.subtract(const Duration(hours: 2)),
    );
    await addActivityDirect(
      type: 'quiz',
      title: 'Quiz: Common Phrases - 85%',
      score: 85,
      timestamp: now.subtract(const Duration(hours: 5)),
    );
    await addActivityDirect(
      type: 'learned',
      title: '"Thank You" - Learned',
      timestamp: now.subtract(const Duration(days: 1)),
    );
  }

  Future<void> addActivityDirect({
    required String type,
    required String title,
    String? gestureName,
    int? score,
    required DateTime timestamp,
  }) async {
    final activities = getActivities();
    activities.insert(
      0,
      {
        'type': type,
        'title': title,
        'gestureName': gestureName,
        'score': score,
        'timestamp': timestamp.toIso8601String(),
      },
    );
    if (activities.length > 50) {
      activities.removeRange(50, activities.length);
    }
    await _prefs.setStringList(
      _activitiesKey,
      activities.map((a) => _encodeActivity(a)).toList(),
    );
  }

  // Weekly progress - return count of gestures learned per day of week
  List<int> getWeeklyProgress() {
    final activities = getActivities();
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    // Initialize with 0 for each day (Mon-Sun)
    final dailyProgress = <int>[0, 0, 0, 0, 0, 0, 0];
    
    // Count learning activities per day
    for (final activity in activities) {
      final timestamp = activity['timestamp'] as DateTime;
      
      // Only count activities from the last 7 days
      if (timestamp.isAfter(weekAgo) && timestamp.isBefore(now)) {
        // Get day of week (0 = Monday, 6 = Sunday)
        final dayOfWeek = timestamp.weekday - 1;
        
        // Count learned, mastered, and practiced activities
        final type = activity['type'] as String;
        if (type == 'learned' || type == 'mastered' || type == 'practiced') {
          dailyProgress[dayOfWeek]++;
        }
      }
    }
    
    return dailyProgress;
  }
}
