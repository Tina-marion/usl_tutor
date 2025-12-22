import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../utils/constants.dart';

class AchievementBadge extends StatelessWidget {
  final Achievement achievement;

  const AchievementBadge({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.isUnlocked;

    return Container(
      width: 100,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: unlocked
            ? AppConstants.accentColor.withOpacity(0.1)
            : AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(
          color: unlocked
              ? AppConstants.accentColor.withOpacity(0.3)
              : AppConstants.dividerColor,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            achievement.icon,
            style: TextStyle(
              fontSize: 32,
              color: Colors.black.withOpacity(unlocked ? 1.0 : 0.35),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            achievement.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppConstants.fontSizeSmall,
              fontWeight: FontWeight.w600,
              color: unlocked
                  ? AppConstants.textPrimary
                  : AppConstants.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
