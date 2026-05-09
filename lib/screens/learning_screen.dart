import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants/app_constants.dart';
import '../models/lesson.dart';
import '../services/mock_data_service.dart';
import '../widgets/app_logo.dart';
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
    if (['letters', 'alphabet', 'alphabets'].contains(value))
      return 'alphabets';
    return value;
  }

  String _lessonCategoryKey(Lesson lesson) {
    if (lesson.gestureIds.isNotEmpty) {
      final first = MockDataService.getGestureById(lesson.gestureIds.first);
      if (first != null) return _normalizeCategory(first.category);
    }
    final text = '${lesson.title} ${lesson.description}'.toLowerCase();
    if (text.contains('letter') || text.contains('alphabet'))
      return 'alphabets';
    if (text.contains('number')) return 'numbers';
    if (text.contains('greeting')) return 'greetings';
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
        return key;
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
    final filteredLessons = _getFilteredLessons();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).cardColor.withValues(alpha: 0.55),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          top: false,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                  child: _buildHeroPanel(filteredLessons.length)),
              SliverToBoxAdapter(child: _buildCategoryFilters()),
              SliverPadding(
                padding: const EdgeInsets.only(top: 8),
                sliver: _buildLessonsSliver(filteredLessons),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppLogoMark(size: 28),
          const SizedBox(width: 10),
          Text(
            'Learn USL',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 15, 118, 110),
                fontSize: 20),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: _showSearchDialog,
        ),
      ],
    );
  }

  Widget _buildHeroPanel(int visibleLessons) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: AppConstants.dividerColor),
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppConstants.primaryGradient,
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore USL lessons',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pick a category, open a lesson, and start building your sign vocabulary.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_lessons.length}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                'lessons',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$visibleLessons visible',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.08, end: 0);
  }

  Widget _buildCategoryFilters() {
    final categories = <String>['all', ..._availableCategoryKeys()];

    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final key = categories[index];
          final isSelected = key == _selectedCategory;

          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppConstants.primaryColor
                    : Theme.of(context).cardColor,
                gradient: isSelected ? AppConstants.primaryGradient : null,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : AppConstants.dividerColor,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color:
                              AppConstants.primaryColor.withValues(alpha: 0.22),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                _categoryLabel(key),
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
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

  Widget _buildLessonsSliver(List<Lesson> filtered) {
    if (filtered.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              border: Border.all(color: AppConstants.dividerColor),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search_off_rounded,
                    size: 36,
                    color: AppConstants.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No lessons found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try a different category or search term.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.82,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final lesson = filtered[index];
            return _LessonCard(
              lesson: lesson,
              onTap: () => _onLessonTap(lesson),
            ).animate().fadeIn(duration: 400.ms);
          },
          childCount: filtered.length,
        ),
      ),
    );
  }

  Widget _LessonCard({required Lesson lesson, required VoidCallback onTap}) {
    final progress = lesson.progress.clamp(0.0, 1.0);
    final categoryColor = _getCategoryColor(_lessonCategoryKey(lesson));
    final categoryLabel = _categoryLabel(_lessonCategoryKey(lesson));
    final progressLabel = progress > 0 ? 'Continue' : 'Start here';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppConstants.dividerColor),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: categoryColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            categoryLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: categoryColor,
                            ),
                          ),
                        ),
                        Icon(
                          progress > 0 ? Icons.play_circle : Icons.flag_rounded,
                          size: 18,
                          color: categoryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          lesson.icon,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      lesson.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${lesson.totalSigns} signs',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (progress > 0)
                      Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              backgroundColor: Theme.of(context)
                                  .dividerColor
                                  .withValues(alpha: 0.5),
                              valueColor: AlwaysStoppedAnimation(categoryColor),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(progress * 100).toInt()}% complete · $progressLabel',
                            style: TextStyle(
                              fontSize: 11,
                              color: categoryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$progressLabel',
                          style: TextStyle(
                            fontSize: 11,
                            color: categoryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String categoryKey) {
    switch (categoryKey) {
      case 'alphabets':
        return AppConstants.secondaryColor;
      case 'numbers':
        return AppConstants.accentColor;
      case 'greetings':
        return AppConstants.successColor;
      case 'family':
        return const Color(0xFF8B5CF6);
      case 'food':
        return const Color(0xFFF97316);
      case 'common phrases':
        return const Color(0xFF14B8A6);
      case 'colors':
        return const Color(0xFFEC4899);
      case 'actions':
        return const Color(0xFF6366F1);
      default:
        return AppConstants.primaryColor;
    }
  }

  List<Lesson> _getFilteredLessons() {
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

    return filtered;
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Search Lessons'),
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
