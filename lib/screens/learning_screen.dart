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
  final ScrollController _categoryScrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _loadLessons();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
    _categoryScrollController.addListener(_updateCategoryScrollIndicators);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _categoryScrollController.removeListener(_updateCategoryScrollIndicators);
    _categoryScrollController.dispose();
    super.dispose();
  }

  void _updateCategoryScrollIndicators() {
    final controller = _categoryScrollController;
    if (!controller.hasClients) return;
    final max = controller.position.maxScrollExtent;
    final offset = controller.offset;
    final canLeft = offset > 4.0;
    final canRight = offset < (max - 4.0);
    if (canLeft != _canScrollLeft || canRight != _canScrollRight) {
      setState(() {
        _canScrollLeft = canLeft;
        _canScrollRight = canRight;
      });
    }
  }

  void _loadLessons() {
    final lessonsById = <String, Lesson>{};
    for (final lesson in MockDataService.getLessons()) {
      lessonsById[lesson.id.trim()] = lesson;
    }
    final lessons = lessonsById.values.toList();
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
          gradient: AppConstants.backgroundGradient,
        ),
        child: Stack(
          children: [
            Positioned(
              right: -36,
              top: 18,
              child: _buildAmbientOrb(
                color: AppConstants.primaryColor.withValues(alpha: 0.09),
                size: 140,
              ),
            ),
            Positioned(
              left: -24,
              top: 190,
              child: _buildAmbientOrb(
                color: AppConstants.accentColor.withValues(alpha: 0.08),
                size: 92,
              ),
            ),
            SafeArea(
              top: false,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                      child: _buildHeroPanel(filteredLessons.length)),
                  SliverToBoxAdapter(child: _buildCategoryFilters()),
                  SliverPadding(
                    padding:
                        const EdgeInsets.only(top: AppConstants.paddingSmall),
                    sliver: _buildLessonsSliver(filteredLessons),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
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
              fontWeight: FontWeight.w800,
              color: AppConstants.primaryColor,
              fontSize: 20,
              letterSpacing: -0.2,
            ),
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
      margin: const EdgeInsets.fromLTRB(
        AppConstants.paddingMedium,
        AppConstants.paddingSmall,
        AppConstants.paddingMedium,
        AppConstants.paddingSmall,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).cardColor,
            AppConstants.primaryColor.withValues(alpha: 0.055),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: AppConstants.dividerColor.withValues(alpha: 0.88)),
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppConstants.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.primaryColor.withValues(alpha: 0.22),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white,
                  size: 28,
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
                        fontSize: 24,
                        height: 1.05,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pick a category, open a lesson, and start building your sign vocabulary.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.38,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildHeroStatChip(
                '$visibleLessons lessons ready to browse',
                AppConstants.primaryColor,
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
      height: 60,
      child: Stack(
        children: [
          ListView.separated(
            controller: _categoryScrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final key = categories[index];
              final isSelected = key == _selectedCategory;

              return Semantics(
                label: 'Category ${_categoryLabel(key)}',
                button: true,
                selected: isSelected,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 72),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppConstants.primaryColor
                          : Theme.of(context).cardColor,
                      gradient:
                          isSelected ? AppConstants.primaryGradient : null,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : AppConstants.dividerColor,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppConstants.primaryColor
                                    .withValues(alpha: 0.16),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : [],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => setState(() => _selectedCategory = key),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          child: Center(
                            child: Text(
                              _categoryLabel(key),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Left fade
          if (_canScrollLeft)
            Positioned(
              left: AppConstants.paddingMedium - 6,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                ignoring: true,
                child: Container(
                  width: 28,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Theme.of(context).scaffoldBackgroundColor,
                        Theme.of(context)
                            .scaffoldBackgroundColor
                            .withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // Right fade + arrow
          Positioned(
            right: AppConstants.paddingMedium - 6,
            top: 0,
            bottom: 0,
            child: Row(
              children: [
                IgnorePointer(
                  ignoring: true,
                  child: Container(
                    width: 28,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          Theme.of(context).scaffoldBackgroundColor,
                          Theme.of(context)
                              .scaffoldBackgroundColor
                              .withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_canScrollRight)
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Material(
                      color: Theme.of(context).cardColor.withOpacity(0.9),
                      elevation: 2,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          // Jump a bit to the right when arrow tapped
                          final controller = _categoryScrollController;
                          final target = (controller.offset + 120)
                              .clamp(0.0, controller.position.maxScrollExtent);
                          controller.animateTo(target,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease);
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
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
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppConstants.dividerColor),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
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
                    size: AppConstants.iconSizeXL,
                    color: AppConstants.primaryColor,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                Text(
                  'No lessons found',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try a different category or search term.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeSmall,
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
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 1000
        ? 4
        : width >= 700
            ? 3
            : 2;
    final childAspect = width >= 700 ? 0.88 : 0.86;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 14),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspect,
          crossAxisSpacing: 9,
          mainAxisSpacing: 9,
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
    final progressLabel = progress > 0 ? 'Continue' : 'Start here';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).cardColor,
              categoryColor.withValues(alpha: 0.02),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppConstants.dividerColor.withValues(alpha: 0.78)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: -18,
              top: -18,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: categoryColor.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              left: -14,
              bottom: -22,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: categoryColor.withValues(alpha: 0.03),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        categoryColor.withValues(alpha: 0.78),
                        categoryColor.withValues(alpha: 0.28),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: categoryColor.withValues(alpha: 0.09),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                progress > 0
                                    ? Icons.play_arrow_rounded
                                    : Icons.bookmark_border_rounded,
                                size: 15,
                                color: categoryColor,
                              ),
                            ),
                            Text(
                              '${lesson.totalSigns}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: categoryColor.withValues(alpha: 0.09),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: categoryColor.withValues(alpha: 0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                lesson.icon,
                                style: const TextStyle(fontSize: 21),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          lesson.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          lesson.description,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            height: 1.25,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          height: 32,
                          child: Center(
                            child: progress > 0
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          minHeight: 5,
                                          backgroundColor: Theme.of(context)
                                              .dividerColor
                                              .withValues(alpha: 0.5),
                                          valueColor: AlwaysStoppedAnimation(
                                              categoryColor),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${(progress * 100).toInt()}% complete',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: categoryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(
                                      color:
                                          categoryColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      progressLabel,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: categoryColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmbientOrb({required Color color, required double size}) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0.0)],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroStatChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getCategoryColor(String categoryKey) {
    switch (categoryKey) {
      case 'alphabets':
        return const Color(0xFF4F7DF0);
      case 'numbers':
        return const Color(0xFFE0A93B);
      case 'greetings':
        return const Color(0xFF2EAD84);
      case 'family':
        return const Color(0xFF8E72E6);
      case 'food':
        return const Color(0xFFEA8135);
      case 'common phrases':
        return const Color(0xFF1FA99A);
      case 'colors':
        return const Color(0xFFDD5D9A);
      case 'actions':
        return const Color(0xFF6B7CF0);
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

    final uniqueLessons = <String, Lesson>{};
    for (final lesson in filtered) {
      uniqueLessons[lesson.id.trim()] = lesson;
    }

    return uniqueLessons.values.toList();
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
