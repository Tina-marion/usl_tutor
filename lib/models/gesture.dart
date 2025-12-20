class GestureModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final String difficulty;
  final String videoUrl;
  final String? thumbnailUrl;
  final List<String> instructions;
  final List<String> tips;
  final int estimatedMinutes;
  final bool isLearned;
  final bool isMastered;
  final bool isLocked;
  final String? prerequisite;

  const GestureModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.difficulty,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.instructions,
    required this.tips,
    this.estimatedMinutes = 2,
    this.isLearned = false,
    this.isMastered = false,
    this.isLocked = false,
    this.prerequisite,
  });

  GestureModel copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    String? difficulty,
    String? videoUrl,
    String? thumbnailUrl,
    List<String>? instructions,
    List<String>? tips,
    int? estimatedMinutes,
    bool? isLearned,
    bool? isMastered,
    bool? isLocked,
    String? prerequisite,
  }) {
    return GestureModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      instructions: instructions ?? this.instructions,
      tips: tips ?? this.tips,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      isLearned: isLearned ?? this.isLearned,
      isMastered: isMastered ?? this.isMastered,
      isLocked: isLocked ?? this.isLocked,
      prerequisite: prerequisite ?? this.prerequisite,
    );
  }
}
