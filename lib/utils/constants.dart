class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://learn.spacevest.com.ng/api/v1/';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';

  // App Configuration
  static const String appName = 'Learn Hausa';
  static const String appVersion = '1.0.0';

  // Colors (matching your design)
  static const int primaryGreen = 0xFF2F855A;
  static const int accentOrange = 0xFFF6AD55;
  static const int lightBackground = 0xFFF7FAFC;
  static const int darkText = 0xFF1A202C;

  // Content Types for Bookmarks
  static const String lessonContentType = 'lesson';
  static const String vocabularyContentType = 'vocabulary';
  static const String phraseContentType = 'phrase';

  // Quiz Question Types
  static const String multipleChoiceType = 'multiple_choice';
  static const String trueFalseType = 'true_false';
  static const String fillBlankType = 'fill_blank';
  static const String audioChoiceType = 'audio_choice';

  // Learning Goals
  static const Map<String, String> learningGoals = {
    'basic': 'Basic Communication',
    'intermediate': 'Intermediate',
    'advanced': 'Advanced',
    'fluent': 'Fluent',
  };

  // Word Types
  static const Map<String, String> wordTypes = {
    'noun': 'Noun',
    'verb': 'Verb',
    'adjective': 'Adjective',
    'adverb': 'Adverb',
    'phrase': 'Phrase',
  };

  // Audio File Extensions
  static const List<String> audioExtensions = ['.mp3', '.wav', '.m4a', '.aac'];

  // Image File Extensions
  static const List<String> imageExtensions = ['.jpg', '.jpeg', '.png', '.gif'];

  // Default Values
  static const int defaultDailyGoalMinutes = 15;
  static const int defaultQuizTimeLimit = 10;
  static const int defaultQuizPassingScore = 70;
  static const double defaultAudioVolume = 1.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
