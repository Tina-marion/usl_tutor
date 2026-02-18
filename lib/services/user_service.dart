import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

/// Service for managing user profile data
class UserService {
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userLevelKey = 'user_level';
  static const String _userXpKey = 'user_xp';
  static const String _userJoinedDateKey = 'user_joined_date';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> initializeUser({
    String name = 'USL Learner',
    String email = 'learner@usl.com',
  }) async {
    if (!_prefs.containsKey(_userNameKey)) {
      await _prefs.setString(_userNameKey, name);
      await _prefs.setString(_userEmailKey, email);
      await _prefs.setInt(_userLevelKey, 1);
      await _prefs.setInt(_userXpKey, 0);
      await _prefs.setString(
        _userJoinedDateKey,
        DateTime.now().toIso8601String(),
      );
    }
  }

  UserProfile getUserProfile() {
    final name = _prefs.getString(_userNameKey) ?? 'USL Learner';
    final email = _prefs.getString(_userEmailKey) ?? 'learner@usl.com';
    final level = _prefs.getInt(_userLevelKey) ?? 1;
    final xp = _prefs.getInt(_userXpKey) ?? 0;
    final joinedDateStr = _prefs.getString(_userJoinedDateKey);
    final joinedDate =
        joinedDateStr != null ? DateTime.parse(joinedDateStr) : DateTime.now();

    return UserProfile(
      id: 'user_001',
      name: name,
      email: email,
      joinedDate: joinedDate,
      level: level,
      xp: xp,
      currentStreak: 0,
      longestStreak: 0,
      lastActiveDate: null,
    );
  }

  Future<void> updateUser(UserProfile user) async {
    await _prefs.setString(_userNameKey, user.name);
    await _prefs.setString(_userEmailKey, user.email);
    await _prefs.setInt(_userLevelKey, user.level);
    await _prefs.setInt(_userXpKey, user.xp);
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
  }
}
