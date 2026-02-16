import '../models/gesture.dart';
import '../models/lesson.dart';

/// Mock data provider for gestures and lessons.
/// Replace with API/database layer in production.
class MockDataService {
  static final List<GestureModel> _gestures = [
    const GestureModel(
      id: 'g1',
      name: 'Hello',
      category: 'Greetings',
      description: 'A friendly greeting gesture',
      difficulty: 'Easy',
      videoUrl: 'assets/videos/0001.mp4',
      instructions: [
        'Raise your dominant hand to ear level',
        'Keep palm open, fingers together',
        'Wave hand side to side 2-3 times',
      ],
      tips: [
        'Keep movements smooth and clear',
        'Maintain eye contact',
        'Smile while signing',
      ],
      estimatedMinutes: 2,
      isLearned: true,
    ),
    const GestureModel(
      id: 'g2',
      name: 'Thank You',
      category: 'Greetings',
      description: 'Express gratitude',
      difficulty: 'Easy',
      videoUrl: 'assets/videos/0013.mp4',
      instructions: [
        'Touch your chin with fingertips',
        'Move hand forward and down',
        'Keep palm facing up',
      ],
      tips: [
        'Start with fingers touching chin',
        'Smooth outward motion',
        'Show genuine appreciation in expression',
      ],
      estimatedMinutes: 2,
      isLearned: true,
      isMastered: true,
    ),
    const GestureModel(
      id: 'g3',
      name: 'Please',
      category: 'Greetings',
      description: 'Make a polite request',
      difficulty: 'Medium',
      videoUrl: 'assets/videos/0016.mp4',
      instructions: [
        'Place hand flat on chest',
        'Move in circular motion',
        'Keep movement smooth',
      ],
      tips: [
        'Circle clockwise',
        'Maintain gentle pressure',
        'Facial expression is important',
      ],
      estimatedMinutes: 3,
      isLearned: false,
      prerequisite: 'g2',
    ),
    const GestureModel(
      id: 'g4',
      name: 'Good',
      category: 'Greetings',
      description: 'Morning greeting - Good',
      difficulty: 'Easy',
      videoUrl: 'assets/videos/0018.mp4',
      instructions: [
        'Sign "good" first',
        'Then sign "morning"',
        'Combine smoothly',
      ],
      tips: [
        'Practice each part separately first',
        'Then combine them',
        'Keep natural rhythm',
      ],
      estimatedMinutes: 3,
      isLearned: false,
    ),
    const GestureModel(
      id: 'g5',
      name: 'Goodbye',
      category: 'Greetings',
      description: 'Farewell gesture',
      difficulty: 'Easy',
      videoUrl: 'assets/videos/0027.mp4',
      instructions: [
        'Raise hand with palm facing person',
        'Open and close fingers',
        'Repeat 2-3 times',
      ],
      tips: [
        'Keep motion visible',
        'Smile warmly',
        'Make eye contact',
      ],
      estimatedMinutes: 2,
      isLearned: false,
    ),
    const GestureModel(
      id: 'f1',
      name: 'Mother',
      category: 'Family',
      description: 'Sign for mother',
      difficulty: 'Easy',
      videoUrl: 'assets/videos/mother.mp4',
      instructions: [
        'Touch thumb to chin',
        'Spread fingers',
        'Keep hand relaxed',
      ],
      tips: [
        'Gentle touch',
        'Clear finger position',
        'Calm expression',
      ],
      estimatedMinutes: 2,
      isLearned: false,
    ),
    const GestureModel(
      id: 'f2',
      name: 'Father',
      category: 'Family',
      description: 'Sign for father',
      difficulty: 'Easy',
      videoUrl: 'assets/videos/father.mp4',
      instructions: [
        'Touch thumb to forehead',
        'Spread fingers',
        'Keep hand relaxed',
      ],
      tips: [
        'Similar to "mother" but at forehead',
        'Clear distinction',
        'Confident posture',
      ],
      estimatedMinutes: 2,
      isLearned: false,
    ),
    const GestureModel(
      id: 'f3',
      name: 'Sister',
      category: 'Family',
      description: 'Sign for sister',
      difficulty: 'Medium',
      videoUrl: 'assets/videos/sister.mp4',
      instructions: [
        'Sign "girl" first',
        'Then sign "same"',
        'Combine smoothly',
      ],
      tips: [
        'Two-part sign',
        'Practice transitions',
        'Keep consistent speed',
      ],
      estimatedMinutes: 3,
      isLearned: false,
    ),
    const GestureModel(
      id: 'n1',
      name: 'One',
      category: 'Numbers',
      description: 'Number 1',
      difficulty: 'Easy',
      videoUrl: 'assets/videos/one.mp4',
      instructions: [
        'Raise index finger',
        'Keep other fingers closed',
        'Palm facing forward',
      ],
      tips: [
        'Clear finger position',
        'Keep hand steady',
        'Confident posture',
      ],
      estimatedMinutes: 1,
      isLearned: false,
    ),
    const GestureModel(
      id: 'n2',
      name: 'Two',
      category: 'Numbers',
      description: 'Number 2',
      difficulty: 'Easy',
      videoUrl: 'assets/videos/two.mp4',
      instructions: [
        'Raise index and middle finger',
        'Keep other fingers closed',
        'Palm facing forward',
      ],
      tips: [
        'Fingers should be separated',
        'Keep hand steady',
        'Clear V shape',
      ],
      estimatedMinutes: 1,
      isLearned: false,
    ),
    const GestureModel(
      id: 'food1',
      name: 'Food',
      category: 'Food',
      description: 'Sign for food',
      difficulty: 'Easy',
      videoUrl: 'assets/videos/0063.mp4',
      instructions: [
        'Bring fingers to mouth',
        'Repeat motion',
        'Natural eating gesture',
      ],
      tips: [
        'Keep movements smooth',
        'Clear hand-to-mouth motion',
        'Comfortable pace',
      ],
      estimatedMinutes: 1,
      isLearned: false,
    ),
    const GestureModel(
      id: 'f4',
      name: 'Parents',
      category: 'Family',
      description: 'Sign for parents',
      difficulty: 'Medium',
      videoUrl: 'assets/videos/0083.mp4',
      instructions: [
        'Combine mother and father signs',
        'Sign for both parents',
        'Smooth transition between signs',
      ],
      tips: [
        'Practice each sign separately first',
        'Keep movements clear',
        'Natural flow',
      ],
      estimatedMinutes: 2,
      isLearned: false,
    ),
    const GestureModel(
      id: 'phrase1',
      name: 'Users',
      category: 'Common Phrases',
      description: 'Sign for users or people',
      difficulty: 'Medium',
      videoUrl: 'assets/videos/0089.mp4',
      instructions: [
        'Indicate multiple people',
        'Sweeping motion',
        'Include everyone gesture',
      ],
      tips: [
        'Wide sweeping motion',
        'Include all directions',
        'Clear indication of group',
      ],
      estimatedMinutes: 2,
      isLearned: false,
    ),
    const GestureModel(
      id: 'g6',
      name: 'Morning',
      category: 'Greetings',
      description: 'Time of day - morning',
      difficulty: 'Easy',
      videoUrl: 'assets/videos/0019.mp4',
      instructions: [
        'Bring arm up like sunrise',
        'Palm facing up',
        'Smooth upward motion',
      ],
      tips: [
        'Think of the sun rising',
        'Keep movement fluid',
        'End at chest level',
      ],
      estimatedMinutes: 2,
      isLearned: false,
    ),
    const GestureModel(
      id: 'g7',
      name: 'Afternoon',
      category: 'Greetings',
      description: 'Time of day - afternoon',
      difficulty: 'Easy',
      videoUrl: 'assets/videos/0020.mp4',
      instructions: [
        'Arm at an angle',
        'Palm down position',
        'Represents sun at midday',
      ],
      tips: [
        'Forearm slightly tilted',
        'Keep position steady',
        'Natural arm angle',
      ],
      estimatedMinutes: 2,
      isLearned: false,
    ),
    const GestureModel(
      id: 'g8',
      name: 'Evening',
      category: 'Greetings',
      description: 'Time of day - evening',
      difficulty: 'Easy',
      videoUrl: 'assets/videos/0021.mp4',
      instructions: [
        'Arm going down like sunset',
        'Palm down',
        'Descending motion',
      ],
      tips: [
        'Think of the sun setting',
        'Smooth downward motion',
        'End at lower position',
      ],
      estimatedMinutes: 2,
      isLearned: false,
    ),
    const GestureModel(
      id: 'phrase2',
      name: 'Day',
      category: 'Common Phrases',
      description: 'Full day or daytime',
      difficulty: 'Easy',
      videoUrl: 'assets/videos/0022.mp4',
      instructions: [
        'Point to the sky',
        'Arc motion across',
        'Represents sun\'s path',
      ],
      tips: [
        'Full sweeping motion',
        'From one side to other',
        'Keep movement smooth',
      ],
      estimatedMinutes: 2,
      isLearned: false,
    ),
    const GestureModel(
      id: 'phrase3',
      name: 'Good',
      category: 'Common Phrases',
      description: 'Positive affirmation',
      difficulty: 'Easy',
      videoUrl: 'assets/videos/0023.mp4',
      instructions: [
        'Touch chin with flat hand',
        'Move forward and down',
        'Palm facing up at end',
      ],
      tips: [
        'Start at chin level',
        'Smooth forward motion',
        'Show positive expression',
      ],
      estimatedMinutes: 2,
      isLearned: false,
    ),
    const GestureModel(
      id: 'phrase4',
      name: 'Bad',
      category: 'Common Phrases',
      description: 'Negative affirmation',
      difficulty: 'Easy',
      videoUrl: 'assets/videos/0024.mp4',
      instructions: [
        'Similar to good but different direction',
        'Touch chin then flip away',
        'Palm ends facing down',
      ],
      tips: [
        'Quick flipping motion',
        'Clear contrast to "good"',
        'Match facial expression',
      ],
      estimatedMinutes: 2,
      isLearned: false,
    ),
  ];

