import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/lesson_service.dart';
import '../services/database_service.dart';

class LessonProvider with ChangeNotifier {
  final LessonService _lessonService = LessonService();
  final DatabaseService _databaseService = DatabaseService();

  List<Category> _categories = [];
  List<Lesson> _lessons = [];
  LessonDetail? _currentLesson;
  List<UserProgress> _userProgress = [];

  bool _isLoading = false;
  bool _isLoadingLessons = false;
  bool _isLoadingLessonDetail = false;
  String? _error;

  // Pagination
  int _currentPage = 1;
  bool _hasMoreLessons = true;

  // Filters
  int? _selectedCategoryId;
  int? _selectedDifficultyId;
  bool? _isPremiumFilter;
  String? _searchQuery;

  // Getters
  List<Category> get categories => _categories;
  List<Lesson> get lessons => _lessons;
  LessonDetail? get currentLesson => _currentLesson;
  List<UserProgress> get userProgress => _userProgress;
  bool get isLoading => _isLoading;
  bool get isLoadingLessons => _isLoadingLessons;
  bool get isLoadingLessonDetail => _isLoadingLessonDetail;
  String? get error => _error;
  bool get hasMoreLessons => _hasMoreLessons;

  // Filter getters
  int? get selectedCategoryId => _selectedCategoryId;
  int? get selectedDifficultyId => _selectedDifficultyId;
  bool? get isPremiumFilter => _isPremiumFilter;
  String? get searchQuery => _searchQuery;

