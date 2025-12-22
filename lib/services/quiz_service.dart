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
        : MockDataService.getGestures();

    // Filter out locked gestures
    gestures = gestures.where((g) => !g.isLocked).toList();

    if (gestures.isEmpty) {
      return [];
    }

    // Shuffle and take requested number
    gestures.shuffle(_random);
    final selectedGestures = gestures.take(numberOfQuestions).toList();

    // Generate questions
    return selectedGestures.map((gesture) {
      return _createQuestionFromGesture(gesture, gestures);
    }).toList();
  }

  /// Create a quiz question from a gesture
  QuizQuestion _createQuestionFromGesture(
    GestureModel targetGesture,
    List<GestureModel> allGestures,
  ) {
    // Get wrong answers
    final wrongGestures =
        allGestures.where((g) => g.id != targetGesture.id).toList();
    wrongGestures.shuffle(_random);

    // Create options (3 wrong + 1 correct)
    final wrongOptions = wrongGestures.take(3).map((g) => g.name).toList();

    // Combine and shuffle
    final options = [targetGesture.name, ...wrongOptions];
    options.shuffle(_random);

    // Find correct answer index
    final correctIndex = options.indexOf(targetGesture.name);

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
