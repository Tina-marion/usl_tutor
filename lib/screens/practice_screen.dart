import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../constants/app_constants.dart';
import '../models/gesture.dart';
import '../services/mock_data_service.dart';
import '../services/progress_service.dart';

enum PracticeMode { numbers, alphabets }

class PracticeScreen extends StatefulWidget {
  final GestureModel? gesture;

  const PracticeScreen({super.key, this.gesture});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  CameraController? _cameraController;
  VideoPlayerController? _videoController;
  bool _isCameraInitialized = false;
  bool _isRecording = false;
  bool _isUploading = false;
  int _countdown = 0;
  Timer? _countdownTimer;
  String? _feedback;
  String? _translation;
  final _progressService = ProgressService();
  PracticeMode? _selectedMode;
  List<GestureModel> _practiceGestures = [];
  int _currentGestureIndex = 0;

  GestureModel? get _activeGesture {
    if (widget.gesture != null) {
      return widget.gesture;
    }
    if (_practiceGestures.isEmpty) {
      return null;
    }
    return _practiceGestures[_currentGestureIndex];
  }

  bool get _isModePractice => widget.gesture == null;

  String get _selectedModeLabel =>
      _selectedMode == PracticeMode.numbers ? 'Numbers' : 'Alphabets';

  BoxDecoration get _panelDecoration => BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppConstants.dividerColor),
      );

  get InferenceService => null;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    if (widget.gesture != null) {
      _initializeVideo();
    }
    _progressService.init();
  }

  Future<void> _initializeVideo() async {
    final gesture = _activeGesture;
    if (gesture != null && gesture.videoUrl.isNotEmpty) {
      try {
        await _videoController?.dispose();
        _videoController = VideoPlayerController.asset(gesture.videoUrl);
        await _videoController!.initialize();
        // Loop the video
        await _videoController!.setLooping(true);
        // Start playing
        await _videoController!.play();
        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        // Video loading failed, continue without it
        print('Video loading error: $e');
      }
    }
  }

  List<GestureModel> _gesturesForMode(PracticeMode mode) {
    final allWithVideos = MockDataService.getGestures()
        .where((g) => g.videoUrl.isNotEmpty)
        .toList();

    final numbers = allWithVideos
        .where((g) => g.category.toLowerCase() == 'numbers')
        .toList();
    final alphabets = allWithVideos
        .where(
          (g) =>
              g.category.toLowerCase() == 'letters' ||
              g.category.toLowerCase() == 'alphabets',
        )
        .toList();

    final selected = mode == PracticeMode.numbers ? numbers : alphabets;
    selected.sort((a, b) => a.name.compareTo(b.name));
    return selected;
  }

  Future<void> _selectMode(PracticeMode mode) async {
    final gestures = _gesturesForMode(mode);
    setState(() {
      _selectedMode = mode;
      _practiceGestures = gestures;
      _currentGestureIndex = 0;
      _feedback = gestures.isEmpty
          ? 'No videos available for this practice mode yet.'
          : null;
    });

    if (gestures.isNotEmpty) {
      await _initializeVideo();
    }
  }

  Future<void> _showNextGesture() async {
    if (_practiceGestures.isEmpty) {
      return;
    }
    setState(() {
      _currentGestureIndex =
          (_currentGestureIndex + 1) % _practiceGestures.length;
      _feedback = null;
      _translation = null;
    });
    await _initializeVideo();
  }

  Future<void> _changeMode() async {
    if (_isRecording || _isUploading || _countdown > 0) {
      return;
    }

    await _videoController?.dispose();
    if (!mounted) {
      return;
    }

    setState(() {
      _videoController = null;
      _selectedMode = null;
      _practiceGestures = [];
      _currentGestureIndex = 0;
      _translation = null;
      _feedback = 'Choose Numbers or Alphabets to continue.';
    });
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
    _videoController?.dispose();
    super.dispose();
  }

  void _startPractice() {
    if (widget.gesture == null && _activeGesture == null) {
      setState(() {
        _feedback = 'Choose Numbers or Alphabets to begin practice.';
      });
      return;
    }

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
        _feedback = 'Processing locally...';
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
    final String gestureExpected = _activeGesture?.name ?? 'sign';

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
            Text('Practice Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_activeGesture != null) ...[
              Text(
                'Expected: $gestureExpected',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (hasTranslation) ...[
              Text(
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
                  color: AppConstants.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _translation!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_activeGesture != null)
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
              Text(
                'Could not detect sign. Please try again with:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text('• Better lighting'),
              Text('• Clear hand movements'),
              Text('• Proper camera position'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Practice Again'),
          ),
          if (_activeGesture != null && hasTranslation)
            ElevatedButton(
              onPressed: () async {
                await _progressService.markGestureAsLearned(_activeGesture!.id);
                if (mounted) {
                  Navigator.pop(context);
                  if (widget.gesture != null) {
                    Navigator.pop(context);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
              ),
              child: Text('Mark as Learned'),
            ),
        ],
      ),
    );
  }

  Widget _buildModePanel() {
    if (!_isModePractice) {
      return const SizedBox.shrink();
    }

    if (_selectedMode == null) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
        padding: const EdgeInsets.all(14),
        decoration: _panelDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hey!!! Ready to practice some USL?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Choose what to practice..',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectMode(PracticeMode.alphabets),
                    icon: Icon(Icons.sort_by_alpha),
                    label: Text('Alphabets'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppConstants.primaryColor,
                      side: const BorderSide(color: AppConstants.dividerColor),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectMode(PracticeMode.numbers),
                    icon: Icon(Icons.pin),
                    label: Text('Numbers'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppConstants.primaryColor,
                      side: const BorderSide(color: AppConstants.dividerColor),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      padding: const EdgeInsets.all(12),
      decoration: _panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mode: $_selectedModeLabel',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: _changeMode,
                icon: Icon(Icons.swap_horiz, size: 18),
                label: Text('Change Mode'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppConstants.primaryColor,
                  side: const BorderSide(color: AppConstants.dividerColor),
                ),
              ),
              if (_practiceGestures.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: _showNextGesture,
                  icon: Icon(Icons.skip_next, size: 18),
                  label: Text('Next Video'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConstants.primaryColor,
                    side: const BorderSide(color: AppConstants.dividerColor),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldShowCameraArea = !_isModePractice || _selectedMode != null;
    final bool canStartPractice =
        _isCameraInitialized && !_isUploading && _activeGesture != null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        title: Text(
          _activeGesture != null
              ? 'Practice: ${_activeGesture!.name}'
              : 'Practice Mode',
        ),
      ),
      body: Column(
        children: [
          _buildModePanel(),
          if (_activeGesture != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: _panelDecoration,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Current: ${_activeGesture!.name}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (_isModePractice && _practiceGestures.isNotEmpty)
                    Text(
                      '${_currentGestureIndex + 1}/${_practiceGestures.length}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              decoration: BoxDecoration(
                color: AppConstants.cardColor,
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                border: Border.all(color: AppConstants.dividerColor),
              ),
              clipBehavior: Clip.antiAlias,
              child: shouldShowCameraArea
                  ? Stack(
                      children: [
                        // Camera preview
                        if (_isCameraInitialized && _cameraController != null)
                          SizedBox.expand(
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _cameraController!
                                    .value.previewSize!.height,
                                height:
                                    _cameraController!.value.previewSize!.width,
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
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),

                        if (_countdown > 0)
                          Container(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.54),
                            child: Center(
                              child: Text(
                                _countdown.toString(),
                                style: TextStyle(
                                  fontSize: 100,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                        if (_videoController != null &&
                            _videoController!.value.isInitialized)
                          Positioned(
                            top: 14,
                            right: 14,
                            child: Container(
                              width: 108,
                              height: 145,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppConstants.primaryColor,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(
                                    AppConstants.radiusSmall),
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    AppConstants.radiusSmall),
                                child: AspectRatio(
                                  aspectRatio:
                                      _videoController!.value.aspectRatio,
                                  child: VideoPlayer(_videoController!),
                                ),
                              ),
                            ),
                          ),

                        if (_isRecording)
                          Positioned(
                            top: 14,
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
                                Text(
                                  'Recording...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (_activeGesture != null &&
                            !_isRecording &&
                            _countdown == 0)
                          Positioned(
                            bottom: 14,
                            left: 14,
                            right: 14,
                            child: Container(
                              padding: const EdgeInsets.all(
                                  AppConstants.paddingMedium),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.87),
                                borderRadius: BorderRadius.circular(
                                    AppConstants.radiusMedium),
                              ),
                              child: Text(
                                _activeGesture!.instructions.first,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: AppConstants.fontSizeSmall,
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  : Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: _panelDecoration,
                        child: Text(
                          'Select a practice mode above to activate the camera.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: AppConstants.fontSizeNormal,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            padding: const EdgeInsets.all(12),
            decoration: _panelDecoration,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_feedback != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            AppConstants.primaryColor.withValues(alpha: 0.08),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusSmall),
                      ),
                      child: Text(
                        _feedback!,
                        style: TextStyle(
                          color: AppConstants.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (_isUploading)
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Processing...',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isRecording
                          ? _stopRecording
                          : (canStartPractice ? _startPractice : null),
                      icon: Icon(_isRecording ? Icons.stop : Icons.play_arrow),
                      label: Text(
                          _isRecording ? 'Stop Recording' : 'Start Practice'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isRecording
                            ? AppConstants.errorColor
                            : AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
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
