import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart' as vp;
import '../models/quiz.dart';
import '../services/quiz_service.dart';
import '../constants/app_constants.dart';
import 'quiz_results_screen.dart';

class VideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool loop;

  const VideoPlayer({
    super.key,
    required this.videoUrl,
    this.autoPlay = false,
    this.loop = false,
  });

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  vp.VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = vp.VideoPlayerController.asset(widget.videoUrl);
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        if (widget.autoPlay) {
          _controller!.play();
        }
        if (widget.loop) {
          _controller!.setLooping(true);
        }
      }
    } catch (e) {
      print('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: vp.VideoPlayer(_controller!),
    );
  }
}

class QuizScreen extends StatefulWidget {
  final int numberOfQuestions;

  const QuizScreen({super.key, this.numberOfQuestions = 10});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizService _quizService = QuizService();

  List<QuizQuestion> _questions = const [];
  final List<QuizAnswer> _answers = [];

  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  bool _hasAnswered = false;

  late DateTime _quizStartTime;
  Timer? _timer;
  int _secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    _quizStartTime = DateTime.now();
    _loadQuiz();
    _startTimer();
  }

  void _loadQuiz() {
    setState(() {
      _questions = _quizService.generateQuiz(
        numberOfQuestions: widget.numberOfQuestions,
      );
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  void _selectAnswer(int index) {
    if (_hasAnswered) return;

    setState(() {
      _selectedAnswerIndex = index;
    });
  }

  void _submitAnswer() {
    if (_selectedAnswerIndex == null || _hasAnswered) return;

    final question = _questions[_currentQuestionIndex];
    final isCorrect = _selectedAnswerIndex == question.correctAnswerIndex;

    setState(() {
      _hasAnswered = true;
    });

    _answers.add(
      QuizAnswer(
        questionId: question.id,
        selectedAnswerIndex: _selectedAnswerIndex,
        isCorrect: isCorrect,
        answeredAt: DateTime.now(),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _nextQuestion();
      }
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

  void _skipQuestion() {
    _answers.add(
      QuizAnswer(
        questionId: _questions[_currentQuestionIndex].id,
        selectedAnswerIndex: null,
        isCorrect: false,
        answeredAt: DateTime.now(),
      ),
    );

    _nextQuestion();
  }

  void _finishQuiz() {
    _timer?.cancel();

    final duration = Duration(seconds: _secondsElapsed);
    final result = _quizService.calculateResults(
      questions: _questions,
      answers: _answers,
      timeTaken: duration,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultsScreen(
          result: result,
          questions: _questions,
          answers: _answers,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading quiz...'),
            ],
          ),
        ),
      );
    }

    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildProgressBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGestureDisplay(question),
                  const SizedBox(height: AppConstants.paddingLarge),
                  _buildQuestionText(),
                  const SizedBox(height: AppConstants.paddingLarge),
                  _buildAnswerOptions(question),
                ],
              ),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          _showExitDialog();
        },
      ),
      title: Text(
        'Question ${_currentQuestionIndex + 1}/${_questions.length}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 16,
                color: AppConstants.primaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                _formatTime(_secondsElapsed),
                style: const TextStyle(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: AppConstants.fontSizeMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildProgressBar() {
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: 8,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(_currentQuestionIndex + 1)}/${_questions.length}',
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimary,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}% Complete',
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  color: AppConstants.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              backgroundColor: AppConstants.dividerColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppConstants.primaryColor,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildGestureDisplay(QuizQuestion question) {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: question.videoUrl.isNotEmpty
            ? VideoPlayer(
                videoUrl: question.videoUrl,
                autoPlay: true,
                loop: true,
              )
            : Center(
                child: Text(
                  'No video available',
                  style: TextStyle(color: Colors.white),
                ),
              ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 100.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildQuestionText() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: const Text(
        'What sign is being performed?',
        style: TextStyle(
          fontSize: AppConstants.fontSizeXL,
          fontWeight: FontWeight.bold,
          color: AppConstants.textPrimary,
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildAnswerOptions(QuizQuestion question) {
    return Column(
      children: List.generate(question.options.length, (index) {
        final option = question.options[index];
        final isSelected = _selectedAnswerIndex == index;
        final isCorrect = index == question.correctAnswerIndex;

        Color? backgroundColor;
        Color? borderColor;
        Color? textColor;

        if (_hasAnswered) {
          if (isCorrect) {
            backgroundColor = AppConstants.accentColor.withOpacity(0.1);
            borderColor = AppConstants.accentColor;
            textColor = AppConstants.accentColor;
          } else if (isSelected) {
            backgroundColor = AppConstants.errorColor.withOpacity(0.1);
            borderColor = AppConstants.errorColor;
            textColor = AppConstants.errorColor;
          }
        } else if (isSelected) {
          backgroundColor = AppConstants.primaryColor.withOpacity(0.1);
          borderColor = AppConstants.primaryColor;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _selectAnswer(index),
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            child: Container(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
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
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: backgroundColor ?? AppConstants.backgroundColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: borderColor ?? AppConstants.dividerColor,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + index),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor ?? AppConstants.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeLarge,
                        fontWeight: FontWeight.w500,
                        color: textColor ?? AppConstants.textPrimary,
                      ),
                    ),
                  ),
                  if (_hasAnswered && isCorrect)
                    const Icon(
                      Icons.check_circle,
                      color: AppConstants.accentColor,
                    ),
                  if (_hasAnswered && isSelected && !isCorrect)
                    const Icon(
                      Icons.cancel,
                      color: AppConstants.errorColor,
                    ),
                ],
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: (300 + index * 100).ms)
            .slideX(begin: 0.2, end: 0);
      }),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (!_hasAnswered)
              Expanded(
                child: OutlinedButton(
                  onPressed: _skipQuestion,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Skip'),
                ),
              ),
            if (!_hasAnswered) const SizedBox(width: 12),
            Expanded(
              flex: _hasAnswered ? 1 : 2,
              child: ElevatedButton(
                onPressed: _hasAnswered ? _nextQuestion : _submitAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasAnswered
                      ? AppConstants.accentColor
                      : AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: Text(
                  _hasAnswered
                      ? (_currentQuestionIndex == _questions.length - 1
                          ? 'Finish'
                          : 'Next Question →')
                      : 'Submit Answer',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: AppConstants.fontSizeNormal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Quiz?'),
        content: const Text(
          'Your progress will be lost. Are you sure you want to exit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
