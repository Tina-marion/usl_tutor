import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:camera/camera.dart';
import '../models/gesture.dart';
import '../services/mock_data_service.dart';
import '../services/mock_recognition_service.dart';
import '../constants/app_constants.dart';
import '../widgets/recognition_feedback_dialog.dart';

class PracticeMockScreen extends StatefulWidget {
  final GestureModel? initialGesture;

  const PracticeMockScreen({super.key, this.initialGesture});

  @override
  State<PracticeMockScreen> createState() => _PracticeMockScreenState();
}

class _PracticeMockScreenState extends State<PracticeMockScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isRecording = false;
  bool _isProcessing = false;

  late GestureModel _currentGesture;
  final MockRecognitionService _recognitionService = MockRecognitionService();

  int _attempts = 0;
  double _bestScore = 0.0;
  int _countdown = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _currentGesture = widget.initialGesture ?? _getRandomGesture();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _isCameraInitialized = true;
        });
        return;
      }

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  GestureModel _getRandomGesture() {
    final gestures =
        MockDataService.getGestures().where((g) => !g.isLocked).toList();
    gestures.shuffle();
    return gestures.first;
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _countdown = 3;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        _processGesture();
      }
    });
  }

  void _stopRecording() {
    _countdownTimer?.cancel();
    setState(() {
      _isRecording = false;
      _countdown = 0;
    });
  }

  Future<void> _processGesture() async {
    setState(() {
      _isProcessing = true;
      _isRecording = false;
    });

    final result = await _recognitionService.recognizeGesture(
      targetGesture: _currentGesture.name,
    );

    setState(() {
      _attempts++;
      if (result.isCorrect && result.confidence > _bestScore) {
        _bestScore = result.confidence;
      }
      _isProcessing = false;
    });

    if (mounted) {
      _showFeedbackDialog(result);
    }
  }

  void _showFeedbackDialog(RecognitionResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RecognitionFeedbackDialog(
        result: result,
        onTryAgain: () {
          Navigator.pop(context);
        },
        onNextSign: () {
          Navigator.pop(context);
          _loadNextGesture();
        },
      ),
    );
  }

  void _loadNextGesture() {
    setState(() {
      _currentGesture = _getRandomGesture();
      _attempts = 0;
      _bestScore = 0.0;
    });
  }

  void _showHint() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: AppConstants.warningColor,
            ),
            const SizedBox(width: 8),
            const Text('Hint'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentGesture.description,
              style: const TextStyle(
                fontSize: AppConstants.fontSizeNormal,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Key steps:',
              style: TextStyle(
                fontSize: AppConstants.fontSizeMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...(_currentGesture.instructions.take(2).map((instruction) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(instruction)),
                  ],
                ),
              );
            })),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            _buildCameraView(),
            _buildTopBar(),
            _buildTargetInfo(),
            if (_countdown > 0 || _isProcessing) _buildCenterOverlay(),
            if (!_isRecording && !_isProcessing) _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    if (!_isCameraInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (_cameraController == null) {
      return Container(
        color: Colors.grey[900],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.videocam_off,
                size: 64,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Camera not available',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: AppConstants.fontSizeLarge,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Using mock recognition',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: AppConstants.fontSizeMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: CameraPreview(_cameraController!),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            Text(
              'Practice Mode',
              style: const TextStyle(
                color: Colors.white,
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white),
              onPressed: _showHint,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildTargetInfo() {
    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppConstants.primaryColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.sports_score,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Target Sign:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppConstants.fontSizeMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _currentGesture.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('Attempts', _attempts.toString()),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildStatItem(
                  'Best',
                  _bestScore > 0 ? '${(_bestScore * 100).round()}%' : '-',
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 100.ms)
        .slideY(begin: -0.3, end: 0);
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: AppConstants.fontSizeLarge,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: AppConstants.fontSizeSmall,
          ),
        ),
      ],
    );
  }

  Widget _buildCenterOverlay() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: _isProcessing
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Analyzing...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppConstants.fontSizeXL,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 1500.ms, color: Colors.white24)
            : Text(
                _countdown.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                ),
              )
                .animate()
                .scale(
                    duration: 500.ms,
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.2, 1.2))
                .then()
                .fadeOut(duration: 200.ms),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          children: [
            Text(
              'Position your hand and tap record',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: AppConstants.fontSizeNormal,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: Icons.skip_next,
                  label: 'Skip',
                  onPressed: _loadNextGesture,
                ),
                GestureDetector(
                  onTap: _startRecording,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppConstants.errorColor,
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppConstants.errorColor.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.fiber_manual_record,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .scale(
                        duration: 1000.ms,
                        begin: const Offset(1, 1),
                        end: const Offset(1.1, 1.1))
                    .then()
                    .scale(
                        duration: 1000.ms,
                        begin: const Offset(1.1, 1.1),
                        end: const Offset(1, 1)),
                _buildControlButton(
                  icon: Icons.lightbulb_outline,
                  label: 'Hint',
                  onPressed: _showHint,
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: 200.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: AppConstants.fontSizeSmall,
          ),
        ),
      ],
    );
  }
}
