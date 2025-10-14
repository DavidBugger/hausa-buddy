import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';
import '../services/biometric_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final BiometricService _biometricService = BiometricService();

  User? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;
  UserStatistics? _statistics;

  AuthProvider() {
    // Initialize when the provider is created
    initialize();
  }

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  UserStatistics? get statistics => _statistics;

  // Initialize authentication state
  Future<void> initialize() async {
    if (_isInitialized) return;

    _setLoading(true);
    try {
      // Ensure DatabaseService is initialized
      await _databaseService.initialize();

      // Check for cached user data
      _user = _databaseService.getUser();

      if (_user != null && _authService.isAuthenticated) {
        // Refresh user data from server
        await refreshUserData();
      }

      _isInitialized = true;
    } catch (e) {
      _setError('Failed to initialize authentication: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Register new user
  Future<bool> register({
    required String email,
    required String username,
    required String firstName,
    required String lastName,
    required String password,
    required String passwordConfirm,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      print('🔄 Attempting registration...');
      print('📧 Email: $email');
      print('👤 Name: $firstName $lastName');
      print('🔗 Username: $username');

      final response = await _authService.register(
        email: email,
        username: username,
        firstName: firstName,
        lastName: lastName,
        password: password,
        passwordConfirm: passwordConfirm,
      );

      print('📡 Registration API Response:');
      print('✅ Success: ${response.isSuccess}');
      if (response.isSuccess) {
        print('🎉 Registration successful!');
        print('📝 Message: ${response.data?.message}');
        final authResult = response.data!;
        await _handleSuccessfulAuth(authResult);
        print('✅ Returning true from register method');
        return true;
      } else {
        print('❌ Registration failed: ${response.error}');
        _setError(response.error!);
        return false;
      }
    } catch (e) {
      print('💥 Registration exception: $e');
      _setError('Registration failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      print('🔐 Attempting login...');
      print('📧 Email: $email');

      final response = await _authService.login(
        email: email,
        password: password,
      );

      print('📡 Login API Response:');
      print('✅ Success: ${response.isSuccess}');
      if (response.isSuccess) {
        print('🎉 Login successful!');
        print('📝 Message: ${response.data?.message}');
        final authResult = response.data!;
        await _handleSuccessfulAuth(authResult, email: email, password: password);
        return true;
      } else {
        print('❌ Login failed: ${response.error}');
        _setError(response.error!);
        return false;
      }
    } catch (e) {
      print('💥 Login exception: $e');
      _setError('Login failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Biometric login - simplified version that checks availability only
  Future<bool> loginWithBiometrics() async {
    _setLoading(true);
    _clearError();

    try {
      print('🔐 Attempting biometric login...');

      // Check if biometrics are available
      final bool isAvailable = await _biometricService.isBiometricAvailable();
      if (!isAvailable) {
        _setError('Biometric authentication is not available on this device');
        return false;
      }

      // Check if user has enrolled biometrics
      final bool hasEnrolled = await _biometricService.hasEnrolledBiometrics();
      if (!hasEnrolled) {
        _setError('No biometrics enrolled. Please set up fingerprint or Face ID in device settings');
        return false;
      }

      // Get available biometric type name
      final String biometricType = await getBiometricTypeName();

      print('📱 Available biometric: $biometricType');

      // Return true to indicate biometrics are available - actual authentication will be handled by UI
      // The UI layer will handle the actual authentication with proper context
      return true;
    } catch (e) {
      print('💥 Biometric login preparation failed: $e');
      _setError('Biometric login preparation failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check if biometric login is available
  Future<bool> isBiometricLoginAvailable() async {
    try {
      final bool available = await _biometricService.isBiometricAvailable();
      final bool enrolled = await _biometricService.hasEnrolledBiometrics();
      return available && enrolled;
    } catch (e) {
      print('Failed to check biometric availability: $e');
      return false;
    }
  }

  // Check if user has logged in before (has cached session) - Async version for authentication
  Future<bool> hasCachedUserSessionAsync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final biometricEnabled = prefs.getBool('biometric_enabled') ?? false;

      if (biometricEnabled) {
        // Check if user data exists in database
        final user = _databaseService.getUser();
        return user != null;
      }

      return false;
    } catch (e) {
      print('Error checking cached user session async: $e');
      return false;
    }
  }

  // Check if user has logged in before (has cached session) - Synchronous version for UI
  Future<bool> hasCachedUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
      return biometricEnabled;
    } catch (e) {
      print('Error checking cached user session sync: $e');
      return false;
    }
  }

  // Clear saved credentials
  Future<void> clearSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
      await prefs.setBool('biometric_enabled', false);
    } catch (e) {
      print('Error clearing saved credentials: $e');
    }
  }

  // Get saved credentials
  Future<Map<String, String?>> getSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('saved_email');
      final password = prefs.getString('saved_password');
      return {'email': email, 'password': password};
    } catch (e) {
      print('Error getting saved credentials: $e');
      return {'email': null, 'password': null};
    }
  }

  // Get user from cache for biometric login
  User? getUserFromCache() {
    return _databaseService.getUser();
  }

  // Restore user session for biometric login
  Future<void> restoreUserSession(User user) async {
    _user = user;
    await ApiService().initialize(); // Reinitialize API service with cached tokens
    await loadUserStatistics();
    notifyListeners();
  }

  // Get available biometric type name
  Future<String> getBiometricTypeName() async {
    try {
      final List<BiometricType> biometrics = await _biometricService.getAvailableBiometrics();
      return biometrics.isNotEmpty
          ? _biometricService.getBiometricTypeName(biometrics.first)
          : 'Biometric';
    } catch (e) {
      print('Failed to get biometric type: $e');
      return 'Biometric';
    }
  }

  // Handle successful authentication
  Future<void> _handleSuccessfulAuth(AuthResult authResult, {String? email, String? password}) async {
    print('🔧 Handling successful authentication...');
    _user = authResult.user;

    // Ensure DatabaseService is initialized before using it
    try {
      await _databaseService.initialize();
    } catch (e) {
      print('⚠️ DatabaseService already initialized or error: $e');
    }

    await _databaseService.saveUser(_user!);

    // Save biometric enabled flag and credentials in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', true);

    // Save credentials if provided
    if (email != null && password != null) {
      await prefs.setString('saved_email', email);
      await prefs.setString('saved_password', password);
    }

    await ApiService().initialize(); // Reinitialize API service with new tokens
    await loadUserStatistics();
    print('🔧 Authentication handling complete - notifying listeners');
    notifyListeners(); // Make sure UI updates
  }

  // Refresh user data
  Future<void> refreshUserData() async {
    if (!isAuthenticated) return;

    try {
      final response = await _authService.getCurrentUser();
      if (response.isSuccess) {
        _user = response.data!;
        await _databaseService.saveUser(_user!);
        notifyListeners();
      }
    } catch (e) {
      print('Failed to refresh user data: $e');
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? bio,
    String? learningGoal,
    int? dailyGoalMinutes,
    bool? notificationsEnabled,
  }) async {
    if (!isAuthenticated) return false;

    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        bio: bio,
        learningGoal: learningGoal,
        dailyGoalMinutes: dailyGoalMinutes,
        notificationsEnabled: notificationsEnabled,
      );

      if (response.isSuccess) {
        _user = response.data!;
        await _databaseService.saveUser(_user!);
        notifyListeners();
        return true;
      } else {
        _setError(response.error!);
        return false;
      }
    } catch (e) {
      _setError('Profile update failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load user statistics
  Future<void> loadUserStatistics() async {
    if (!isAuthenticated) return;

    try {
      print('📊 Attempting to load user statistics...');
      final response = await _authService.getUserStatistics();
      if (response.isSuccess) {
        print('📊 Statistics loaded successfully');
        _statistics = response.data!;
        notifyListeners();
      } else {
        print('⚠️ Statistics endpoint not available: ${response.error}');
        // Don't crash if statistics endpoint doesn't exist
        // Set default statistics instead
        _statistics = UserStatistics(
          learningStreak: 0,
          totalLessonsCompleted: 0,
          totalPoints: 0,
          weeklyLessons: 0,
          quizStatistics: QuizStatistics(totalQuizzes: 0, averageScore: 0.0),
          joinDate: DateTime.now(),
          lastActivity: null,
        );
        notifyListeners();
      }
    } catch (e) {
      print('⚠️ Error loading statistics: $e');
      // Set default statistics on error
      _statistics = UserStatistics(
        learningStreak: 0,
        totalLessonsCompleted: 0,
        totalPoints: 0,
        weeklyLessons: 0,
        quizStatistics: QuizStatistics(totalQuizzes: 0, averageScore: 0.0),
        joinDate: DateTime.now(),
        lastActivity: null,
      );
      notifyListeners();
    }
  }

  // Logout user
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.logout();
      await _databaseService.clearUser();
      await clearSavedCredentials(); // Clear saved credentials and biometric flag
      _user = null;
      _statistics = null;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Logout failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Update learning streak
  void updateLearningStreak(int newStreak) {
    if (_user != null) {
      _user = User(
        id: _user!.id,
        email: _user!.email,
        username: _user!.username,
        firstName: _user!.firstName,
        lastName: _user!.lastName,
        profilePicture: _user!.profilePicture,
        learningStreak: newStreak,
        totalLessonsCompleted: _user!.totalLessonsCompleted,
        totalPoints: _user!.totalPoints,
        profile: _user!.profile,
        dateJoined: _user!.dateJoined,
      );
      _databaseService.saveUser(_user!);
      notifyListeners();
    }
  }

  // Update lesson completion count
  void updateLessonsCompleted(int increment) {
    if (_user != null) {
      _user = User(
        id: _user!.id,
        email: _user!.email,
        username: _user!.username,
        firstName: _user!.firstName,
        lastName: _user!.lastName,
        profilePicture: _user!.profilePicture,
        learningStreak: _user!.learningStreak,
        totalLessonsCompleted: _user!.totalLessonsCompleted + increment,
        totalPoints: _user!.totalPoints,
        profile: _user!.profile,
        dateJoined: _user!.dateJoined,
      );
      _databaseService.saveUser(_user!);
      notifyListeners();
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
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
