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
    'alphabets',
    'numbers',
    'greetings',
    'family',
    'food',
    'common phrases',
    'colors',
    'actions',
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
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
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
      if (safeA != safeB) {
        return safeA.compareTo(safeB);
      }
      return a.title.compareTo(b.title);
    });

    setState(() {
      _lessons = lessons;
    });
  }

  String _normalizeCategory(String category) {
    final value = category.trim().toLowerCase();
    if (value == 'letters' || value == 'alphabet' || value == 'alphabets') {
      return 'alphabets';
    }
    return value;
  }

  String _lessonCategoryKey(Lesson lesson) {
    if (lesson.gestureIds.isNotEmpty) {
      final first = MockDataService.getGestureById(lesson.gestureIds.first);
      if (first != null) {
        return _normalizeCategory(first.category);
      }
    }

    final lessonText = '${lesson.title} ${lesson.description}'.toLowerCase();
    if (lessonText.contains('letter') || lessonText.contains('alphabet')) {
      return 'alphabets';
    }
    if (lessonText.contains('number')) {
      return 'numbers';
    }
    if (lessonText.contains('greeting')) {
      return 'greetings';
    }
    return lesson.title.toLowerCase();
  }

  String _categoryLabel(String key) {
    switch (key) {
      case 'all':
        return 'All';
      case 'alphabets':
        return 'Letters';
      case 'numbers':
        return 'Numbers';
      case 'greetings':
        return 'Greetings';
      case 'family':
        return 'Family';
      case 'food':
        return 'Food';
      case 'common phrases':
        return 'Common Phrases';
      case 'colors':
        return 'Colors';
      case 'actions':
        return 'Actions';
      default:
        return key
            .split(' ')
            .map(
                (w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
            .join(' ');
    }
  }

  void _onCategorySelected(String categoryKey) {
    setState(() {
      _selectedCategory = categoryKey;
    });
  }

  void _onLessonTap(Lesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GestureListScreen(lesson: lesson),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildCategoryFilters(),
          Expanded(child: _buildLessonsList()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppConstants.backgroundColor,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Learn USL',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppConstants.textPrimary,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _showSearchDialog,
        ),
      ],
    );
  }

  int _categorySortValue(String categoryKey) {
    final index = _categoryPriority.indexOf(categoryKey);
    return index == -1 ? 999 : index;
  }

  List<String> _availableCategoryKeys() {
    final keys = <String>{};
    for (final lesson in _lessons) {
      keys.add(_lessonCategoryKey(lesson));
    }
    final sorted = keys.toList()
      ..sort((a, b) {
        final byPriority =
            _categorySortValue(a).compareTo(_categorySortValue(b));
        if (byPriority != 0) {
          return byPriority;
        }
        return _categoryLabel(a).compareTo(_categoryLabel(b));
      });
    return sorted;
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
          final categoryKey = categories[index];
          final isSelected = categoryKey == _selectedCategory;
          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _onCategorySelected(categoryKey),
            child: AnimatedContainer(
              duration: AppConstants.animationFast,
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppConstants.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppConstants.primaryColor
                      : AppConstants.dividerColor,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected && categoryKey == 'all') ...[
                    const Icon(Icons.check, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    _categoryLabel(categoryKey),
                    style: TextStyle(
                      color:
                          isSelected ? Colors.white : AppConstants.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.2, end: 0);
  }

  Widget _buildLessonsList() {
    if (_lessons.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    var filtered = _selectedCategory == 'all'
        ? List<Lesson>.from(_lessons)
        : _lessons
            .where((l) => _lessonCategoryKey(l) == _selectedCategory)
            .toList();

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((l) =>
              l.title.toLowerCase().contains(_searchQuery) ||
              l.description.toLowerCase().contains(_searchQuery))
          .toList();
    }

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          _selectedCategory == 'all'
              ? 'No lessons match your search right now.'
              : 'No lessons available for ${_categoryLabel(_selectedCategory)} yet.',
          style: const TextStyle(color: AppConstants.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final lesson = filtered[index];
        return _buildLessonCard(lesson)
            .animate()
            .fadeIn(duration: 350.ms, delay: (70 * index).ms)
            .slideY(
                begin: 0.15, end: 0, duration: 350.ms, delay: (70 * index).ms);
      },
    );
  }

  Widget _buildLessonCard(Lesson lesson) {
    final progress = lesson.progress.clamp(0.0, 1.0);
    final progressLabel = '${(progress * 100).round()}% Complete';
    final actionText =
        progress > 0 ? AppConstants.continueButton : AppConstants.startButton;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _onLessonTap(lesson),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EEFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      lesson.icon,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.title,
                          style: const TextStyle(
                            fontSize: 32 / 2,
                            fontWeight: FontWeight.w700,
                            color: AppConstants.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${lesson.totalSigns} signs',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppConstants.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF8D8D8D),
                    size: 30,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE2E2E2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppConstants.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            progressLabel,
            style: TextStyle(
              color: progress > 0
                  ? AppConstants.primaryColor
                  : AppConstants.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppConstants.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _onLessonTap(lesson),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        actionText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog<void>(
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
