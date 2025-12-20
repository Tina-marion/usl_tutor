import 'dart:math';

import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../models/gesture.dart';
import '../models/lesson.dart';
import '../services/mock_data_service.dart';
import '../services/progress_service.dart';

class QuizScreen extends StatefulWidget {
  final Lesson? lesson;

  const QuizScreen({super.key, this.lesson});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _progressService = ProgressService();
  List<GestureModel> _quizGestures = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _hasAnswered = false;
  int? _selectedAnswer;
  List<String> _options = [];

  @override
  void initState() {
    super.initState();
    _progressService.init();
    _loadQuiz();
  }

  void _loadQuiz() {
    final allGestures = widget.lesson != null
        ? MockDataService.getGesturesForLesson(widget.lesson!)
        : MockDataService.getGestures();

    // Take up to 10 random gestures
    final shuffled = List<GestureModel>.from(allGestures)..shuffle();
    _quizGestures = shuffled.take(min(10, shuffled.length)).toList();

    if (_quizGestures.isNotEmpty) {
      _generateOptions();
    }

    setState(() {});
  }

  void _generateOptions() {
    final currentGesture = _quizGestures[_currentIndex];
    final allGestures = MockDataService.getGestures();

    // Get correct answer and 3 wrong answers
    final wrongAnswers = allGestures
        .where((g) => g.id != currentGesture.id)
        .map((g) => g.name)
        .toList()
      ..shuffle();

    _options = [
      currentGesture.name,
      ...wrongAnswers.take(3),
    ]..shuffle();
  }

  void _answerQuestion(int index) {
    if (_hasAnswered) return;

    setState(() {
      _hasAnswered = true;
      _selectedAnswer = index;

      if (_options[index] == _quizGestures[_currentIndex].name) {
        _score++;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (_currentIndex < _quizGestures.length - 1) {
        setState(() {
          _currentIndex++;
          _hasAnswered = false;
          _selectedAnswer = null;
          _generateOptions();
        });
      } else {
        _showResults();
      }
    });
  }

  void _showResults() {
    final percentage = (_score / _quizGestures.length * 100).round();

    // Save quiz score
    if (widget.lesson != null) {
      _progressService.saveQuizScore(widget.lesson!.id, percentage);
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          percentage >= 70 ? 'Great Job! 🎉' : 'Keep Practicing! 💪',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$_score / ${_quizGestures.length}',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: percentage >= 70
                    ? AppConstants.accentColor
                    : AppConstants.warningColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$percentage% Correct',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: AppConstants.dividerColor,
              color: percentage >= 70
                  ? AppConstants.accentColor
                  : AppConstants.warningColor,
              minHeight: 10,
              borderRadius: BorderRadius.circular(999),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Finish'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 0;
                _score = 0;
                _hasAnswered = false;
                _selectedAnswer = null;
                _loadQuiz();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
            ),
            child: const Text('Retry Quiz'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_quizGestures.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(
          child: Text('No gestures available for quiz'),
        ),
      );
    }

    final currentGesture = _quizGestures[_currentIndex];

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.lesson != null ? 'Quiz: ${widget.lesson!.title}' : 'Quiz',
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_currentIndex + 1}/${_quizGestures.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppConstants.textSecondary,
                      ),
                    ),
                    Text(
                      'Score: $_score',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / _quizGestures.length,
                  backgroundColor: AppConstants.dividerColor,
                  color: AppConstants.primaryColor,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(999),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                children: [
                  // Video/Image placeholder
                  Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMedium),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.sign_language,
                            size: 80,
                            color: Colors.white70,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Video: ${currentGesture.name}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: AppConstants.fontSizeLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // Question
                  const Text(
                    'What sign is this?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimary,
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // Answer options
                  ..._options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final isCorrect = option == currentGesture.name;
                    final isSelected = _selectedAnswer == index;

                    Color? backgroundColor;
                    Color? borderColor;

                    if (_hasAnswered) {
                      if (isSelected) {
                        backgroundColor = isCorrect
                            ? AppConstants.accentColor.withOpacity(0.1)
                            : AppConstants.errorColor.withOpacity(0.1);
                        borderColor = isCorrect
                            ? AppConstants.accentColor
                            : AppConstants.errorColor;
                      } else if (isCorrect) {
                        backgroundColor =
                            AppConstants.accentColor.withOpacity(0.1);
                        borderColor = AppConstants.accentColor;
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppConstants.paddingMedium,
                      ),
                      child: InkWell(
                        onTap: () => _answerQuestion(index),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMedium),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(
                            AppConstants.paddingLarge,
                          ),
                          decoration: BoxDecoration(
                            color: backgroundColor ?? Colors.white,
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusMedium,
                            ),
                            border: Border.all(
                              color: borderColor ?? AppConstants.dividerColor,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: AppConstants.fontSizeLarge,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        borderColor ?? AppConstants.textPrimary,
                                  ),
                                ),
                              ),
                              if (_hasAnswered && (isSelected || isCorrect))
                                Icon(
                                  isCorrect ? Icons.check_circle : Icons.cancel,
                                  color: isCorrect
                                      ? AppConstants.accentColor
                                      : AppConstants.errorColor,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
