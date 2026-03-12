import 'dart:math';

import '../models/quiz.dart';
import '../models/gesture.dart';
import 'mock_data_service.dart';

/// Service to generate and manage quiz questions
class QuizService {
  final Random _random = Random();

  /// Generate a quiz with specified number of questions
  List<QuizQuestion> generateQuiz({
    int numberOfQuestions = 10,
    String? category,
  }) {
    // Get available gestures
    List<GestureModel> gestures = category != null
        ? MockDataService.getGesturesByCategory(category)
        : MockDataService.getGestures().toList();

    // Filter out locked gestures
    gestures = gestures.where((g) => !g.isLocked).toList();

    final uniqueGestures = _deduplicateByName(gestures);

    if (uniqueGestures.isEmpty) {
      return [];
    }

    // Shuffle and take requested number
    uniqueGestures.shuffle(_random);
    final selectedGestures = uniqueGestures.take(numberOfQuestions).toList();

    // Generate questions
    return selectedGestures.map((gesture) {
      return _createQuestionFromGesture(gesture, uniqueGestures);
    }).toList();
  }

  /// Create a quiz question from a gesture
  QuizQuestion _createQuestionFromGesture(
    GestureModel targetGesture,
    List<GestureModel> allGestures,
  ) {
    final targetName = _normalizeGestureName(targetGesture.name);

    // Get wrong answers
    final wrongGestures = allGestures
        .where(
          (g) =>
              g.id != targetGesture.id &&
              _normalizeGestureName(g.name) != targetName,
        )
        .toList();

    final wrongOptions = wrongGestures.map((g) => g.name).toSet().toList();
    wrongOptions.shuffle(_random);

    // Create options (3 wrong + 1 correct)
    // Combine and shuffle
    final options = [targetGesture.name, ...wrongOptions.take(3)];
    options.shuffle(_random);

    // Find correct answer index
    final correctIndex = options
        .indexWhere((option) => _normalizeGestureName(option) == targetName);

    return QuizQuestion(
      id: 'q_${targetGesture.id}_${DateTime.now().millisecondsSinceEpoch}',
      gestureId: targetGesture.id,
      gestureName: targetGesture.name,
      videoUrl: targetGesture.videoUrl,
      options: options,
      correctAnswerIndex: correctIndex,
      category: targetGesture.category,
    );
  }

  List<GestureModel> _deduplicateByName(List<GestureModel> gestures) {
    final seenNames = <String>{};
    final uniqueGestures = <GestureModel>[];

    for (final gesture in gestures) {
      final normalizedName = _normalizeGestureName(gesture.name);
      if (seenNames.add(normalizedName)) {
        uniqueGestures.add(gesture);
      }
    }

    return uniqueGestures;
  }

  String _normalizeGestureName(String name) => name.trim().toLowerCase();

  /// Calculate quiz results
  QuizResult calculateResults({
    required List<QuizQuestion> questions,
    required List<QuizAnswer> answers,
    required Duration timeTaken,
  }) {
    int correct = 0;
    int wrong = 0;
    int skipped = 0;
    final Map<String, int> categoryScores = {};

    for (final answer in answers) {
      if (answer.isSkipped) {
        skipped++;
      } else if (answer.isCorrect) {
        correct++;

        // Update category score
        final question = questions.firstWhere((q) => q.id == answer.questionId,
            orElse: () => questions.first);
        categoryScores[question.category] =
            (categoryScores[question.category] ?? 0) + 1;
      } else {
        wrong++;
      }
    }

    return QuizResult(
      totalQuestions: questions.length,
      correctAnswers: correct,
      wrongAnswers: wrong,
      skippedQuestions: skipped,
      categoryScores: categoryScores,
      timeTaken: timeTaken,
    );
  }

  /// Get a quick quiz (5 questions)
  List<QuizQuestion> generateQuickQuiz() {
    return generateQuiz(numberOfQuestions: 5);
  }

  /// Get a standard quiz (10 questions)
  List<QuizQuestion> generateStandardQuiz() {
    return generateQuiz(numberOfQuestions: 10);
  }

  /// Get a category-specific quiz
  List<QuizQuestion> generateCategoryQuiz(String category) {
    return generateQuiz(numberOfQuestions: 5, category: category);
  }
}
