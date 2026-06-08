import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_constants.dart';
import '../models/quiz.dart';
import '../widgets/app_logo.dart';

class QuizResultsScreen extends StatelessWidget {
  final QuizResult result;
  final List<QuizQuestion> questions;
  final List<QuizAnswer> answers;

  const QuizResultsScreen({
    super.key,
    required this.result,
    required this.questions,
    required this.answers,
  });

  @override
  Widget build(BuildContext context) {
    final percent = result.percentage.round();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogoMark(size: 28),
            const SizedBox(width: 10),
            Text('Quiz Results'),
          ],
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(context, percent),
            const SizedBox(height: AppConstants.paddingLarge),
            _buildCategoryBreakdown(context),
            const SizedBox(height: AppConstants.paddingLarge),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, int percent) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            percent >= 70 ? 'Great Job!' : 'Keep Practicing!',
            style: TextStyle(
              fontSize: AppConstants.fontSizeXXL,
              fontWeight: FontWeight.bold,
              color: percent >= 70
                  ? AppConstants.accentColor
                  : AppConstants.warningColor,
            ),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            '${result.emoji}  Grade: ${result.grade}',
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${result.correctAnswers}/${result.totalQuestions}',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeXL,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'correct',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 10,
              backgroundColor: AppConstants.dividerColor,
              color: percent >= 70
                  ? AppConstants.accentColor
                  : AppConstants.warningColor,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            'Time: ${_formatDuration(result.timeTaken)}',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(BuildContext context) {
    if (result.categoryScores.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Breakdown',
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          ...result.categoryScores.entries.map((entry) {
            final category = entry.key;
            final count = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeNormal,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text('Back'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context, 'retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text('Retry'),
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
