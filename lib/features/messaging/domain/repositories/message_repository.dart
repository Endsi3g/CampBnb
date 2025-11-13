/// Modèle pour un message
class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'created_at': timestamp.toIso8601String(),
      'is_read': isRead,
    };
  }
}

/// Modèle pour une conversation
class ConversationModel {
  final String id;
  final String participant1Id;
  final String participant2Id;
  final String? listingId;
  final MessageModel? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  ConversationModel({
    required this.id,
    required this.participant1Id,
    required this.participant2Id,
    this.listingId,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      participant1Id: json['participant1_id'] as String,
      participant2Id: json['participant2_id'] as String,
      listingId: json['listing_id'] as String?,
      lastMessage: json['last_message'] != null
          ? MessageModel.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }
}

/// Interface du repository pour les messages
abstract class MessageRepository {
  /// Récupérer toutes les conversations d'un utilisateur
  Future<List<ConversationModel>> getConversations(String userId);

  /// Récupérer les messages d'une conversation
  Future<List<MessageModel>> getMessages(String conversationId);

  /// Envoyer un message
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String receiverId,
    required String content,
  });

  /// Créer ou récupérer une conversation
  Future<ConversationModel> getOrCreateConversation({
    required String otherUserId,
    String? listingId,
  });

  /// Marquer les messages comme lus
  Future<void> markAsRead(String conversationId);
}

