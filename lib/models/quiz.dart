/// Model for a quiz question
class QuizQuestion {
  final String id;
  final String gestureId;
  final String gestureName;
  final String videoUrl;
  final List<String> options;
  final int correctAnswerIndex;
  final String category;

  const QuizQuestion({
    required this.id,
    required this.gestureId,
    required this.gestureName,
    required this.videoUrl,
    required this.options,
    required this.correctAnswerIndex,
    required this.category,
  });

  String get correctAnswer => options[correctAnswerIndex];
}

/// Model for quiz result
class QuizResult {
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int skippedQuestions;
  final Map<String, int> categoryScores; // category -> correct count
  final Duration timeTaken;

  const QuizResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.skippedQuestions,
    required this.categoryScores,
    required this.timeTaken,
  });

  double get percentage =>
      totalQuestions == 0 ? 0 : (correctAnswers / totalQuestions) * 100;

  String get grade {
    final percent = percentage;
    if (percent >= 90) return 'A+';
    if (percent >= 85) return 'A';
    if (percent >= 80) return 'B+';
    if (percent >= 75) return 'B';
    if (percent >= 70) return 'C+';
    if (percent >= 65) return 'C';
    if (percent >= 60) return 'D';
    return 'F';
  }

  String get emoji {
    final percent = percentage;
    if (percent >= 90) return '🏆';
    if (percent >= 80) return '🌟';
    if (percent >= 70) return '😊';
    if (percent >= 60) return '👍';
    return '📚';
  }
}

/// Model for tracking user's answer
class QuizAnswer {
  final String questionId;
  final int? selectedAnswerIndex;
  final bool isCorrect;
  final DateTime answeredAt;

  const QuizAnswer({
    required this.questionId,
    required this.selectedAnswerIndex,
    required this.isCorrect,
    required this.answeredAt,
  });

  bool get isSkipped => selectedAnswerIndex == null;
}
