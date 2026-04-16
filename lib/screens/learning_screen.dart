import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants/app_constants.dart';
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
      default:
        return key.split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w).join(' ');
    }
  }

  void _onCategorySelected(String categoryKey) {
    setState(() => _selectedCategory = categoryKey);
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
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Learn USL',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 22),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black87),
          onPressed: _showSearchDialog,
        ),
      ],
    );
  }

  Widget _buildCategoryFilters() {
    final categories = <String>['all', ..._availableCategoryKeys()];
    return SizedBox(
      height: 54,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final key = categories[index];
          final isSelected = key == _selectedCategory;
          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _onCategorySelected(key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.green : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? Colors.green : Colors.grey.shade300),
              ),
              child: Text(
                _categoryLabel(key),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
    final sorted = keys.toList()
      ..sort((a, b) {
        final byPriority = _categoryPriority.indexOf(a).compareTo(_categoryPriority.indexOf(b));
        return byPriority != 0 ? byPriority : _categoryLabel(a).compareTo(_categoryLabel(b));
      });
    return sorted;
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

    if (filtered.isEmpty) {
      return const Center(
        child: Text('No lessons found', style: TextStyle(color: Colors.grey, fontSize: 16)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.08,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final lesson = filtered[index];
        return _LessonGridCard(
          lesson: lesson,
          onTap: () => _onLessonTap(lesson),
        ).animate().fadeIn(duration: 400.ms, delay: (50 * index).ms)
         .scale(begin: const Offset(0.92, 0.92));
      },
    );
  }

  // ===================== Enhanced Large & Colourful Lesson Card =====================
  Widget _LessonGridCard({required Lesson lesson, required VoidCallback onTap}) {
    final progress = lesson.progress.clamp(0.0, 1.0);
    final categoryColor = _getCategoryColor(_lessonCategoryKey(lesson));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Colorful Top Accent Bar (map-like feel)
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: categoryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Very Large & Colourful Icon
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: categoryColor.withOpacity(0.3),
                  width: 6,
                ),
              ),
              child: Center(
                child: Text(
                  lesson.icon,
                  style: TextStyle(
                    fontSize: 68,
                    shadows: [
                      Shadow(
                        color: categoryColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                lesson.title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 6),

            // Sign count
            Text(
              '${lesson.totalSigns} signs',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 16),

            // Progress Bar (only if started)
            if (progress > 0) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(categoryColor),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${(progress * 100).round()}% complete',
                style: TextStyle(
                  fontSize: 13.5,
                  color: categoryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else
              const Text(
                'Tap to start',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper: Assign vibrant colors per category
  Color _getCategoryColor(String categoryKey) {
    switch (categoryKey) {
      case 'alphabets': return Colors.blue.shade600;
      case 'numbers':   return Colors.orange.shade600;
      case 'greetings': return Colors.green.shade600;
      case 'family':    return Colors.purple.shade600;
      case 'food':      return const Color(0xFFFF6D00); // Vibrant orange
      case 'common phrases': return Colors.teal.shade600;
      case 'colors':    return Colors.pink.shade600;
      case 'actions':   return Colors.indigo.shade600;
      default:          return Colors.green.shade600;
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Lessons'),
        content: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter lesson name...',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (_) => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}