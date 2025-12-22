import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/user_profile.dart';
import '../utils/constants.dart';

class ActivityTimeline extends StatelessWidget {
  final List<LearningActivity> activities;
  final bool showDividers;

  const ActivityTimeline({
    super.key,
    required this.activities,
    this.showDividers = false,
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < activities.length; i++) {
      final item = _buildActivityItem(activities[i])
          .animate()
          .fadeIn(duration: 300.ms, delay: (100 + i * 80).ms)
          .slideY(begin: 0.1, end: 0, duration: 300.ms);
      children.add(item);
      if (showDividers && i < activities.length - 1) {
        children
            .add(const Divider(height: 1, color: AppConstants.dividerColor));
      }
    }

    return Column(children: children);
  }

  Widget _buildActivityItem(LearningActivity activity) {
    final iconData = _getIconForType(activity.type);
    final iconColor = _getColorForType(activity.type);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconData,
              color: iconColor,
              size: 20,
            ),
          ),

          const SizedBox(width: AppConstants.paddingMedium),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeNormal,
                    fontWeight: FontWeight.w500,
                    color: AppConstants.textPrimary,
                  ),
                ),
                if (activity.score != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Score: ${activity.score}%',
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeSmall,
                      color: AppConstants.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  activity.timeAgo,
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeSmall,
                    color: AppConstants.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'learned':
        return Icons.school;
      case 'mastered':
        return Icons.star;
      case 'practiced':
        return Icons.fitness_center;
      case 'quiz':
        return Icons.quiz;
      default:
        return Icons.check_circle;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'learned':
        return AppConstants.primaryColor;
      case 'mastered':
        return AppConstants.warningColor;
      case 'practiced':
        return AppConstants.secondaryColor;
      case 'quiz':
        return AppConstants.accentColor;
      default:
        return AppConstants.textSecondary;
    }
  }
}
