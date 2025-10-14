import '../models/bookmark.dart';
import 'api_service.dart';

class BookmarkService {
  static final BookmarkService _instance = BookmarkService._internal();
  factory BookmarkService() => _instance;
  BookmarkService._internal();

  final ApiService _apiService = ApiService();

  // Get user's bookmarks
  Future<ApiResponse<List<Bookmark>>> getBookmarks({
    String? contentType,
  }) async {
    final Map<String, String> queryParams = {};
    if (contentType != null) queryParams['content_type'] = contentType;

    final response = await _apiService.get<Map<String, dynamic>>(
      '/bookmarks/',
      queryParams: queryParams,
      fromJson: (json) => json,
    );

    if (response.isSuccess) {
      final results = response.data!['results'] as List;
      final bookmarks = results
          .map((item) => Bookmark.fromJson(item as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(bookmarks);
    } else {
      return ApiResponse.error(response.error!);
    }
  }

  // Add bookmark
  Future<ApiResponse<Bookmark>> addBookmark({
    required String contentType,
    required int objectId,
    String? notes,
  }) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '/bookmarks/',
      {
        'content_type': contentType,
        'object_id': objectId,
        'notes': notes ?? '',
      },
      fromJson: (json) => json,
    );

    if (response.isSuccess) {
      final bookmark = Bookmark.fromJson(response.data!);
      return ApiResponse.success(bookmark);
    } else {
      return ApiResponse.error(response.error!);
    }
  }

  // Update bookmark
  Future<ApiResponse<Bookmark>> updateBookmark(
      int bookmarkId, {
        String? notes,
      }) async {
    final response = await _apiService.put<Map<String, dynamic>>(
      '/bookmarks/$bookmarkId/',
      {
        'notes': notes ?? '',
      },
      fromJson: (json) => json,
    );

    if (response.isSuccess) {
      final bookmark = Bookmark.fromJson(response.data!);
      return ApiResponse.success(bookmark);
    } else {
      return ApiResponse.error(response.error!);
    }
  }

  // Remove bookmark
  Future<ApiResponse<void>> removeBookmark(int bookmarkId) async {
    final response = await _apiService.delete('/bookmarks/$bookmarkId/');
    return response;
  }

  // Check if content is bookmarked
  Future<bool> isBookmarked(String contentType, int objectId) async {
    final bookmarksResponse = await getBookmarks(contentType: contentType);
    if (bookmarksResponse.isSuccess) {
      return bookmarksResponse.data!.any(
            (bookmark) => bookmark.objectId == objectId,
      );
    }
    return false;
  }

  // Toggle bookmark status
  Future<ApiResponse<bool>> toggleBookmark({
    required String contentType,
    required int objectId,
    String? notes,
  }) async {
    final bookmarksResponse = await getBookmarks(contentType: contentType);
    if (!bookmarksResponse.isSuccess) {
      return ApiResponse.error(bookmarksResponse.error!);
    }

    final existingBookmark = bookmarksResponse.data!
        .where((bookmark) => bookmark.objectId == objectId)
        .firstOrNull;

    if (existingBookmark != null) {
      // Remove bookmark
      final removeResponse = await removeBookmark(existingBookmark.id);
      if (removeResponse.isSuccess) {
        return ApiResponse.success(false); // Not bookmarked
      } else {
        return ApiResponse.error(removeResponse.error!);
      }
    } else {
      // Add bookmark
      final addResponse = await addBookmark(
        contentType: contentType,
        objectId: objectId,
        notes: notes,
      );
      if (addResponse.isSuccess) {
        return ApiResponse.success(true); // Bookmarked
      } else {
        return ApiResponse.error(addResponse.error!);
      }
    }
  }
}