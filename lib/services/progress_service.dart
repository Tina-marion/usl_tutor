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
}
