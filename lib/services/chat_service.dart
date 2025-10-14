import '../models/chat.dart';
import 'api_service.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final ApiService _apiService = ApiService();

  // Get chat sessions
  Future<ApiResponse<List<ChatSession>>> getChatSessions() async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '/chat/sessions/',
      fromJson: (json) => json,
    );

    if (response.isSuccess) {
      final results = response.data!['results'] as List;
      final sessions = results
          .map((item) => ChatSession.fromJson(item as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(sessions);
    } else {
      return ApiResponse.error(response.error!);
    }
  }

  // Create new chat session
  Future<ApiResponse<ChatSession>> createChatSession({String? title}) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '/chat/sessions/',
      {
        'title': title ?? 'New Conversation',
      },
      fromJson: (json) => json,
    );

    if (response.isSuccess) {
      final session = ChatSession.fromJson(response.data!);
      return ApiResponse.success(session);
    } else {
      return ApiResponse.error(response.error!);
    }
  }

  // Get chat session details
  Future<ApiResponse<ChatSessionDetail>> getChatSessionDetail(int sessionId) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '/chat/sessions/$sessionId/',
      fromJson: (json) => json,
    );

    if (response.isSuccess) {
      final session = ChatSessionDetail.fromJson(response.data!);
      return ApiResponse.success(session);
    } else {
      return ApiResponse.error(response.error!);
    }
  }

  // Get messages for a session
  Future<ApiResponse<List<ChatMessage>>> getChatMessages(int sessionId) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '/chat/sessions/$sessionId/messages/',
      fromJson: (json) => json,
    );

    if (response.isSuccess) {
      final results = response.data!['results'] as List;
      final messages = results
          .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(messages);
    } else {
      return ApiResponse.error(response.error!);
    }
  }

  // Send message
  Future<ApiResponse<ChatMessageResponse>> sendMessage(
      int sessionId,
      String message,
      ) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '/chat/sessions/$sessionId/message/',
      {
        'message': message,
      },
      fromJson: (json) => json,
    );

    if (response.isSuccess) {
      final messageResponse = ChatMessageResponse.fromJson(response.data!);
      return ApiResponse.success(messageResponse);
    } else {
      return ApiResponse.error(response.error!);
    }
  }

  // Delete chat session
  Future<ApiResponse<void>> deleteChatSession(int sessionId) async {
    final response = await _apiService.delete('/chat/sessions/$sessionId/');
    return response;
  }

  // Update chat session
  Future<ApiResponse<ChatSession>> updateChatSession(
      int sessionId, {
        String? title,
        bool? isActive,
      }) async {
    final Map<String, dynamic> data = {};
    if (title != null) data['title'] = title;
    if (isActive != null) data['is_active'] = isActive;

    final response = await _apiService.put<Map<String, dynamic>>(
      '/chat/sessions/$sessionId/',
      data,
      fromJson: (json) => json,
    );

    if (response.isSuccess) {
      final session = ChatSession.fromJson(response.data!);
      return ApiResponse.success(session);
    } else {
      return ApiResponse.error(response.error!);
    }
  }
}
