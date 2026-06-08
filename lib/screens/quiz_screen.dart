import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart' as vp;

import '../constants/app_constants.dart';
import '../models/quiz.dart';
import '../services/quiz_service.dart';
import '../widgets/app_logo.dart';
import 'quiz_results_screen.dart';

class QuizScreen extends StatefulWidget {
  final int numberOfQuestions;

  const QuizScreen({super.key, this.numberOfQuestions = 10});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizService _quizService = QuizService();

  List<QuizQuestion> _questions = [];
  final List<QuizAnswer> _answers = [];

  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  bool _hasAnswered = false;

  Timer? _timer;
  int _secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    _questions = _quizService.generateQuiz(
      numberOfQuestions: widget.numberOfQuestions,
    );
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _secondsElapsed++);
    });
  }

  void _selectAnswer(int index) {
    if (_hasAnswered) return;
    setState(() => _selectedAnswerIndex = index);
  }

  void _submitAnswer() {
    if (_selectedAnswerIndex == null) return;

    final question = _questions[_currentQuestionIndex];
    final isCorrect = _selectedAnswerIndex == question.correctAnswerIndex;

    setState(() => _hasAnswered = true);

    _answers.add(
      QuizAnswer(
        questionId: question.id,
        selectedAnswerIndex: _selectedAnswerIndex,
        isCorrect: isCorrect,
        answeredAt: DateTime.now(),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = null;
        _hasAnswered = false;
      });
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    _timer?.cancel();

    final result = _quizService.calculateResults(
      questions: _questions,
      answers: _answers,
      timeTaken: Duration(seconds: _secondsElapsed),
    );

    // Show results and handle a possible 'retry' response to restart the quiz
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizResultsScreen(
          result: result,
          questions: _questions,
          answers: _answers,
        ),
      ),
    ).then((res) {
      if (res == 'retry' && mounted) {
        _restartQuiz();
      }
    });
  }

  void _restartQuiz() {
    setState(() {
      _secondsElapsed = 0;
      _currentQuestionIndex = 0;
      _selectedAnswerIndex = null;
      _hasAnswered = false;
      _answers.clear();
      _questions = _quizService.generateQuiz(
        numberOfQuestions: widget.numberOfQuestions,
      );
      _timer?.cancel();
      _startTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // SCROLLABLE CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildVideo(question),
                    const SizedBox(height: 20),
                    _buildQuestionCard(),
                    const SizedBox(height: 20),
                    _buildAnswers(question),
                  ],
                ),
              ),
            ),

            // FIXED BUTTON
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildButton(),
            ),
          ],
        ),
      ),
    );
  }

  // HEADER
  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLogoMark(size: 32),
            const SizedBox(width: 10),
            Text(
              "Quiz Time 🎯",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "Question ${_currentQuestionIndex + 1}/${_questions.length}",
          style:
              TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  // VIDEO
  Widget _buildVideo(QuizQuestion question) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: VideoPlayerWidget(
          key: ValueKey(question.videoUrl),
          videoUrl: question.videoUrl,
        ),
      ),
    );
  }

  // QUESTION CARD
  Widget _buildQuestionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        "What sign is being performed?",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ANSWERS
  Widget _buildAnswers(QuizQuestion question) {
    return Column(
      children: List.generate(question.options.length, (index) {
        final option = question.options[index];
        final isSelected = _selectedAnswerIndex == index;
        final isCorrect = index == question.correctAnswerIndex;

        Color border = Theme.of(context).dividerColor;
        Color bg = Theme.of(context).cardColor;

        if (_hasAnswered) {
          if (isCorrect) {
            border = Colors.green;
            bg = Colors.green.withValues(alpha: 0.18);
          } else if (isSelected) {
            border = Colors.red;
            bg = Colors.red.withValues(alpha: 0.16);
          }
        } else if (isSelected) {
          border = Colors.purple;
          bg = Colors.purple.withValues(alpha: 0.16);
        }

        return GestureDetector(
          onTap: () => _selectAnswer(index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border, width: 1.5),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: border,
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                if (_hasAnswered && isCorrect)
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                if (_hasAnswered && isSelected && !isCorrect)
                  const Icon(Icons.cancel, color: Colors.red, size: 20),
              ],
            ),
          ),
        );
      }),
    );
  }

  // BUTTON
  Widget _buildButton() {
    return ElevatedButton(
      onPressed: _hasAnswered ? _nextQuestion : _submitAnswer,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstants.primaryColor,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        _hasAnswered ? "Next →" : "Submit",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: _hasAnswered ? Colors.yellow : Colors.white,
        ),
      ),
    );
  }
}

// VIDEO PLAYER WIDGET
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  vp.VideoPlayerController? _controller;
  ChewieController? _chewieController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _loadVideo();
    }
  }

  Future<void> _loadVideo() async {
    _chewieController?.dispose();
    _chewieController = null;
    await _controller?.dispose();
    _controller = null;
    _errorMessage = null;

    final controller = vp.VideoPlayerController.asset(widget.videoUrl);
    _controller = controller;

    try {
      await controller.initialize();
      if (!mounted || _controller != controller) return;

      _chewieController = ChewieController(
        videoPlayerController: controller,
        autoInitialize: true,
        autoPlay: true,
        looping: true,
        aspectRatio: controller.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Error loading video',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      );

      if (mounted) setState(() {});
    } catch (_) {
      if (mounted && _controller == controller) {
        setState(() {
          _errorMessage = 'Unable to load quiz video.';
        });
      }
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_chewieController != null) {
      return Chewie(controller: _chewieController!);
    }

    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: vp.VideoPlayer(_controller!),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exit Quiz?'),
        content: Text(
          'Your progress will be lost. Are you sure you want to exit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Exit'),
          ),
        ],
      ),
    );
  }
}