  static final List<Lesson> _lessons = [
    const Lesson(
      id: 'l1',
      title: 'Greetings',
      description: 'Learn common greeting signs',
      icon: '👋',
      totalSigns: 8,
      learnedSigns: 2,
      gestureIds: ['g1', 'g2', 'g3', 'g4', 'g5', 'g6', 'g7', 'g8'],
    ),
    const Lesson(
      id: 'l2',
      title: 'Family Members',
      description: 'Signs for family relationships',
      icon: '👨‍👩‍👧‍👦',
      totalSigns: 4,
      learnedSigns: 0,
      gestureIds: ['f1', 'f2', 'f3', 'f4'],
    ),
    const Lesson(
      id: 'l3',
      title: 'Numbers 1-10',
      description: 'Basic number signs',
      icon: '🔢',
      totalSigns: 2,
      learnedSigns: 0,
      gestureIds: ['n1', 'n2'],
    ),
    const Lesson(
      id: 'l4',
      title: 'Food',
      description: 'Signs related to food and eating',
      icon: '🍽️',
      totalSigns: 1,
      learnedSigns: 0,
      gestureIds: ['food1'],
    ),
    const Lesson(
      id: 'l5',
      title: 'Common Phrases',
      description: 'Frequently used expressions',
      icon: '💬',
      totalSigns: 4,
      learnedSigns: 0,
      gestureIds: ['phrase1', 'phrase2', 'phrase3', 'phrase4'],
    ),
  ];

  static List<Lesson> getLessons() => _lessons;

  static List<GestureModel> getGestures() => _gestures;

  static List<GestureModel> getGesturesByCategory(String category) =>
      _gestures.where((g) => g.category == category).toList();

  static GestureModel? getGestureById(String id) {
    return _gestures.where((g) => g.id == id).cast<GestureModel?>().firstWhere(
          (g) => g != null && g.id == id,
          orElse: () => null,
        );
  }

  static Lesson? getLessonById(String id) {
    return _lessons.where((l) => l.id == id).cast<Lesson?>().firstWhere(
          (l) => l != null && l.id == id,
          orElse: () => null,
        );
  }

  static List<GestureModel> getGesturesForLesson(Lesson lesson) {
    return _gestures.where((g) => lesson.gestureIds.contains(g.id)).toList();
  }

  static List<GestureModel> searchGestures(String query) {
    final q = query.toLowerCase();
    return _gestures.where((g) => g.name.toLowerCase().contains(q)).toList();
  }
}
