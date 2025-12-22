import 'dart:math';

/// Mock service to simulate AI gesture recognition
/// In production, this would use a TensorFlow Lite model
class MockRecognitionService {
  final Random _random = Random();

  /// Simulate gesture recognition with delay
  /// Returns recognized gesture name and confidence score
  Future<RecognitionResult> recognizeGesture({
    required String targetGesture,
    Duration delay = const Duration(milliseconds: 800),
  }) async {
    // Simulate processing time
    await Future.delayed(delay);

    // 70% chance of correct recognition
    final bool isCorrect = _random.nextDouble() > 0.3;

    if (isCorrect) {
      // Correct gesture with varying confidence
      final confidence = 0.7 + (_random.nextDouble() * 0.25); // 70-95%
      return RecognitionResult(
        recognizedGesture: targetGesture,
        targetGesture: targetGesture,
        confidence: confidence,
        isCorrect: true,
        feedback: _generatePositiveFeedback(confidence),
        suggestions: _generatePositiveSuggestions(confidence),
      );
    } else {
      // Incorrect gesture
      final wrongGestures = [
        'Hello',
        'Thank You',
        'Please',
        'Sorry',
        'Goodbye'
      ];
      wrongGestures.remove(targetGesture);
      final wrongGesture = wrongGestures[_random.nextInt(wrongGestures.length)];
      final confidence = 0.4 + (_random.nextDouble() * 0.3); // 40-70%

      return RecognitionResult(
        recognizedGesture: wrongGesture,
        targetGesture: targetGesture,
        confidence: confidence,
        isCorrect: false,
        feedback: _generateNegativeFeedback(targetGesture, wrongGesture),
        suggestions: _generateCorrectionSuggestions(),
      );
    }
  }

  String _generatePositiveFeedback(double confidence) {
    if (confidence > 0.9) {
      return 'Perfect! Excellent execution! 🌟';
    } else if (confidence > 0.8) {
      return 'Great job! Very good form! 👍';
    } else if (confidence > 0.7) {
      return 'Good work! Keep practicing! 😊';
    } else {
      return 'Nice try! A bit more precision needed.';
    }
  }

  List<String> _generatePositiveSuggestions(double confidence) {
    if (confidence > 0.9) {
      return [
        'Your hand positioning was spot-on',
        'Movement speed was perfect',
        'Clear and confident execution',
      ];
    } else if (confidence > 0.8) {
      return [
        'Hand position was very good',
        'Try to make movements slightly smoother',
        'Maintain this consistency',
      ];
    } else {
      return [
        'Hand position needs slight adjustment',
        'Focus on smooth, controlled movements',
        'Practice the motion a few more times',
      ];
    }
  }

  String _generateNegativeFeedback(String target, String recognized) {
    return 'Not quite right. You signed "$recognized" but the target was "$target"';
  }

  List<String> _generateCorrectionSuggestions() {
    final suggestions = [
      'Move your hand higher (near ear level)',
      'Keep fingers more spread apart',
      'Wave motion should be side-to-side',
      'Start with hand closer to your face',
      'Make the movement slower and more deliberate',
      'Ensure palm is facing forward',
      'Keep your hand more relaxed',
      'Focus on finger positioning',
    ];

    // Return 3 random suggestions
    suggestions.shuffle();
    return suggestions.take(3).toList();
  }
}

/// Result model for gesture recognition
class RecognitionResult {
  final String recognizedGesture;
  final String targetGesture;
  final double confidence;
  final bool isCorrect;
  final String feedback;
  final List<String> suggestions;

  RecognitionResult({
    required this.recognizedGesture,
    required this.targetGesture,
    required this.confidence,
    required this.isCorrect,
    required this.feedback,
    required this.suggestions,
  });

  int get confidencePercent => (confidence * 100).round();
}
