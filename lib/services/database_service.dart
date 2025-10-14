import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/bookmark.dart';
import '../models/lesson.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static const String _userBox = 'user_box';
  static const String _lessonsBox = 'lessons_box';
  static const String _bookmarksBox = 'bookmarks_box';
  static const String _progressBox = 'progress_box';
  static const String _settingsBox = 'settings_box';

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  // Initialize Hive database and SharedPreferences for settings
  Future<void> initialize() async {
    if (_isInitialized) {
      print('📦 DatabaseService already initialized');
      return; // Already initialized
    }

    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);

    // Register adapters (we'll generate these with hive_generator)
    // Hive.registerAdapter(UserAdapter());
    // For now, we'll use JSON serialization with Hive boxes

    await _openBoxes();
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
    print('✅ DatabaseService initialized with Hive + SharedPreferences');
  }

  Future<void> _openBoxes() async {
    await Hive.openBox(_userBox);
    await Hive.openBox(_lessonsBox);
    await Hive.openBox(_bookmarksBox);
    await Hive.openBox(_progressBox);
    await Hive.openBox(_settingsBox);
  }

  // User Data
  Future<void> saveUser(User user) async {
    try {
      await _ensureInitialized();
      final box = Hive.box(_userBox);
      final userJson = user.toJson();
      await box.put('current_user', userJson);
      print('✅ User saved successfully to Hive');
    } catch (e) {
      print('💥 Error saving user: $e');
      rethrow;
    }
  }

  User? getUser() {
    try {
      _ensureInitializedSync();
      final box = Hive.box(_userBox);
      final userData = box.get('current_user');
      if (userData != null) {
        // Convert Map<dynamic, dynamic> to Map<String, dynamic> more robustly
        final Map<String, dynamic> userJson = Map<String, dynamic>.from(userData);
        return User.fromJson(userJson);
      }
      return null;
    } catch (e) {
      print('💥 Error getting user: $e');
      return null;
    }
  }

  Future<void> clearUser() async {
    try {
      await _ensureInitialized();
      final box = Hive.box(_userBox);
      await box.delete('current_user');
      print('✅ User data cleared successfully');
    } catch (e) {
      print('💥 Error clearing user: $e');
    }
  }

  // Bookmarks
  Future<void> saveBookmarks(List<Bookmark> bookmarks) async {
    try {
      await _ensureInitialized();
      final box = Hive.box(_bookmarksBox);
      final bookmarksJson = bookmarks.map((bookmark) => bookmark.toJson()).toList();
      await box.put('user_bookmarks', bookmarksJson);
      print('✅ Bookmarks saved successfully');
    } catch (e) {
      print('💥 Error saving bookmarks: $e');
      rethrow;
    }
  }

  List<Bookmark> getCachedBookmarks() {
    try {
      _ensureInitializedSync();
      final box = Hive.box(_bookmarksBox);
      final bookmarksData = box.get('user_bookmarks');
      if (bookmarksData != null) {
        return (bookmarksData as List)
            .map((item) => Bookmark.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      return [];
    } catch (e) {
      print('💥 Error getting bookmarks: $e');
      return [];
    }
  }

  // Lessons Cache
  Future<void> saveLessons(List<Lesson> lessons) async {
    try {
      await _ensureInitialized();
      final box = Hive.box(_lessonsBox);
      final lessonsJson = lessons.map((lesson) => lesson.toJson()).toList();
      await box.put('cached_lessons', lessonsJson);
      await box.put('lessons_cache_time', DateTime.now().millisecondsSinceEpoch);
      print('✅ Lessons cached successfully');
    } catch (e) {
      print('💥 Error saving lessons: $e');
      rethrow;
    }
  }

  List<Lesson>? getCachedLessons() {
    try {
      _ensureInitializedSync();
      final box = Hive.box(_lessonsBox);
      final cacheTime = box.get('lessons_cache_time');

      // Check if cache is older than 1 hour
      if (cacheTime != null) {
        final cacheDate = DateTime.fromMillisecondsSinceEpoch(cacheTime);
        if (DateTime.now().difference(cacheDate).inHours > 1) {
          return null; // Cache expired
        }
      }

      final lessonsData = box.get('cached_lessons');
      if (lessonsData != null) {
        return (lessonsData as List)
            .map((item) => Lesson.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      return null;
    } catch (e) {
      print('💥 Error getting lessons: $e');
      return null;
    }
  }

  // Categories Cache
  Future<void> saveCategories(List<Category> categories) async {
    try {
      await _ensureInitialized();
      final box = Hive.box(_lessonsBox);
      final categoriesJson = categories.map((cat) => cat.toJson()).toList();
      await box.put('cached_categories', categoriesJson);
      await box.put('categories_cache_time', DateTime.now().millisecondsSinceEpoch);
      print('✅ Categories cached successfully');
    } catch (e) {
      print('💥 Error saving categories: $e');
      rethrow;
    }
  }

  List<Category>? getCachedCategories() {
    try {
      _ensureInitializedSync();
      final box = Hive.box(_lessonsBox);
      final cacheTime = box.get('categories_cache_time');

      if (cacheTime != null) {
        final cacheDate = DateTime.fromMillisecondsSinceEpoch(cacheTime);
        if (DateTime.now().difference(cacheDate).inHours > 2) {
          return null; // Cache expired
        }
      }

      final categoriesData = box.get('cached_categories');
      if (categoriesData != null) {
        return (categoriesData as List)
            .map((item) => Category.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      return null;
    } catch (e) {
      print('💥 Error getting categories: $e');
      return null;
    }
  }

  // Progress Data
  Future<void> saveProgress(List<UserProgress> progress) async {
    try {
      await _ensureInitialized();
      final box = Hive.box(_progressBox);
      final progressJson = progress.map((p) => p.toJson()).toList();
      await box.put('user_progress', progressJson);
      print('✅ Progress saved successfully');
    } catch (e) {
      print('💥 Error saving progress: $e');
      rethrow;
    }
  }

  List<UserProgress> getCachedProgress() {
    try {
      _ensureInitializedSync();
      final box = Hive.box(_progressBox);
      final progressData = box.get('user_progress');
      if (progressData != null) {
        return (progressData as List)
            .map((item) => UserProgress.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      return [];
    } catch (e) {
      print('💥 Error getting progress: $e');
      return [];
    }
  }

  // Helper method to ensure initialization
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  // Synchronous version for getters
  void _ensureInitializedSync() {
    if (!_isInitialized) {
      print('⚠️ DatabaseService not initialized when accessing data. Call initialize() first.');
    }
  }

  // Settings (using SharedPreferences - simpler)
  Future<void> saveSetting(String key, dynamic value) async {
    await _ensureInitialized();
    try {
      bool success = false;
      if (value is String) {
        success = await _prefs!.setString(key, value);
      } else if (value is int) {
        success = await _prefs!.setInt(key, value);
      } else if (value is double) {
        success = await _prefs!.setDouble(key, value);
      } else if (value is bool) {
        success = await _prefs!.setBool(key, value);
      } else if (value is List<String>) {
        success = await _prefs!.setStringList(key, value);
      } else {
        throw Exception('Unsupported type for SharedPreferences');
      }

      if (!success) {
        throw Exception('Failed to save setting: $key');
      }
    } catch (e) {
      print('💥 Error saving setting $key: $e');
      rethrow;
    }
  }

  T? getSetting<T>(String key, [T? defaultValue]) {
    _ensureInitializedSync();
    try {
      if (T == String) {
        return _prefs?.getString(key) as T? ?? defaultValue;
      } else if (T == int) {
        return _prefs?.getInt(key) as T? ?? defaultValue;
      } else if (T == double) {
        return _prefs?.getDouble(key) as T? ?? defaultValue;
      } else if (T == bool) {
        return _prefs?.getBool(key) as T? ?? defaultValue;
      } else if (T == List<String>) {
        return _prefs?.getStringList(key) as T? ?? defaultValue;
      } else {
        throw Exception('Unsupported type for SharedPreferences');
      }
    } catch (e) {
      print('💥 Error getting setting $key: $e');
      return defaultValue;
    }
  }

  // App Settings
  bool get isDarkMode => getSetting<bool>('dark_mode', false) ?? false;
  set isDarkMode(bool value) => saveSetting('dark_mode', value);

  double get audioVolume => getSetting<double>('audio_volume', 1.0) ?? 1.0;
  set audioVolume(double value) => saveSetting('audio_volume', value);

  bool get notificationsEnabled => getSetting<bool>('notifications_enabled', true) ?? true;
  set notificationsEnabled(bool value) => saveSetting('notifications_enabled', value);

  String get preferredLanguage => getSetting<String>('preferred_language', 'en') ?? 'en';
  set preferredLanguage(String value) => saveSetting('preferred_language', value);

  // Clear all data
  Future<void> clearAllData() async {
    await _ensureInitialized();
    try {
      // Clear user data from Hive
      await clearUser();

      // Clear settings from SharedPreferences
      await _prefs!.clear();

      print('✅ All data cleared successfully');
    } catch (e) {
      print('💥 Error clearing all data: $e');
    }
  }

  // Close all boxes
  Future<void> closeBoxes() async {
    await Hive.close();
    print('✅ DatabaseService closed');
  }
}