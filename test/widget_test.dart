// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:usl_tutor_app/main.dart';
import 'package:usl_tutor_app/models/quiz.dart';
import 'package:usl_tutor_app/services/quiz_service.dart';

void main() {
  test('Quiz grade thresholds follow A to F scale', () {
    QuizResult buildResult(int correctAnswers) => QuizResult(
          totalQuestions: 10,
          correctAnswers: correctAnswers,
          wrongAnswers: 10 - correctAnswers,
          skippedQuestions: 0,
          categoryScores: const {},
          timeTaken: Duration.zero,
        );

    expect(buildResult(9).grade, 'A');
    expect(buildResult(8).grade, 'B');
    expect(buildResult(7).grade, 'C');
    expect(buildResult(6).grade, 'D');
    expect(buildResult(5).grade, 'E');
    expect(buildResult(4).grade, 'F');
  });

  test('Quiz questions keep a unique correct label for each video', () {
    final questions = QuizService().generateQuiz(numberOfQuestions: 50);

    expect(questions, isNotEmpty);

    for (final question in questions) {
      final normalizedCorrectAnswer = question.correctAnswer.toLowerCase();
      final matchingOptions = question.options
          .where((option) => option.toLowerCase() == normalizedCorrectAnswer)
          .length;

      expect(
        matchingOptions,
        1,
        reason:
            'Question for ${question.videoUrl} has duplicate answer labels matching the correct sign.',
      );
    }
  });

  testWidgets('Splash shows app name and navigates to onboarding',
      (WidgetTester tester) async {
    await tester.pumpWidget(const USLTutorApp());

    expect(find.text('USL Tutor'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 4));

    expect(find.textContaining('Learn Sign Language'), findsOneWidget);
  });
}
