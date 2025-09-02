class AppConfig {
  static const String appName = 'Learn Hausa';
  static const String version = '1.0.0';

  // Colors
  static const int primaryGreen = 0xFF2F855A;
  static const int accentOrange = 0xFFF6AD55;
  static const int lightBackground = 0xFFF7FAFC;
  static const int darkText = 0xFF1A202C;

  // API Configuration
  static const String baseUrl = 'https://api.learnhausa.com';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Local Storage Keys
  static const String userKey = 'user_data';
  static const String progressKey = 'learning_progress';
  static const String bookmarksKey = 'bookmarks';
}