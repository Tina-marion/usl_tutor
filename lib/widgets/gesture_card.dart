import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../models/gesture.dart';

class GestureCard extends StatelessWidget {
  final GestureModel gesture;
  final VoidCallback onTap;

  const GestureCard({
    super.key,
    required this.gesture,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: gesture.isLocked
              ? Border.all(color: AppConstants.dividerColor, width: 1)
              : null,
          boxShadow: gesture.isLocked
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            _buildThumbnail(),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          gesture.name,
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeLarge,
                            fontWeight: FontWeight.bold,
                            color: gesture.isLocked
                                ? AppConstants.textSecondary
                                : AppConstants.textPrimary,
                          ),
                        ),
                      ),
                      _buildStatusIcon(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildDifficultyChip(),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppConstants.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${gesture.estimatedMinutes} min',
                        style: const TextStyle(
                          fontSize: AppConstants.fontSizeSmall,
                          color: AppConstants.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (gesture.isLocked && gesture.prerequisite != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Complete previous signs first',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeSmall,
                        color: AppConstants.warningColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppConstants.paddingSmall),
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: gesture.isLocked
            ? AppConstants.dividerColor
            : AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      ),
      child: Center(
        child: Icon(
          gesture.isLocked ? Icons.lock : Icons.sign_language,
          size: 40,
          color: gesture.isLocked
              ? AppConstants.textSecondary
              : AppConstants.primaryColor,
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    if (gesture.isLocked) {
      return const Icon(
        Icons.lock,
        size: 20,
        color: AppConstants.textSecondary,
      );
    } else if (gesture.isMastered) {
      return const Icon(
        Icons.star,
        size: 20,
        color: AppConstants.warningColor,
      );
    } else if (gesture.isLearned) {
      return const Icon(
        Icons.check_circle,
        size: 20,
        color: AppConstants.accentColor,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildDifficultyChip() {
    Color color;
    switch (gesture.difficulty.toLowerCase()) {
      case 'easy':
        color = AppConstants.accentColor;
        break;
      case 'medium':
        color = AppConstants.warningColor;
        break;
      case 'hard':
        color = AppConstants.errorColor;
        break;
      default:
        color = AppConstants.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        gesture.difficulty,
        style: TextStyle(
          fontSize: AppConstants.fontSizeSmall,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    IconData icon;
    if (gesture.isLocked) {
      icon = Icons.lock;
    } else if (gesture.isLearned) {
      icon = Icons.replay;
    } else {
      icon = Icons.play_arrow;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: gesture.isLocked
            ? AppConstants.dividerColor
            : AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      ),
      child: Icon(
        icon,
        color: gesture.isLocked
            ? AppConstants.textSecondary
            : AppConstants.primaryColor,
        size: 20,
      ),
    );
  }
}