  // Initialize lesson data
  Future<void> initialize() async {
    _setLoading(true);
    try {
      // Load cached data first
      await _loadCachedData();

      // Then refresh from server
      await Future.wait([
        loadCategories(),
        loadLessons(refresh: true),
        loadUserProgress(),
      ]);
    } catch (e) {
      _setError('Failed to initialize lessons: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load cached data
  Future<void> _loadCachedData() async {
    final cachedCategories = _databaseService.getCachedCategories();
    if (cachedCategories != null) {
      _categories = cachedCategories;
      notifyListeners();
    }

    final cachedLessons = _databaseService.getCachedLessons();
    if (cachedLessons != null) {
      _lessons = cachedLessons;
      notifyListeners();
    }

    final cachedProgress = _databaseService.getCachedProgress();
    _userProgress = cachedProgress;
    notifyListeners();
  }

  // Load categories
  Future<void> loadCategories() async {
    try {
      final response = await _lessonService.getCategories();
      if (response.isSuccess) {
        _categories = response.data!;
        await _databaseService.saveCategories(_categories);
        notifyListeners();
      }
    } catch (e) {
      print('Failed to load categories: $e');
    }
  }

  // Load lessons with pagination
  Future<void> loadLessons({
    bool refresh = false,
    bool loadMore = false,
  }) async {
    if (_isLoadingLessons) return;

    if (refresh) {
      _currentPage = 1;
      _hasMoreLessons = true;
    }

    if (!_hasMoreLessons && loadMore) return;

    _setLoadingLessons(true);
    _clearError();

    try {
      final response = await _lessonService.getLessons(
        page: loadMore ? _currentPage + 1 : _currentPage,
        categoryId: _selectedCategoryId,
        difficultyId: _selectedDifficultyId,
        isPremium: _isPremiumFilter,
        search: _searchQuery,
      );

      if (response.isSuccess) {
        final paginatedResponse = response.data!;

        if (refresh || !loadMore) {
          _lessons = paginatedResponse.results;
        } else {
          _lessons.addAll(paginatedResponse.results);
        }

        _currentPage = paginatedResponse.currentPage;
        _hasMoreLessons = paginatedResponse.hasNext;

        // Cache lessons
        await _databaseService.saveLessons(_lessons);

        notifyListeners();
      } else {
        _setError(response.error!);
      }
    } catch (e) {
      _setError('Failed to load lessons: ${e.toString()}');
    } finally {
      _setLoadingLessons(false);
    }
  }

  // Load lesson detail
  Future<void> loadLessonDetail(String slug) async {
    _setLoadingLessonDetail(true);
    _clearError();

    try {
      final response = await _lessonService.getLessonDetail(slug);
      if (response.isSuccess) {
        _currentLesson = response.data!;
        notifyListeners();
      } else {
        _setError(response.error!);
      }
    } catch (e) {
      _setError('Failed to load lesson: ${e.toString()}');
    } finally {
      _setLoadingLessonDetail(false);
    }
  }

  // Load user progress
  Future<void> loadUserProgress() async {
    try {
      final authService = AuthService();
      final response = await authService.getUserProgress();
      if (response.isSuccess) {
        _userProgress = response.data!;
        await _databaseService.saveProgress(_userProgress);
        notifyListeners();
      }
    } catch (e) {
      print('Failed to load user progress: $e');
    }
  }

  // Mark lesson as completed
  Future<bool> markLessonCompleted(int lessonId, {
    int? score,
    int timeSpentMinutes = 0,
  }) async {
    try {
      final response = await _lessonService.markLessonCompleted(
        lessonId,
        score: score,
        timeSpentMinutes: timeSpentMinutes,
      );

      if (response.isSuccess) {
        // Update local progress
        final progressIndex = _userProgress.indexWhere(
              (progress) => progress.lessonId == lessonId,
        );

        final newProgress = UserProgress(
          id: progressIndex >= 0 ? _userProgress[progressIndex].id : 0,
          lessonId: lessonId,
          lessonTitle: _lessons
              .where((lesson) => lesson.id == lessonId)
              .firstOrNull
              ?.title ?? '',
          completed: true,
          completionDate: DateTime.now(),
          score: score,
          timeSpentMinutes: timeSpentMinutes,
        );

        if (progressIndex >= 0) {
          _userProgress[progressIndex] = newProgress;
        } else {
          _userProgress.add(newProgress);
        }

        await _databaseService.saveProgress(_userProgress);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to mark lesson completed: $e');
      return false;
    }
  }

  // Check if lesson is completed
  bool isLessonCompleted(int lessonId) {
    return _userProgress.any(
          (progress) => progress.lessonId == lessonId && progress.completed,
    );
  }

  // Get lesson progress percentage
  double getLessonProgress(int lessonId) {
    final progress = _userProgress
        .where((p) => p.lessonId == lessonId && p.completed)
        .firstOrNull;
    return progress != null ? 1.0 : 0.0;
  }

  // Filter methods
  void setCategoryFilter(int? categoryId) {
    if (_selectedCategoryId != categoryId) {
      _selectedCategoryId = categoryId;
      loadLessons(refresh: true);
    }
  }

  void setDifficultyFilter(int? difficultyId) {
    if (_selectedDifficultyId != difficultyId) {
      _selectedDifficultyId = difficultyId;
      loadLessons(refresh: true);
    }
  }

  void setPremiumFilter(bool? isPremium) {
    if (_isPremiumFilter != isPremium) {
      _isPremiumFilter = isPremium;
      loadLessons(refresh: true);
    }
  }

  void setSearchQuery(String? query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      loadLessons(refresh: true);
    }
  }

  void clearFilters() {
    _selectedCategoryId = null;
    _selectedDifficultyId = null;
    _isPremiumFilter = null;
    _searchQuery = null;
    loadLessons(refresh: true);
  }

  // Get filtered lessons by category
  List<Lesson> getLessonsByCategory(int categoryId) {
    return _lessons.where((lesson) => lesson.categoryName ==
        _categories.firstWhere((cat) => cat.id == categoryId).name).toList();
  }

  // Get completed lessons count
  int get completedLessonsCount {
    return _userProgress.where((progress) => progress.completed).length;
  }

  // Get total study time
  int get totalStudyTimeMinutes {
    return _userProgress.fold(0, (sum, progress) => sum + progress.timeSpentMinutes);
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingLessons(bool loading) {
    _isLoadingLessons = loading;
    notifyListeners();
  }

  void _setLoadingLessonDetail(bool loading) {
    _isLoadingLessonDetail = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}