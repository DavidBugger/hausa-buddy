// lib/screens/lessons/lesson_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/audio_provider.dart';
import '../../providers/bookmark_provider.dart';
import '../../models/lesson.dart';
import '../../utils/constants.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/lesson/audio_player_widget.dart';

class LessonDetailScreen extends StatefulWidget {
  final String lessonSlug;

  const LessonDetailScreen({
    Key? key,
    required this.lessonSlug,
  }) : super(key: key);

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _progressController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _progressAnimation;

  final ScrollController _scrollController = ScrollController();
  bool _isBookmarked = false;
  int _currentContentIndex = 0;
  bool _showTranslation = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadLessonData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _progressController, curve: Curves.easeInOut));

    // Start animations
    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeController.forward();
      _slideController.forward();
      _progressController.forward();
    });
  }

  void _loadLessonData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lessonProvider = Provider.of<LessonProvider>(context, listen: false);
      final bookmarkProvider = Provider.of<BookmarkProvider>(context, listen: false);

      lessonProvider.loadLessonDetail(widget.lessonSlug);

      // Check if lesson is bookmarked
      _checkBookmarkStatus();
    });
  }

  void _checkBookmarkStatus() async {
    final lessonProvider = Provider.of<LessonProvider>(context, listen: false);
    final bookmarkProvider = Provider.of<BookmarkProvider>(context, listen: false);

    if (lessonProvider.currentLesson != null) {
      final isBookmarked = bookmarkProvider.isBookmarked(
        AppConstants.lessonContentType,
        lessonProvider.currentLesson!.id,
      );
      setState(() {
        _isBookmarked = isBookmarked;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _progressController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0FDF4), // green-50
              Color(0xFFFFFFFF), // white
            ],
          ),
        ),
        child: Consumer<LessonProvider>(
          builder: (context, lessonProvider, child) {
            if (lessonProvider.isLoadingLessonDetail) {
              return const Center(child: LoadingWidget());
            }

            if (lessonProvider.error != null) {
              return _buildErrorState(lessonProvider.error!);
            }

            final lesson = lessonProvider.currentLesson;
            if (lesson == null) {
              return const Center(child: Text('Lesson not found'));
            }

            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildSliverAppBar(lesson),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLessonInfo(lesson),
                            const SizedBox(height: 24),
                            _buildProgressIndicator(lesson),
                            const SizedBox(height: 24),
                            _buildLessonContent(lesson),
                            const SizedBox(height: 24),
                            _buildVocabularySection(lesson),
                            const SizedBox(height: 24),
                            _buildActionButtons(lesson),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(LessonDetail lesson) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(AppConstants.primaryGreen),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: Colors.white,
          ),
          onPressed: _toggleBookmark,
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () => _shareLesson(lesson),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          lesson.title,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(AppConstants.primaryGreen),
                Color(0xFF16A34A),
              ],
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.book,
              size: 80,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLessonInfo(LessonDetail lesson) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(int.parse('0xFF${lesson.category.color.substring(1)}')).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  lesson.category.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(int.parse('0xFF${lesson.category.color.substring(1)}')),
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(int.parse('0xFF${lesson.difficulty.color.substring(1)}')).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  lesson.difficulty.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(int.parse('0xFF${lesson.difficulty.color.substring(1)}')),
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.schedule,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                '${lesson.estimatedDurationMinutes}min',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            lesson.description,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF374151),
              height: 1.5,
              fontFamily: 'Poppins',
            ),
          ),
          if (lesson.isPremium) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(AppConstants.accentOrange).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: const Color(AppConstants.accentOrange),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Premium Content',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(AppConstants.accentOrange),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(LessonDetail lesson) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        final progress = lesson.lessonContent.isNotEmpty
            ? (_currentContentIndex + 1) / lesson.lessonContent.length
            : 0.0;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lesson Progress',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(AppConstants.darkText),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    '${_currentContentIndex + 1}/${lesson.lessonContent.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(AppConstants.primaryGreen),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress * _progressAnimation.value,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(AppConstants.primaryGreen),
                  ),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLessonContent(LessonDetail lesson) {
    if (lesson.lessonContent.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          lesson.content,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF374151),
            height: 1.5,
            fontFamily: 'Poppins',
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Lesson Content',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(AppConstants.darkText),
                fontFamily: 'Poppins',
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _showTranslation ? Icons.visibility_off : Icons.visibility,
                    color: const Color(AppConstants.primaryGreen),
                  ),
                  onPressed: () {
                    setState(() {
                      _showTranslation = !_showTranslation;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.translate,
                    color: Color(AppConstants.primaryGreen),
                  ),
                  onPressed: () {
                    setState(() {
                      _showTranslation = !_showTranslation;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Content Navigation
        if (lesson.lessonContent.length > 1) ...[
          _buildContentNavigation(lesson),
          const SizedBox(height: 16),
        ],

        // Current Content
        _buildContentCard(lesson.lessonContent[_currentContentIndex]),

        const SizedBox(height: 16),

        // Navigation Buttons
        if (lesson.lessonContent.length > 1) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: _currentContentIndex > 0 ? _previousContent : null,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.grey[700],
                  elevation: 0,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _currentContentIndex < lesson.lessonContent.length - 1
                    ? _nextContent
                    : null,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Next'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(AppConstants.primaryGreen),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildContentNavigation(LessonDetail lesson) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: lesson.lessonContent.length,
        itemBuilder: (context, index) {
          final isActive = index == _currentContentIndex;
          final content = lesson.lessonContent[index];

          return GestureDetector(
            onTap: () {
              setState(() {
                _currentContentIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(AppConstants.primaryGreen)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive
                      ? const Color(AppConstants.primaryGreen)
                      : Colors.grey[300]!,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getContentTypeIcon(content.contentType),
                    color: isActive ? Colors.white : Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContentCard(LessonContent content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content Type Header
          Row(
            children: [
              Icon(
                _getContentTypeIcon(content.contentType),
                color: const Color(AppConstants.primaryGreen),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                _getContentTypeTitle(content.contentType),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(AppConstants.primaryGreen),
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Hausa Text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(AppConstants.primaryGreen).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Hausa',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(AppConstants.primaryGreen),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    if (content.audioFile != null)
                      AudioPlayerWidget(
                        audioUrl: content.audioFile!,
                        title: content.hausaText,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  content.hausaText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(AppConstants.darkText),
                    fontFamily: 'Poppins',
                  ),
                ),
                if (content.pronunciationGuide.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Pronunciation: ${content.pronunciationGuide}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ],
            ),
          ),

          // English Translation
          if (_showTranslation) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(AppConstants.accentOrange).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'English Translation',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(AppConstants.accentOrange),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content.englishTranslation,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(AppConstants.darkText),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Image if available
          if (content.image != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                content.image!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 50),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVocabularySection(LessonDetail lesson) {
    if (lesson.vocabulary.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vocabulary',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(AppConstants.darkText),
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 16),
        ...lesson.vocabulary.map((vocab) => _buildVocabularyCard(vocab)),
      ],
    );
  }

  Widget _buildVocabularyCard(Vocabulary vocab) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vocab.hausaWord,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(AppConstants.primaryGreen),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vocab.englishMeaning,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(AppConstants.darkText),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    if (vocab.pronunciation.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Pronunciation: ${vocab.pronunciation}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (vocab.audioFile != null)
                AudioPlayerWidget(
                  audioUrl: vocab.audioFile!,
                  title: vocab.hausaWord,
                ),
            ],
          ),
          if (vocab.exampleSentenceHausa.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vocab.exampleSentenceHausa,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(AppConstants.darkText),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  if (vocab.exampleSentenceEnglish.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      vocab.exampleSentenceEnglish,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(LessonDetail lesson) {
    return Consumer<LessonProvider>(
      builder: (context, lessonProvider, child) {
        final isCompleted = lessonProvider.isLessonCompleted(lesson.id);

        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isCompleted ? null : () => _markAsCompleted(lesson),
                icon: Icon(
                  isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                ),
                label: Text(isCompleted ? 'Completed' : 'Mark Complete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted
                      ? Colors.grey[300]
                      : const Color(AppConstants.primaryGreen),
                  foregroundColor: isCompleted ? Colors.grey[600] : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _startQuiz(lesson),
                icon: const Icon(Icons.quiz),
                label: const Text('Take Quiz'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading lesson',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(AppConstants.darkText),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadLessonData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  IconData _getContentTypeIcon(String contentType) {
    switch (contentType) {
      case 'text':
        return Icons.text_fields;
      case 'audio':
        return Icons.volume_up;
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.play_circle;
      default:
        return Icons.article;
    }
  }

  String _getContentTypeTitle(String contentType) {
    switch (contentType) {
      case 'text':
        return 'Text Content';
      case 'audio':
        return 'Audio Content';
      case 'image':
        return 'Visual Content';
      case 'video':
        return 'Video Content';
      default:
        return 'Content';
    }
  }

  // Action methods
  void _toggleBookmark() async {
    final lessonProvider = Provider.of<LessonProvider>(context, listen: false);
    final bookmarkProvider = Provider.of<BookmarkProvider>(context, listen: false);

    if (lessonProvider.currentLesson != null) {
      HapticFeedback.lightImpact();

      final success = await bookmarkProvider.toggleBookmark(
        contentType: AppConstants.lessonContentType,
        objectId: lessonProvider.currentLesson!.id,
      );

      if (success) {
        setState(() {
          _isBookmarked = !_isBookmarked;
        });
      }
    }
  }

  void _shareLesson(LessonDetail lesson) {
    // Implement sharing functionality
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  void _previousContent() {
    if (_currentContentIndex > 0) {
      setState(() {
        _currentContentIndex--;
      });
    }
  }

  void _nextContent() {
    final lesson = Provider.of<LessonProvider>(context, listen: false).currentLesson;
    if (lesson != null && _currentContentIndex < lesson.lessonContent.length - 1) {
      setState(() {
        _currentContentIndex++;
      });
    }
  }

  void _markAsCompleted(LessonDetail lesson) async {
    final lessonProvider = Provider.of<LessonProvider>(context, listen: false);

    HapticFeedback.mediumImpact();

    final success = await lessonProvider.markLessonCompleted(
      lesson.id,
      timeSpentMinutes: lesson.estimatedDurationMinutes,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lesson completed! Great job!'),
          backgroundColor: Color(AppConstants.primaryGreen),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to mark lesson as completed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _startQuiz(LessonDetail lesson) {
    // Navigate to quiz for this lesson
    Navigator.pushNamed(context, '/quiz', arguments: lesson.id);
  }
}