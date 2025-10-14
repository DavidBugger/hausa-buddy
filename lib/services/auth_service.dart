import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();

  // Register new user
  Future<ApiResponse<AuthResult>> register({
    required String email,
    required String username,
    required String firstName,
    required String lastName,
    required String password,
    required String passwordConfirm,
  }) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '/auth/register/',
      {
        'email': email,
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
        'password': password,
        'password_confirm': passwordConfirm,
      },
      fromJson: (json) => json, // Pass identity function to get raw JSON
    );

    if (response.isSuccess) {
      final data = response.data!;
      final user = User.fromJson(Map<String, dynamic>.from(data['user']));
      return ApiResponse.success(AuthResult(
        user: user,
        accessToken: data['access'] as String? ?? '',
        refreshToken: data['refresh'] as String? ?? '',
        message: data['message'] as String? ?? 'Registration successful',
      ));
    } else {
      return ApiResponse.error(response.error!);
    }
  }

  // Login user
  Future<ApiResponse<AuthResult>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '/auth/login/',
      {
        'email': email,
        'password': password,
      },
      fromJson: (json) => json, // Pass identity function to get raw JSON
    );

    if (response.isSuccess) {
      final data = response.data!;
      final user = User.fromJson(Map<String, dynamic>.from(data['user']));
      return ApiResponse.success(AuthResult(
        user: user,
        accessToken: data['access'] as String? ?? '',
        refreshToken: data['refresh'] as String? ?? '',
        message: data['message'] as String? ?? 'Login successful',
      ));
    } else {
      return ApiResponse.error(response.error!);
    }
  }

  Future<ApiResponse<User>> getCurrentUser() async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '/auth/profile/',
      fromJson: (json) => json,
    );

    if (response.isSuccess) {
      final user = User.fromJson(response.data!);
      return ApiResponse.success(user);
    } else {
      return ApiResponse.error(response.error!);
    }
  }

  // Update user profile
  Future<ApiResponse<User>> updateProfile({
    String? firstName,
    String? lastName,
    String? bio,
    String? learningGoal,
    int? dailyGoalMinutes,
    bool? notificationsEnabled,
  }) async {
    final Map<String, dynamic> data = {};

    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    if (bio != null) data['profile'] = {'bio': bio};
    if (learningGoal != null) data['profile'] = {...(data['profile'] ?? {}), 'learning_goal': learningGoal};
    if (dailyGoalMinutes != null) data['profile'] = {...(data['profile'] ?? {}), 'daily_goal_minutes': dailyGoalMinutes};
    if (notificationsEnabled != null) data['profile'] = {...(data['profile'] ?? {}), 'notifications_enabled': notificationsEnabled};

      final response = await _apiService.put<Map<String, dynamic>>(
      '/auth/profile/',
      data,
      fromJson: (json) => json,
    );

    if (response.isSuccess) {
      final user = User.fromJson(response.data!);
      return ApiResponse.success(user);
    } else {
      return ApiResponse.error(response.error!);
    }
  }

  // Get user progress
  Future<ApiResponse<List<UserProgress>>> getUserProgress() async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '/auth/progress/',
      fromJson: (json) => json,
    );

    if (response.isSuccess) {
      final results = response.data!['results'] as List;
      final progressList = results
          .map((item) => UserProgress.fromJson(item as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(progressList);
    } else {
      return ApiResponse.error(response.error!);
    }
  }

  // Get user statistics
  Future<ApiResponse<UserStatistics>> getUserStatistics() async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '/auth/statistics/',
      fromJson: (json) => json,
    );

    if (response.isSuccess) {
      final stats = UserStatistics.fromJson(response.data!);
      return ApiResponse.success(stats);
    } else {
      return ApiResponse.error(response.error!);
    }
  }

  // Logout
  Future<void> logout() async {
    await _apiService.clearTokens();
  }

  // Check if user is authenticated
  bool get isAuthenticated => _apiService.isAuthenticated;
}

// Auth result model
class AuthResult {
  final User user;
  final String accessToken;
  final String refreshToken;
  final String message;

  AuthResult({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.message,
  });
}