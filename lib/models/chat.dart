class ChatSession {
  final int id;
  final String title;
  final bool isActive;
  final String? lastMessagePreview;
  final int messagesCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatSession({
    required this.id,
    required this.title,
    required this.isActive,
    this.lastMessagePreview,
    required this.messagesCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      title: json['title'] ?? 'New Conversation',
      isActive: json['is_active'] ?? true,
      lastMessagePreview: json['last_message_preview']?['message'],
      messagesCount: json['messages_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'is_active': isActive,
      'messages_count': messagesCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ChatSessionDetail {
  final int id;
  final String title;
  final bool isActive;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatSessionDetail({
    required this.id,
    required this.title,
    required this.isActive,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatSessionDetail.fromJson(Map<String, dynamic> json) {
    return ChatSessionDetail(
      id: json['id'],
      title: json['title'],
      isActive: json['is_active'],
      messages: (json['messages'] as List)
          .map((item) => ChatMessage.fromJson(item))
          .toList(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class ChatMessage {
  final int id;
  final String message;
  final bool isUser;
  final String? audioFile;
  final String messageType;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.message,
    required this.isUser,
    this.audioFile,
    required this.messageType,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      message: json['message'],
      isUser: json['is_user'],
      audioFile: json['audio_file'],
      messageType: json['message_type'] ?? 'text',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'is_user': isUser,
      'audio_file': audioFile,
      'message_type': messageType,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class ChatMessageResponse {
  final ChatMessage userMessage;
  final ChatMessage aiResponse;
  final String? error;

  ChatMessageResponse({
    required this.userMessage,
    required this.aiResponse,
    this.error,
  });

  factory ChatMessageResponse.fromJson(Map<String, dynamic> json) {
    return ChatMessageResponse(
      userMessage: ChatMessage.fromJson(json['user_message']),
      aiResponse: ChatMessage.fromJson(json['ai_response']),
      error: json['error'],
    );
  }
}
