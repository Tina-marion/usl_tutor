import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/lesson.dart';
import '../services/mock_data_service.dart';
import 'gesture_list_screen.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  static const List<String> _categoryPriority = [
    'alphabets', 'numbers', 'greetings', 'family', 'food',
    'common phrases', 'colors', 'actions',
  ];

  String _selectedCategory = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<Lesson> _lessons = [];

  @override
  void initState() {
    super.initState();
    _loadLessons();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadLessons() {
    final lessons = MockDataService.getLessons();
    lessons.sort((a, b) {
      final aPriority = _categoryPriority.indexOf(_lessonCategoryKey(a));
      final bPriority = _categoryPriority.indexOf(_lessonCategoryKey(b));
      final safeA = aPriority == -1 ? 999 : aPriority;
      final safeB = bPriority == -1 ? 999 : bPriority;
      if (safeA != safeB) return safeA.compareTo(safeB);
      return a.title.compareTo(b.title);
    });
    setState(() => _lessons = lessons);
  }

  String _normalizeCategory(String category) {
    final value = category.trim().toLowerCase();
    if (['letters', 'alphabet', 'alphabets'].contains(value)) return 'alphabets';
    return value;
  }

  String _lessonCategoryKey(Lesson lesson) {
    if (lesson.gestureIds.isNotEmpty) {
      final first = MockDataService.getGestureById(lesson.gestureIds.first);
      if (first != null) return _normalizeCategory(first.category);
    }
    final text = '${lesson.title} ${lesson.description}'.toLowerCase();
    if (text.contains('letter') || text.contains('alphabet')) return 'alphabets';
    if (text.contains('number')) return 'numbers';
    if (text.contains('greeting')) return 'greetings';
    return lesson.title.toLowerCase();
  }

  String _categoryLabel(String key) {
    switch (key) {
      case 'all': return 'All';
      case 'alphabets': return 'Letters';
      case 'numbers': return 'Numbers';
      case 'greetings': return 'Greetings';
      case 'family': return 'Family';
      case 'food': return 'Food';
      case 'common phrases': return 'Common Phrases';
      case 'colors': return 'Colors';
      case 'actions': return 'Actions';
      default: return key;
    }
  }

  void _onLessonTap(Lesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GestureListScreen(lesson: lesson)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildCategoryFilters(),
          Expanded(child: _buildLessonsGrid()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF8F9FA),
      elevation: 4,
      centerTitle: true,
      title: const Text(
        'Learn USL',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: _showSearchDialog,
        ),
      ],
    );
  }

  Widget _buildCategoryFilters() {
    final categories = <String>['all', ..._availableCategoryKeys()];

    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final key = categories[index];
          final isSelected = key == _selectedCategory;

          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.green : Colors.white,
                gradient: isSelected 
                    ? LinearGradient(colors: [Colors.green.shade700, Colors.green.shade300]) 
                    : null,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected ? [BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 2))] : [],
              ),
              child: Text(
                _categoryLabel(key),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<String> _availableCategoryKeys() {
    final keys = <String>{};
    for (final lesson in _lessons) {
      keys.add(_lessonCategoryKey(lesson));
    }
    return keys.toList();
  }

  Widget _buildLessonsGrid() {
    var filtered = _selectedCategory == 'all'
        ? List<Lesson>.from(_lessons)
        : _lessons.where((l) => _lessonCategoryKey(l) == _selectedCategory).toList();

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((l) =>
      l.title.toLowerCase().contains(_searchQuery) ||
          l.description.toLowerCase().contains(_searchQuery)).toList();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final lesson = filtered[index];

        return _LessonCard(
          lesson: lesson,
          onTap: () => _onLessonTap(lesson),
        ).animate().fadeIn(duration: 400.ms);
      },
    );
  }

  Widget _LessonCard({required Lesson lesson, required VoidCallback onTap}) {
    final progress = lesson.progress.clamp(0.0, 1.0);
    final categoryColor = _getCategoryColor(_lessonCategoryKey(lesson));
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth * 0.25; // Adjusted size for better aesthetics

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200, // Fixed height for consistency
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: categoryColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
            const SizedBox(height: 12),

            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  lesson.icon,
                  style: const TextStyle(fontSize: 42),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                lesson.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 4),

            Text(
              '${lesson.totalSigns} signs',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 8),

            if (progress > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(categoryColor),
                ),
              )
            else
              const Text(
                'Lets get started!',
                style: TextStyle(fontSize: 12, color: Color.fromARGB(255, 255, 107, 39)),
              ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String categoryKey) {
    switch (categoryKey) {
      case 'alphabets': return Colors.blue;
      case 'numbers': return Colors.orange;
      case 'greetings': return Colors.green;
      case 'family': return Colors.purple;
      case 'food': return Colors.deepOrange;
      case 'common phrases': return Colors.teal;
      case 'colors': return Colors.pink;
      case 'actions': return Colors.indigo;
      default: return Colors.green;
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Search Lessons'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Enter lesson name...',
          ),
        ),
      ),
    );
  }
}
