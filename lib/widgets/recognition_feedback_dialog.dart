import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/mock_recognition_service.dart';
import '../constants/app_constants.dart';

class RecognitionFeedbackDialog extends StatelessWidget {
  final RecognitionResult result;
  final VoidCallback onTryAgain;
  final VoidCallback onNextSign;

  const RecognitionFeedbackDialog({
    super.key,
    required this.result,
    required this.onTryAgain,
    required this.onNextSign,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: AppConstants.paddingMedium),
            _buildConfidenceScore(),
            const SizedBox(height: AppConstants.paddingLarge),
            _buildFeedbackMessage(),
            const SizedBox(height: AppConstants.paddingMedium),
            _buildSuggestions(),
            const SizedBox(height: AppConstants.paddingLarge),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: result.isCorrect
                ? AppConstants.accentColor.withOpacity(0.1)
                : AppConstants.warningColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            result.isCorrect ? Icons.check_circle : Icons.info_outline,
            size: 48,
            color: result.isCorrect
                ? AppConstants.accentColor
                : AppConstants.warningColor,
          ),
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 16),
        Text(
          result.isCorrect ? 'Well Done!' : 'Not Quite',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: result.isCorrect
                ? AppConstants.accentColor
                : AppConstants.warningColor,
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
      ],
    );
  }

  Widget _buildConfidenceScore() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingLarge,
        vertical: AppConstants.paddingMedium,
      ),
      decoration: BoxDecoration(
        color: result.isCorrect
            ? AppConstants.accentColor.withOpacity(0.1)
            : AppConstants.warningColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Recognized as: ',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  color: AppConstants.textSecondary,
                ),
              ),
              Text(
                result.recognizedGesture,
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${result.confidencePercent}%',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: result.isCorrect
                      ? AppConstants.accentColor
                      : AppConstants.warningColor,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'confidence',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  color: AppConstants.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: result.confidence,
              backgroundColor: AppConstants.dividerColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                result.isCorrect
                    ? AppConstants.accentColor
                    : AppConstants.warningColor,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 300.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildFeedbackMessage() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      ),
      child: Row(
        children: [
          Icon(
            result.isCorrect ? Icons.thumb_up : Icons.info,
            color: result.isCorrect
                ? AppConstants.accentColor
                : AppConstants.warningColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              result.feedback,
              style: const TextStyle(
                fontSize: AppConstants.fontSizeNormal,
                color: AppConstants.textPrimary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms);
  }

  Widget _buildSuggestions() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        border: Border.all(color: AppConstants.dividerColor),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 20,
                color: AppConstants.warningColor,
              ),
              const SizedBox(width: 8),
              const Text(
                'Suggestions:',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...result.suggestions.map((suggestion) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: result.isCorrect
                          ? AppConstants.accentColor
                          : AppConstants.warningColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      suggestion,
                      style: const TextStyle(
                        fontSize: AppConstants.fontSizeMedium,
                        color: AppConstants.textPrimary,
                        height: 1.4,
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
        .fadeIn(duration: 400.ms, delay: 500.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onTryAgain,
            style: ElevatedButton.styleFrom(
              backgroundColor: result.isCorrect
                  ? AppConstants.accentColor
                  : AppConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
            ),
            child: Text(
              result.isCorrect ? 'Practice Again' : 'Try Again',
              style: const TextStyle(
                fontSize: AppConstants.fontSizeNormal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onNextSign,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(
                color: result.isCorrect
                    ? AppConstants.accentColor
                    : AppConstants.primaryColor,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Next Sign',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeNormal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 600.ms);
  }
}
