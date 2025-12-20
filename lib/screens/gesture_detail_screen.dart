import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants/app_constants.dart';
import '../models/gesture.dart';
import '../services/progress_service.dart';

class GestureDetailScreen extends StatefulWidget {
  final GestureModel gesture;

  const GestureDetailScreen({super.key, required this.gesture});

  @override
  State<GestureDetailScreen> createState() => _GestureDetailScreenState();
}

class _GestureDetailScreenState extends State<GestureDetailScreen> {
  final _progressService = ProgressService();
  bool _isFavorite = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteState();
  }

  Future<void> _loadFavoriteState() async {
    await _progressService.init();
    setState(() {
      _isFavorite = _progressService.isFavorite(widget.gesture.id);
    });
  }

  Future<void> _toggleFavorite() async {
    await _progressService.toggleFavorite(widget.gesture.id);
    setState(() {
      _isFavorite = !_isFavorite;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite ? 'Added to favorites' : 'Removed from favorites',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _markAsLearned() async {
    await _progressService.markGestureAsLearned(widget.gesture.id);

    if (mounted) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Great Job! 🎉'),
          content: Text('You\'ve marked "${widget.gesture.name}" as learned!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Continue Learning'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Navigate to practice mode with this gesture.
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
              ),
              child: const Text('Practice Now'),
            ),
          ],
        ),
      );
    }
  }

  void _startPractice() {
    // TODO: Navigate to practice mode.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening practice mode...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVideoSection(),
            _buildGestureInfo(),
            _buildInstructions(),
            _buildTips(),
            const SizedBox(height: AppConstants.paddingLarge),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? AppConstants.errorColor : null,
          ),
          onPressed: _toggleFavorite,
        ),
      ],
    );
  }

  Widget _buildVideoSection() {
    return Container(
      width: double.infinity,
      height: 300,
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            color: Colors.grey[900],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_circle_outline,
                    size: 80,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Video: ${widget.gesture.name}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AppConstants.fontSizeLarge,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Video player will be integrated here',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: AppConstants.fontSizeMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!_isPlaying)
            InkWell(
              onTap: () {
                setState(() {
                  _isPlaying = true;
                });
                // TODO: Start video playback.
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton(Icons.replay, 'Replay'),
                  const SizedBox(width: 24),
                  _buildControlButton(Icons.slow_motion_video, 'Slow Motion'),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildControlButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 4),
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

  Widget _buildGestureInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.gesture.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimary,
                  ),
                ),
              ),
              _buildDifficultyChip(),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.volume_up),
                onPressed: () {
                  // TODO: Text-to-speech.
                },
                color: AppConstants.primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.gesture.category,
            style: const TextStyle(
              fontSize: AppConstants.fontSizeMedium,
              color: AppConstants.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.gesture.description,
            style: const TextStyle(
              fontSize: AppConstants.fontSizeNormal,
              color: AppConstants.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 200.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildDifficultyChip() {
    Color color;
    switch (widget.gesture.difficulty.toLowerCase()) {
      case 'easy':
        color = AppConstants.accentColor;
        break;
      case 'medium':
        color = AppConstants.warningColor;
        break;
      case 'hard':
        color = AppConstants.errorColor;
        break;
      default:
        color = AppConstants.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        widget.gesture.difficulty,
        style: TextStyle(
          fontSize: AppConstants.fontSizeSmall,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt, color: AppConstants.primaryColor, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Instructions',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.gesture.instructions.asMap().entries.map((entry) {
            final index = entry.key;
            final instruction = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: AppConstants.fontSizeMedium,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      instruction,
                      style: const TextStyle(
                        fontSize: AppConstants.fontSizeNormal,
                        color: AppConstants.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 300.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildTips() {
    return Container(
      margin:
          const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: AppConstants.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(
          color: AppConstants.accentColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppConstants.warningColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Tips',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.gesture.tips.map((tip) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeLarge,
                      color: AppConstants.warningColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(
                        fontSize: AppConstants.fontSizeNormal,
                        color: AppConstants.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildBottomBar() {
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
            Expanded(
              child: OutlinedButton(
                onPressed: _markAsLearned,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppConstants.primaryColor),
                ),
                child: const Text(
                  '✓ Mark as Learned',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: AppConstants.fontSizeNormal,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _startPractice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: const Text(
                  '🎥 Practice This Sign',
                  style: TextStyle(
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
}
