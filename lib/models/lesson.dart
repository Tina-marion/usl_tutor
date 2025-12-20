class Lesson {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int totalSigns;
  final int learnedSigns;
  final List<String> gestureIds;

  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.totalSigns,
    this.learnedSigns = 0,
    required this.gestureIds,
  });

  double get progress => totalSigns == 0 ? 0.0 : learnedSigns / totalSigns;

  bool get isCompleted => learnedSigns == totalSigns;

  Lesson copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    int? totalSigns,
    int? learnedSigns,
    List<String>? gestureIds,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      totalSigns: totalSigns ?? this.totalSigns,
      learnedSigns: learnedSigns ?? this.learnedSigns,
      gestureIds: gestureIds ?? this.gestureIds,
    );
  }
}
