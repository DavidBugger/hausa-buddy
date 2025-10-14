import '../models/common.dart';
import '../models/lesson.dart';
import 'api_service.dart';

class LessonService {
  static final LessonService _instance = LessonService._internal();
  factory LessonService() => _instance;
  LessonService._internal();

  final ApiService _apiService = ApiService();

  // Get all categories
  Future<ApiResponse<List<Category>>> getCategories() async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '/lessons/categories/',
      fromJson: (json) => json,
    );

    if (response.isSuccess) {
      final results = response.data!['results'] as List? ?? response.data! as List;
      final categories = results
          .map((item) => Category.fromJson(item as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(categories);
    } else {
      return ApiResponse.error(response.error!);
    }
  }

  // Get lessons with optional filters
  Future<ApiResponse<PaginatedResponse<Lesson>>> getLessons({
    int page = 1,
    int? categoryId,
    int? difficultyId,
    bool? isPremium,
    String? search,
  }) async {
    final Map<String, String> queryParams = {'page': page.toString()};

    if (categoryId != null) queryParams['category'] = categoryId.toString();
    if (difficultyId != null) queryParams['difficulty'] = difficultyId.toString();
    if (isPremium != null) queryParams['is_premium'] = isPremium.toString();
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await _apiService.get<Map<String, dynamic>>(
      '/lessons/',
      queryParams: queryParams,
      fromJson: (json) => json,
    );

    if (response.isSuccess) {
      final data = response.data!;
      final results = data['results'] as List;
      final lessons = results
          .map((item) => Lesson.fromJson(item as Map<String, dynamic>))
          .toList();

      return ApiResponse.success(PaginatedResponse<Lesson>(
        count: data['count'],
        next: data['next'],
        previous: data['previous'],
        totalPages: data['total_pages'],
        currentPage: data['current_page'],
        results: lessons,
      ));
    } else {
      return ApiResponse.error(response.error!);
    }
  }

  // Get lesson details by slug
  Future<ApiResponse<LessonDetail>> getLessonDetail(String slug) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '/lessons/$slug/',
      fromJson: (json) => json,
    );

    if (response.isSuccess) {
      final lessonDetail = LessonDetail.fromJson(response.data!);
      return ApiResponse.success(lessonDetail);
    } else {
      return ApiResponse.error(response.error!);
    }
  }

  // Get vocabulary with optional filters
  Future<ApiResponse<List<Vocabulary>>> getVocabulary({
    int? lessonId,
    String? wordType,
    String? search,
  }) async {
    final Map<String, String> queryParams = {};

    if (lessonId != null) queryParams['lesson'] = lessonId.toString();
    if (wordType != null) queryParams['word_type'] = wordType;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await _apiService.get<Map<String, dynamic>>(
      '/lessons/vocabulary/',
      queryParams: queryParams,
      fromJson: (json) => json,
    );

    if (response.isSuccess) {
      final results = response.data!['results'] as List;
      final vocabulary = results
          .map((item) => Vocabulary.fromJson(item as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(vocabulary);
    } else {
      return ApiResponse.error(response.error!);
    }
  }

  // Mark lesson as completed
  Future<ApiResponse<void>> markLessonCompleted(int lessonId, {
    int? score,
    int timeSpentMinutes = 0,
  }) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '/auth/progress/',
      {
        'lesson': lessonId,
        'completed': true,
        'completion_date': DateTime.now().toIso8601String(),
        'score': score,
        'time_spent_minutes': timeSpentMinutes,
      },
    );

    if (response.isSuccess) {
      return ApiResponse.success(null);
    } else {
      return ApiResponse.error(response.error!);
    }
  }
}
