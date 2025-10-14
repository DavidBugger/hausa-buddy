import 'package:flutter/material.dart';
import '../models/bookmark.dart';
import '../services/bookmark_service.dart';
import '../services/database_service.dart';

class BookmarkProvider with ChangeNotifier {
  final BookmarkService _bookmarkService = BookmarkService();
  final DatabaseService _databaseService = DatabaseService();

  List<Bookmark> _bookmarks = [];
  bool _isLoading = false;
  String? _error;

  // Filter
  String? _contentTypeFilter;

  // Getters
  List<Bookmark> get bookmarks => _bookmarks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get contentTypeFilter => _contentTypeFilter;

  // Filtered bookmarks
  List<Bookmark> get filteredBookmarks {
    if (_contentTypeFilter == null) return _bookmarks;
    return _bookmarks.where((bookmark) => bookmark.contentType == _contentTypeFilter).toList();
  }

  // Get bookmarked lessons
  List<Bookmark> get bookmarkedLessons {
    return _bookmarks.where((bookmark) => bookmark.contentType == 'lesson').toList();
  }

  // Bookmark counts by type
  int get lessonBookmarksCount => _bookmarks.where((b) => b.contentType == 'lesson').length;
  int get vocabularyBookmarksCount => _bookmarks.where((b) => b.contentType == 'vocabulary').length;
  int get phraseBookmarksCount => _bookmarks.where((b) => b.contentType == 'phrase').length;

  // Initialize bookmarks
  Future<void> initialize() async {
    await loadBookmarks();
  }

  // Load bookmarks
  Future<void> loadBookmarks({String? contentType}) async {
    _setLoading(true);
    _clearError();

    try {
      // Load cached bookmarks first
      final cachedBookmarks = _databaseService.getCachedBookmarks();
      if (cachedBookmarks.isNotEmpty) {
        _bookmarks = cachedBookmarks;
        notifyListeners();
      }

      // Then load from server
      final response = await _bookmarkService.getBookmarks(contentType: contentType);
      if (response.isSuccess) {
        _bookmarks = response.data!;
        await _databaseService.saveBookmarks(_bookmarks);
        notifyListeners();
      } else {
        _setError(response.error!);
      }
    } catch (e) {
      _setError('Failed to load bookmarks: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Add bookmark
  Future<bool> addBookmark({
    required String contentType,
    required int objectId,
    String? notes,
  }) async {
    _clearError();

    try {
      final response = await _bookmarkService.addBookmark(
        contentType: contentType,
        objectId: objectId,
        notes: notes,
      );

      if (response.isSuccess) {
        _bookmarks.add(response.data!);
        await _databaseService.saveBookmarks(_bookmarks);
        notifyListeners();
        return true;
      } else {
        _setError(response.error!);
        return false;
      }
    } catch (e) {
      _setError('Failed to add bookmark: ${e.toString()}');
      return false;
    }
  }

  // Remove bookmark
  Future<bool> removeBookmark(int bookmarkId) async {
    _clearError();

    try {
      final response = await _bookmarkService.removeBookmark(bookmarkId);
      if (response.isSuccess) {
        _bookmarks.removeWhere((bookmark) => bookmark.id == bookmarkId);
        await _databaseService.saveBookmarks(_bookmarks);
        notifyListeners();
        return true;
      } else {
        _setError(response.error!);
        return false;
      }
    } catch (e) {
      _setError('Failed to remove bookmark: ${e.toString()}');
      return false;
    }
  }

  // Toggle bookmark
  Future<bool> toggleBookmark({
    required String contentType,
    required int objectId,
    String? notes,
  }) async {
    _clearError();

    try {
      final response = await _bookmarkService.toggleBookmark(
        contentType: contentType,
        objectId: objectId,
        notes: notes,
      );

      if (response.isSuccess) {
        // Refresh bookmarks to get updated list
        await loadBookmarks();
        return response.data!; // Returns true if bookmarked, false if removed
      } else {
        _setError(response.error!);
        return false;
      }
    } catch (e) {
      _setError('Failed to toggle bookmark: ${e.toString()}');
      return false;
    }
  }

  // Check if content is bookmarked
  bool isBookmarked(String contentType, int objectId) {
    return _bookmarks.any(
          (bookmark) => bookmark.contentType == contentType && bookmark.objectId == objectId,
    );
  }

  // Get bookmark for content
  Bookmark? getBookmark(String contentType, int objectId) {
    return _bookmarks
        .where((bookmark) => bookmark.contentType == contentType && bookmark.objectId == objectId)
        .firstOrNull;
  }

  // Set content type filter
  void setContentTypeFilter(String? contentType) {
    _contentTypeFilter = contentType;
    notifyListeners();
  }

  // Clear filter
  void clearFilter() {
    _contentTypeFilter = null;
    notifyListeners();
  }

  // Update bookmark notes
  Future<bool> updateBookmarkNotes(int bookmarkId, String notes) async {
    _clearError();

    try {
      final response = await _bookmarkService.updateBookmark(bookmarkId, notes: notes);
      if (response.isSuccess) {
        final index = _bookmarks.indexWhere((bookmark) => bookmark.id == bookmarkId);
        if (index >= 0) {
          _bookmarks[index] = response.data!;
          await _databaseService.saveBookmarks(_bookmarks);
          notifyListeners();
        }
        return true;
      } else {
        _setError(response.error!);
        return false;
      }
    } catch (e) {
      _setError('Failed to update bookmark: ${e.toString()}');
      return false;
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