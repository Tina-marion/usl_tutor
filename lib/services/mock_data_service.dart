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
  ];

  static final List<Lesson> _lessons = [
    const Lesson(
      id: 'l1',
      title: 'Greetings',
      description: 'Learn common greeting signs',
      icon: '👋',
      totalSigns: 5,
      learnedSigns: 2,
      gestureIds: ['g1', 'g2', 'g3', 'g4', 'g5'],
    ),
    const Lesson(
      id: 'l2',
      title: 'Family Members',
      description: 'Signs for family relationships',
      icon: '👨‍👩‍👧‍👦',
      totalSigns: 3,
      learnedSigns: 0,
      gestureIds: ['f1', 'f2', 'f3'],
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
      title: 'Common Phrases',
      description: 'Frequently used expressions',
      icon: '💬',
      totalSigns: 0,
      learnedSigns: 0,
      gestureIds: [],
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
