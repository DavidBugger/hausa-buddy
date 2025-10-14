import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/bookmark_provider.dart';
import '../../providers/lesson_provider.dart';
import '../../models/bookmark.dart';
import '../../widgets/lesson/lesson_card.dart';
import '../../utils/constants.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({Key? key}) : super(key: key);

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _staggerController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _staggerAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadBookmarks();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
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
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _staggerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _staggerController,
      curve: Curves.easeOut,
    ));

    // Start animations
    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeController.forward();
      _slideController.forward();
      _staggerController.forward();
    });
  }

  void _loadBookmarks() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookmarkProvider = Provider.of<BookmarkProvider>(context, listen: false);
      bookmarkProvider.loadBookmarks();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Bookmarks',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(AppConstants.primaryGreen),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
        child: Consumer<BookmarkProvider>(
          builder: (context, bookmarkProvider, child) {
            if (bookmarkProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(AppConstants.primaryGreen),
                ),
              );
            }

            final bookmarkedLessons = bookmarkProvider.bookmarkedLessons;

            if (bookmarkedLessons.isEmpty) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildEmptyState(),
                ),
              );
            }

            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(AppConstants.primaryGreen).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.bookmark_outline,
                              color: Color(AppConstants.primaryGreen),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${bookmarkedLessons.length} Saved ${bookmarkedLessons.length == 1 ? 'Lesson' : 'Lessons'}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(AppConstants.darkText),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Your saved content for quick access',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bookmarked Lessons List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: bookmarkedLessons.length,
                        itemBuilder: (context, index) {
                          return AnimatedBuilder(
                            animation: _staggerAnimation,
                            builder: (context, child) {
                              final delay = index * 0.1;
                              final itemAnimation = Tween<double>(
                                begin: 0.0,
                                end: 1.0,
                              ).animate(
                                CurvedAnimation(
                                  parent: _staggerController,
                                  curve: Interval(
                                    delay.clamp(0.0, 1.0),
                                    (delay + 0.6).clamp(0.0, 1.0),
                                    curve: Curves.easeOut,
                                  ),
                                ),
                              );

                              return Transform.scale(
                                scale: 0.8 + (itemAnimation.value * 0.2),
                                child: Opacity(
                                  opacity: itemAnimation.value,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _buildBookmarkCard(bookmarkedLessons[index]),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(AppConstants.primaryGreen).withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.bookmark_border,
              size: 64,
              color: Color(AppConstants.primaryGreen),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Bookmarks Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(AppConstants.darkText),
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Save lessons and content you want to revisit later by tapping the bookmark icon.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Browse Lessons'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppConstants.primaryGreen),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkCard(Bookmark bookmark) {
    // Extract lesson details from contentDetails if available
    final contentDetails = bookmark.contentDetails ?? {};
    final lessonTitle = bookmark.contentTitle ?? 'Unknown Lesson';
    final categoryName = contentDetails['category_name'] ?? 'General';
    final difficulty = contentDetails['difficulty'] ?? 'Beginner';
    final estimatedDuration = contentDetails['estimated_duration_minutes'] ?? 5;
    final rating = contentDetails['rating'] ?? 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Lesson Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(AppConstants.primaryGreen),
                    Color(0xFF16A34A),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getLessonIcon(categoryName),
                color: Colors.white,
                size: 28,
              ),
            ),

            const SizedBox(width: 16),

            // Lesson Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lessonTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(AppConstants.darkText),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$categoryName • $difficulty',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$estimatedDuration min',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${rating.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    final bookmarkProvider = Provider.of<BookmarkProvider>(context, listen: false);
                    bookmarkProvider.toggleBookmark(
                      contentType: bookmark.contentType,
                      objectId: bookmark.objectId,
                    );
                    HapticFeedback.lightImpact();
                  },
                  icon: const Icon(
                    Icons.bookmark,
                    color: Color(AppConstants.primaryGreen),
                  ),
                ),
                TextButton(
                  onPressed: () => _navigateToContent(bookmark),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      color: Color(AppConstants.primaryGreen),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
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

  IconData _getLessonIcon(String category) {
    switch (category.toLowerCase()) {
      case 'grammar':
        return Icons.language;
      case 'vocabulary':
        return Icons.translate;
      case 'pronunciation':
        return Icons.record_voice_over;
      case 'culture':
        return Icons.people;
      default:
        return Icons.book;
    }
  }

  void _navigateToContent(Bookmark bookmark) {
    switch (bookmark.contentType) {
      case 'lesson':
        Navigator.pushNamed(context, '/lesson/${bookmark.objectId}');
        break;
      case 'vocabulary':
        Navigator.pushNamed(context, '/vocabulary/${bookmark.objectId}');
        break;
      case 'phrase':
        Navigator.pushNamed(context, '/phrase/${bookmark.objectId}');
        break;
      default:
        // Fallback to lesson route
        Navigator.pushNamed(context, '/lesson/${bookmark.objectId}');
    }
  }
}