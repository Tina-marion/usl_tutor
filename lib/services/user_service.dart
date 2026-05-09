import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

/// Service for managing user profile data
class UserService {
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userLevelKey = 'user_level';
  static const String _userXpKey = 'user_xp';
  static const String _userJoinedDateKey = 'user_joined_date';
  static const String _userCurrentStreakKey = 'user_current_streak';
  static const String _userLongestStreakKey = 'user_longest_streak';
  static const String _userLastActiveDateKey = 'user_last_active_date';
  static const String _profileCompleteKey = 'profile_complete';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    if (_prefs.containsKey(_userNameKey) &&
        !_prefs.containsKey(_profileCompleteKey)) {
      final savedName = _prefs.getString(_userNameKey)?.trim() ?? '';
      if (savedName.isNotEmpty &&
          savedName != 'USL Learner' &&
          savedName != 'USL Tutor Learner') {
        await _prefs.setBool(_profileCompleteKey, true);
      }
    }
  }

  Future<void> initializeUser({
    String name = 'Buddy',
    String email = 'learner@usl.com',
  }) async {
    if (!_prefs.containsKey(_userNameKey)) {
      await _prefs.setString(_userNameKey, name);
      await _prefs.setString(_userEmailKey, email);
      await _prefs.setInt(_userLevelKey, 1);
      await _prefs.setInt(_userXpKey, 0);
      await _prefs.setInt(_userCurrentStreakKey, 0);
      await _prefs.setInt(_userLongestStreakKey, 0);
      await _prefs.setString(
        _userJoinedDateKey,
        DateTime.now().toIso8601String(),
      );
      await _prefs.setBool(_profileCompleteKey, false);
    }
  }

  UserProfile getUserProfile() {
    final rawName = _prefs.getString(_userNameKey)?.trim() ?? '';
    final name = rawName.isEmpty ||
            rawName == 'USL Learner' ||
            rawName == 'USL Tutor Learner'
        ? 'Buddy'
        : rawName;
    final email = _prefs.getString(_userEmailKey) ?? 'learner@usl.com';
    final level = _prefs.getInt(_userLevelKey) ?? 1;
    final xp = _prefs.getInt(_userXpKey) ?? 0;
    final currentStreak = _prefs.getInt(_userCurrentStreakKey) ?? 0;
    final longestStreak = _prefs.getInt(_userLongestStreakKey) ?? 0;
    final joinedDateStr = _prefs.getString(_userJoinedDateKey);
    final lastActiveDateStr = _prefs.getString(_userLastActiveDateKey);
    final joinedDate =
        joinedDateStr != null ? DateTime.parse(joinedDateStr) : DateTime.now();
    final lastActiveDate =
        lastActiveDateStr != null ? DateTime.tryParse(lastActiveDateStr) : null;

    return UserProfile(
      id: 'user_001',
      name: name,
      email: email,
      joinedDate: joinedDate,
      level: level,
      xp: xp,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastActiveDate: lastActiveDate,
    );
  }

  Future<void> updateUser(UserProfile user) async {
    await _prefs.setString(
      _userNameKey,
      user.name.trim().isEmpty ? 'Buddy' : user.name.trim(),
    );
    await _prefs.setString(_userEmailKey, user.email);
    await _prefs.setInt(_userLevelKey, user.level);
    await _prefs.setInt(_userXpKey, user.xp);
    await _prefs.setInt(_userCurrentStreakKey, user.currentStreak);
    await _prefs.setInt(_userLongestStreakKey, user.longestStreak);
    if (user.lastActiveDate != null) {
      await _prefs.setString(
        _userLastActiveDateKey,
        user.lastActiveDate!.toIso8601String(),
      );
    } else {
      await _prefs.remove(_userLastActiveDateKey);
    }
  }

  Future<void> markProfileComplete() async {
    await _prefs.setBool(_profileCompleteKey, true);
  }

  bool isProfileComplete() {
    return _prefs.getBool(_profileCompleteKey) ?? false;
  }

  Future<void> updateStreakData({
    required int currentStreak,
    required int longestStreak,
    DateTime? lastActiveDate,
  }) async {
    await _prefs.setInt(_userCurrentStreakKey, currentStreak);
    await _prefs.setInt(_userLongestStreakKey, longestStreak);
    if (lastActiveDate != null) {
      await _prefs.setString(
        _userLastActiveDateKey,
        lastActiveDate.toIso8601String(),
      );
    } else {
      await _prefs.remove(_userLastActiveDateKey);
    }
  }

  Future<void> addXp(int amount) async {
    final user = getUserProfile();
    int newXp = user.xp + amount;
    int newLevel = user.level;

    // Level up when XP reaches threshold
    while (newXp >= newLevel * 100) {
      newXp -= newLevel * 100;
      newLevel++;
    }

    await _prefs.setInt(_userXpKey, newXp);
    await _prefs.setInt(_userLevelKey, newLevel);
  }

  Future<void> reset() async {
    await _prefs.remove(_userNameKey);
    await _prefs.remove(_userEmailKey);
    await _prefs.remove(_userLevelKey);
    await _prefs.remove(_userXpKey);
    await _prefs.remove(_userJoinedDateKey);
    await _prefs.remove(_userCurrentStreakKey);
    await _prefs.remove(_userLongestStreakKey);
    await _prefs.remove(_userLastActiveDateKey);
    await _prefs.remove(_profileCompleteKey);
  }
}
