import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();

  List<ChatSession> _sessions = [];
  ChatSessionDetail? _currentSession;
  List<ChatMessage> _messages = [];

  bool _isLoading = false;
  bool _isLoadingSessions = false;
  bool _isLoadingMessages = false;
  bool _isSending = false;
  String? _error;

  // Getters
  List<ChatSession> get sessions => _sessions;
  ChatSessionDetail? get currentSession => _currentSession;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isLoadingSessions => _isLoadingSessions;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isSending => _isSending;
  String? get error => _error;

  // Initialize chat data
  Future<void> initialize() async {
    await loadSessions();
  }

  // Load chat sessions
  Future<void> loadSessions() async {
    _setLoadingSessions(true);
    _clearError();

    try {
      final response = await _chatService.getChatSessions();
      if (response.isSuccess) {
        _sessions = response.data!;
        notifyListeners();
      } else {
        _setError(response.error!);
      }
    } catch (e) {
      _setError('Failed to load chat sessions: ${e.toString()}');
    } finally {
      _setLoadingSessions(false);
    }
  }

  // Create new chat session
  Future<ChatSession?> createSession({String? title}) async {
    _clearError();

    try {
      final response = await _chatService.createChatSession(title: title);
      if (response.isSuccess) {
        final newSession = response.data!;
        _sessions.insert(0, newSession);
        notifyListeners();
        return newSession;
      } else {
        _setError(response.error!);
        return null;
      }
    } catch (e) {
      _setError('Failed to create chat session: ${e.toString()}');
      return null;
    }
  }

  // Load session detail and messages
  Future<void> loadSession(int sessionId) async {
    _setLoading(true);
    _clearError();

    try {
      // Load session detail
      final sessionResponse = await _chatService.getChatSessionDetail(sessionId);
      if (sessionResponse.isSuccess) {
        _currentSession = sessionResponse.data!;
        _messages = _currentSession!.messages;
        notifyListeners();
      } else {
        _setError(sessionResponse.error!);
      }
    } catch (e) {
      _setError('Failed to load chat session: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load messages for current session
  Future<void> loadMessages() async {
    if (_currentSession == null) return;

    _setLoadingMessages(true);
    _clearError();

    try {
      final response = await _chatService.getChatMessages(_currentSession!.id);
      if (response.isSuccess) {
        _messages = response.data!;
        notifyListeners();
      } else {
        _setError(response.error!);
      }
    } catch (e) {
      _setError('Failed to load messages: ${e.toString()}');
    } finally {
      _setLoadingMessages(false);
    }
  }

  // Send message
  Future<bool> sendMessage(String message) async {
    if (_currentSession == null || message.trim().isEmpty) return false;

    _setSending(true);
    _clearError();

    try {
      final response = await _chatService.sendMessage(_currentSession!.id, message.trim());
      if (response.isSuccess) {
        final messageResponse = response.data!;

        // Add both user message and AI response to the list
        _messages.add(messageResponse.userMessage);
        _messages.add(messageResponse.aiResponse);

        // Update session in the sessions list
        final sessionIndex = _sessions.indexWhere((s) => s.id == _currentSession!.id);
        if (sessionIndex >= 0) {
          // Move session to top and update message count
          final updatedSession = ChatSession(
            id: _sessions[sessionIndex].id,
            title: _sessions[sessionIndex].title,
            isActive: _sessions[sessionIndex].isActive,
            lastMessagePreview: message.length > 50 ? '${message.substring(0, 50)}...' : message,
            messagesCount: _messages.length,
            createdAt: _sessions[sessionIndex].createdAt,
            updatedAt: DateTime.now(),
          );

          _sessions.removeAt(sessionIndex);
          _sessions.insert(0, updatedSession);
        }

        notifyListeners();
        return true;
      } else {
        _setError(response.error!);
        return false;
      }
    } catch (e) {
      _setError('Failed to send message: ${e.toString()}');
      return false;
    } finally {
      _setSending(false);
    }
  }

  // Delete session
  Future<bool> deleteSession(int sessionId) async {
    _clearError();

    try {
      final response = await _chatService.deleteChatSession(sessionId);
      if (response.isSuccess) {
        _sessions.removeWhere((session) => session.id == sessionId);

        // If deleted session was current session, clear it
        if (_currentSession?.id == sessionId) {
          _currentSession = null;
          _messages.clear();
        }

        notifyListeners();
        return true;
      } else {
        _setError(response.error!);
        return false;
      }
    } catch (e) {
      _setError('Failed to delete session: ${e.toString()}');
      return false;
    }
  }

  // Update session title
  Future<bool> updateSessionTitle(int sessionId, String title) async {
    _clearError();

    try {
      final response = await _chatService.updateChatSession(sessionId, title: title);
      if (response.isSuccess) {
        final updatedSession = response.data!;
        final index = _sessions.indexWhere((s) => s.id == sessionId);
        if (index >= 0) {
          _sessions[index] = updatedSession;
        }

        // Update current session if it's the same
        if (_currentSession?.id == sessionId) {
          _currentSession = ChatSessionDetail(
            id: updatedSession.id,
            title: updatedSession.title,
            isActive: updatedSession.isActive,
            messages: _messages,
            createdAt: updatedSession.createdAt,
            updatedAt: updatedSession.updatedAt,
          );
        }

        notifyListeners();
        return true;
      } else {
        _setError(response.error!);
        return false;
      }
    } catch (e) {
      _setError('Failed to update session: ${e.toString()}');
      return false;
    }
  }

  // Clear current session
  void clearCurrentSession() {
    _currentSession = null;
    _messages.clear();
    notifyListeners();
  }

  // Get session by ID
  ChatSession? getSession(int sessionId) {
    return _sessions.where((session) => session.id == sessionId).firstOrNull;
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingSessions(bool loading) {
    _isLoadingSessions = loading;
    notifyListeners();
  }

  void _setLoadingMessages(bool loading) {
    _isLoadingMessages = loading;
    notifyListeners();
  }

  void _setSending(bool sending) {
    _isSending = sending;
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
