import '../models/quiz.dart';
import 'api_service.dart';

class QuizService {
  static final QuizService _instance = QuizService._internal();
  factory QuizService() => _instance;
  QuizService._internal();

  final ApiService _apiService = ApiService();

  // Get all quizzes
  Future<ApiResponse<List<Quiz>>> getQuizzes() async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '/quizzes/',
      fromJson: (json) => json,
    );

    if (response.isSuccess) {
      final results = response.data!['results'] as List;
      final quizzes = results
          .map((item) => Quiz.fromJson(item as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(quizzes);
    } else {
      return ApiResponse.error(response.error!);
    }
  }

  // Get quiz details
  Future<ApiResponse<QuizDetail>> getQuizDetail(int quizId) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '/quizzes/$quizId/',
      fromJson: (json) => json,
    );

    if (response.isSuccess) {
      final quizDetail = QuizDetail.fromJson(response.data!);
      return ApiResponse.success(quizDetail);
    } else {
      return ApiResponse.error(response.error!);
    }
  }

  // Start quiz attempt
  Future<ApiResponse<QuizAttempt>> startQuizAttempt(int quizId) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '/quizzes/$quizId/start/',
      {},
      fromJson: (json) => json,
    );

    if (response.isSuccess) {
      final attemptData = response.data!['attempt'];
      final attempt = QuizAttempt.fromJson(attemptData);
      return ApiResponse.success(attempt);
    } else {
      return ApiResponse.error(response.error!);
    }
  }

  // Submit quiz answers
  Future<ApiResponse<QuizResult>> submitQuiz(
      int attemptId,
      List<UserAnswer> answers,
      int timeSpentMinutes,
      ) async {
    final answersJson = answers.map((answer) => answer.toJson()).toList();

    final response = await _apiService.post<Map<String, dynamic>>(
      '/quizzes/attempt/$attemptId/submit/',
      {
        'answers': answersJson,
        'time_taken_minutes': timeSpentMinutes,
      },
      fromJson: (json) => json,
    );

    if (response.isSuccess) {
      final result = QuizResult.fromJson(response.data!);
      return ApiResponse.success(result);
    } else {
      return ApiResponse.error(response.error!);
    }
  }

  // Get user's quiz attempts
  Future<ApiResponse<List<QuizAttempt>>> getUserQuizAttempts() async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '/quizzes/attempts/',
      fromJson: (json) => json,
    );

    if (response.isSuccess) {
      final results = response.data!['results'] as List;
      final attempts = results
          .map((item) => QuizAttempt.fromJson(item as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(attempts);
    } else {
      return ApiResponse.error(response.error!);
    }
  }
}