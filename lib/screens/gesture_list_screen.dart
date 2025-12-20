import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../models/gesture.dart';
import '../models/lesson.dart';
import '../services/mock_data_service.dart';
import '../widgets/gesture_card.dart';
import 'gesture_detail_screen.dart';

class GestureListScreen extends StatelessWidget {
  final Lesson lesson;

  const GestureListScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    final gestures = MockDataService.getGesturesForLesson(lesson);
    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.title),
      ),
      body: _GestureListContent(lesson: lesson, gestures: gestures),
    );
  }
}

class _GestureListContent extends StatelessWidget {
  final Lesson lesson;
  final List<GestureModel> gestures;

  const _GestureListContent({required this.lesson, required this.gestures});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingLarge,
          ),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.06),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(AppConstants.radiusLarge),
              bottomRight: Radius.circular(AppConstants.radiusLarge),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lesson.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppConstants.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '${gestures.length} gestures · ${lesson.learnedSigns}/${lesson.totalSigns} mastered',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: AppConstants.textSecondary),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: lesson.progress,
                backgroundColor: Colors.white,
                color: AppConstants.primaryColor,
                minHeight: 10,
                borderRadius: BorderRadius.circular(999),
              ),
              const SizedBox(height: 8),
              Text(
                _progressLabel(lesson.progress),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppConstants.primaryColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.paddingLarge),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge,
            ),
            child: ListView.separated(
              itemCount: gestures.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final gesture = gestures[index];
                return GestureCard(
                  gesture: gesture,
                  onTap: () => _handleGestureTap(context, gesture),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  String _progressLabel(double progress) {
    final percent = (progress * 100).round();
    if (percent >= 100) return 'Mastered';
    if (percent >= 60) return 'Keep going';
    if (percent >= 30) return 'Getting started';
    return 'Begin this lesson';
  }

  void _handleGestureTap(BuildContext context, GestureModel gesture) {
    if (gesture.isLocked) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Locked gesture'),
          content: const Text('Complete previous gestures to unlock this one.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ],
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GestureDetailScreen(gesture: gesture),
      ),
    );
  }
}
