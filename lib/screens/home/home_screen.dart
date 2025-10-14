// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/bookmark_provider.dart';
import '../../models/lesson.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/lesson/lesson_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _progressController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _progressAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.forward();
      _slideController.forward();
      _progressController.forward();
    });
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final lessonProvider = Provider.of<LessonProvider>(context, listen: false);
      final bookmarkProvider = Provider.of<BookmarkProvider>(context, listen: false);

      // Load user statistics
      authProvider.loadUserStatistics();

      // Initialize providers if not already done
      lessonProvider.initialize();
      bookmarkProvider.initialize();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshData,
            color: const Color(AppConstants.primaryGreen),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildDailyTip(),
                      const SizedBox(height: 24),
                      _buildProgressSection(),
                      const SizedBox(height: 24),
                      _buildQuickActions(),
                      const SizedBox(height: 24),
                      _buildContinueLearning(),
                      const SizedBox(height: 24),
                      _buildRecentLessons(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        if (user == null) return const SizedBox.shrink();

        return Row(
          children: [
            // Profile Picture
            GestureDetector(
              onTap: () => _navigateToProfile(),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(AppConstants.primaryGreen),
                      Color(0xFF16A34A),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(AppConstants.primaryGreen).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: user.profilePicture != null
                    ? ClipOval(
                  child: Image.network(
                    user.profilePicture!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildInitialsAvatar(user);
                    },
                  ),
                )
                    : _buildInitialsAvatar(user),
              ),
            ),

            const SizedBox(width: 16),

            // Welcome Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.firstName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(AppConstants.darkText),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),

            // Streak Counter
            _buildStreakCounter(user.learningStreak),
          ],
        );
      },
    );
  }

  Widget _buildInitialsAvatar(user) {
    return Center(
      child: Text(
        user.initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildStreakCounter(int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(AppConstants.accentOrange).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(AppConstants.accentOrange).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department,
            color: Color(AppConstants.accentOrange),
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(AppConstants.accentOrange),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFDCFCE7), // green-100
            Color(0xFFBBF7D0), // green-200
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(AppConstants.primaryGreen).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(AppConstants.primaryGreen).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: Color(AppConstants.primaryGreen),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Daily Tip',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(AppConstants.primaryGreen),
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Sannu! In Hausa, "Sannu" means hello and is used as a general greeting. Practice using it in different contexts throughout your day.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF374151),
              height: 1.5,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(AppConstants.primaryGreen).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '🎯 Cultural Tip',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(AppConstants.primaryGreen),
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Consumer2<AuthProvider, LessonProvider>(
      builder: (context, authProvider, lessonProvider, child) {
        final statistics = authProvider.statistics;
        final completedLessons = lessonProvider.completedLessonsCount;
        final totalStudyTime = lessonProvider.totalStudyTimeMinutes;

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
              const Text(
                'Your Progress',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(AppConstants.darkText),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 16),

              // Progress Cards
              Row(
                children: [
                  Expanded(
                    child: _buildProgressCard(
                      'Lessons',
                      completedLessons.toString(),
                      Icons.book_outlined,
                      const Color(AppConstants.primaryGreen),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildProgressCard(
                      'Study Time',
                      AppHelpers.formatDuration(totalStudyTime),
                      Icons.schedule,
                      const Color(AppConstants.accentOrange),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildProgressCard(
                      'Quiz Score',
                      '${(statistics?.quizStatistics.averageScore ?? 0).toStringAsFixed(0)}%',
                      Icons.quiz_outlined,
                      const Color(0xFF3B82F6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildProgressCard(
                      'Total Points',
                      (authProvider.user?.totalPoints ?? 0).toString(),
                      Icons.stars,
                      const Color(0xFF8B5CF6),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Weekly Progress Chart
              _buildWeeklyProgress(statistics?.weeklyLessons ?? 0),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressCard(String title, String value, IconData icon, Color color) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_progressAnimation.value * 0.2),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.8),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeeklyProgress(int weeklyLessons) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final progress = List.generate(7, (index) => index < weeklyLessons ? 1.0 : 0.3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'This Week',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(AppConstants.darkText),
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: days.asMap().entries.map((entry) {
            final index = entry.key;
            final day = entry.value;
            return AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32 * progress[index] * _progressAnimation.value,
                      decoration: BoxDecoration(
                        color: progress[index] > 0.5
                            ? const Color(AppConstants.primaryGreen)
                            : const Color(AppConstants.primaryGreen).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      day,
                      style: TextStyle(
                        fontSize: 12,
                        color: progress[index] > 0.5
                            ? const Color(AppConstants.primaryGreen)
                            : const Color(0xFF6B7280),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(AppConstants.darkText),
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Practice Quiz',
                'Test your knowledge',
                Icons.quiz,
                const Color(0xFF3B82F6),
                    () => _navigateToQuiz(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'AI Chat',
                'Practice conversation',
                Icons.chat_bubble_outline,
                const Color(0xFF8B5CF6),
                    () => _navigateToChat(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Vocabulary',
                'Learn new words',
                Icons.translate,
                const Color(AppConstants.accentOrange),
                    () => _navigateToVocabulary(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Bookmarks',
                'Saved content',
                Icons.bookmark_outline,
                const Color(0xFFEF4444),
                    () => _navigateToBookmarks(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
      String title,
      String subtitle,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueLearning() {
    return Consumer<LessonProvider>(
      builder: (context, lessonProvider, child) {
        if (lessonProvider.isLoading) {
          return const LoadingWidget();
        }

        // Find the next incomplete lesson
        final nextLesson = lessonProvider.lessons
            .where((lesson) => !lessonProvider.isLessonCompleted(lesson.id))
            .firstOrNull;

        if (nextLesson == null) {
          return _buildCompletedAllLessons();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(AppConstants.primaryGreen),
                Color(0xFF16A34A),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(AppConstants.primaryGreen).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Continue Learning',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                nextLesson.title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${nextLesson.categoryName} • ${AppHelpers.formatDuration(nextLesson.estimatedDurationMinutes)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _navigateToLesson(nextLesson.slug),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(AppConstants.primaryGreen),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompletedAllLessons() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFDCFCE7),
            Color(0xFFBBF7D0),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.celebration,
            size: 48,
            color: Color(AppConstants.primaryGreen),
          ),
          const SizedBox(height: 12),
          const Text(
            'Congratulations!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(AppConstants.primaryGreen),
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You\'ve completed all available lessons. Keep practicing with quizzes and AI chat!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF374151),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentLessons() {
    return Consumer<LessonProvider>(
      builder: (context, lessonProvider, child) {
        if (lessonProvider.isLoading) {
          return const LoadingWidget();
        }

        final recentLessons = lessonProvider.lessons.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Lessons',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(AppConstants.darkText),
                    fontFamily: 'Poppins',
                  ),
                ),
                TextButton(
                  onPressed: () => _navigateToLessons(),
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: Color(AppConstants.primaryGreen),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recentLessons.map((lesson) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: LessonCard(
                lesson: lesson,
                isCompleted: lessonProvider.isLessonCompleted(lesson.id),
                onTap: () => _navigateToLesson(lesson.slug),
              ),
            )).toList(),
          ],
        );
      },
    );
  }

  // Helper methods
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning!';
    } else if (hour < 17) {
      return 'Good afternoon!';
    } else {
      return 'Good evening!';
    }
  }

  Future<void> _refreshData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final lessonProvider = Provider.of<LessonProvider>(context, listen: false);
    final bookmarkProvider = Provider.of<BookmarkProvider>(context, listen: false);

    await Future.wait([
      authProvider.refreshUserData(),
      authProvider.loadUserStatistics(),
      lessonProvider.loadLessons(refresh: true),
      lessonProvider.loadUserProgress(),
      bookmarkProvider.loadBookmarks(),
    ]);

    HapticFeedback.lightImpact();
  }

  // Navigation methods
  void _navigateToProfile() {
    Navigator.pushNamed(context, '/profile');
  }

  void _navigateToQuiz() {
    Navigator.pushNamed(context, '/quiz');
  }

  void _navigateToChat() {
    Navigator.pushNamed(context, '/chat');
  }

  void _navigateToVocabulary() {
    Navigator.pushNamed(context, '/vocabulary');
  }

  void _navigateToBookmarks() {
    Navigator.pushNamed(context, '/bookmarks');
  }

  void _navigateToLessons() {
    Navigator.pushNamed(context, '/lessons');
  }

  void _navigateToLesson(String lessonSlug) {
    Navigator.pushNamed(context, '/lesson/$lessonSlug');
  }
}