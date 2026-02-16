import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../models/gesture.dart';
import '../services/inference_service.dart';
import '../services/progress_service.dart';

class PracticeScreen extends StatefulWidget {
  final GestureModel? gesture;

  const PracticeScreen({super.key, this.gesture});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isRecording = false;
  bool _isUploading = false;
  int _countdown = 0;
  Timer? _countdownTimer;
  String? _feedback;
  String? _translation;
  final _progressService = ProgressService();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _progressService.init();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _feedback = 'No camera available';
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
        _feedback = 'Camera error: $e';
      });
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  void _startPractice() {
    setState(() {
      _countdown = 3;
      _feedback = null;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        _startRecording();
      }
    });
  }

  void _startRecording() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      setState(() {
        _feedback = 'Camera not ready';
      });
      return;
    }

    setState(() {
      _isRecording = true;
      _countdown = 0;
      _translation = null;
    });

    _cameraController!
        .startVideoRecording()
        .catchError((e) => setState(() => _feedback = 'Record error: $e'));
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    setState(() {
      _isRecording = false;
    });

    try {
      final file = await _cameraController!.stopVideoRecording();
      final localFile = File(file.path);

      setState(() {
        _isUploading = true;
        _feedback = 'Uploading for translation...';
      });

      final translation = await InferenceService.translateVideo(localFile);
      await _progressService.addPracticeTime(1);

      setState(() {
        _translation = translation;
        _feedback = 'Translation: $translation';
      });
    } catch (e) {
      setState(() {
        _feedback = 'Processing error: $e';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        _showResultDialog();
      }
    }
  }

  void _showResultDialog() {
    final bool hasTranslation =
        _translation != null && _translation!.isNotEmpty;
    final String gestureExpected = widget.gesture?.name ?? 'sign';

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              hasTranslation ? Icons.check_circle : Icons.info,
              color: hasTranslation
                  ? AppConstants.successColor
                  : AppConstants.accentColor,
            ),
            const SizedBox(width: 8),
            const Text('Practice Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.gesture != null) ...[
              Text(
                'Expected: $gestureExpected',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (hasTranslation) ...[
              const Text(
                'You signed:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _translation!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (widget.gesture != null)
                _translation!.toLowerCase() == gestureExpected.toLowerCase()
                    ? Row(
                        children: [
                          Icon(Icons.star, color: AppConstants.successColor),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Perfect match! Great job!',
                              style: TextStyle(
                                color: AppConstants.successColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: AppConstants.warningColor),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Keep practicing to improve!',
                              style: TextStyle(
                                color: AppConstants.warningColor,
                              ),
                            ),
                          ),
                        ],
                      ),
            ] else ...[
              const Text(
                'Could not detect sign. Please try again with:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Text('• Better lighting'),
              const Text('• Clear hand movements'),
              const Text('• Proper camera position'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Practice Again'),
          ),
          if (widget.gesture != null && hasTranslation)
            ElevatedButton(
              onPressed: () async {
                await _progressService.markGestureAsLearned(widget.gesture!.id);
                if (mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
              ),
              child: const Text('Mark as Learned'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.gesture != null
              ? 'Practice: ${widget.gesture!.name}'
              : 'Practice Mode',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Camera preview
                if (_isCameraInitialized && _cameraController != null)
                  SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _cameraController!.value.previewSize!.height,
                        height: _cameraController!.value.previewSize!.width,
                        child: CameraPreview(_cameraController!),
                      ),
                    ),
                  )
                else
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          _feedback ?? 'Initializing camera...',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                // Countdown overlay
                if (_countdown > 0)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Text(
                        _countdown.toString(),
                        style: const TextStyle(
                          fontSize: 100,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                // Recording indicator
                if (_isRecording)
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Recording...',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Gesture guide overlay
                if (widget.gesture != null && !_isRecording && _countdown == 0)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMedium),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.gesture!.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: AppConstants.fontSizeLarge,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.gesture!.instructions.first,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: AppConstants.fontSizeSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Controls
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: SafeArea(
              child: Column(
                children: [
                  if (_feedback != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _feedback!,
                        style: const TextStyle(
                          color: AppConstants.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (!_isRecording && _countdown == 0)
                        ElevatedButton.icon(
                          onPressed: _isCameraInitialized && !_isUploading
                              ? _startPractice
                              : null,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Practice'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        ),
                      if (_isRecording)
                        ElevatedButton.icon(
                          onPressed: _stopRecording,
                          icon: const Icon(Icons.stop),
                          label: const Text('Stop'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.errorColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        ),
                      if (_isUploading)
                        const Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
