import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../shared/services/supabase_service.dart';
import '../../domain/repositories/message_repository.dart';

class MessageRepositoryImpl implements MessageRepository {
  final Dio _dio = Dio();
  final String _baseUrl;

  MessageRepositoryImpl() : _baseUrl = AppConfig.supabaseUrl {
    _dio.options.baseUrl = '$_baseUrl/functions/v1';
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  String? get _authToken {
    return SupabaseService.client.auth.currentSession?.accessToken;
  }

  String? get _currentUserId {
    return SupabaseService.client.auth.currentUser?.id;
  }

  @override
  Future<List<ConversationModel>> getConversations(String userId) async {
    try {
      final response = await _dio.get(
        '/messages/conversations',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_authToken',
          },
        ),
      );

      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => ConversationModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des conversations: $e');
    }
  }

  @override
  Future<List<MessageModel>> getMessages(String conversationId) async {
    try {
      final response = await _dio.get(
        '/messages/$conversationId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_authToken',
          },
        ),
      );

      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => MessageModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des messages: $e');
    }
  }

  @override
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String receiverId,
    required String content,
  }) async {
    try {
      final response = await _dio.post(
        '/messages',
        data: {
          'conversation_id': conversationId,
          'receiver_id': receiverId,
          'content': content,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $_authToken',
          },
        ),
      );

      return MessageModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi du message: $e');
    }
  }

  @override
  Future<ConversationModel> getOrCreateConversation({
    required String otherUserId,
    String? listingId,
  }) async {
    try {
      // D'abord, essayer de trouver une conversation existante
      final conversations = await getConversations(_currentUserId!);
      final existing = conversations.firstWhere(
        (c) =>
            (c.participant1Id == _currentUserId && c.participant2Id == otherUserId) ||
            (c.participant1Id == otherUserId && c.participant2Id == _currentUserId),
        orElse: () => throw Exception('Not found'),
      );

      return existing;
    } catch (e) {
      // Si pas trouvé, créer une nouvelle conversation via l'API
      try {
        final response = await _dio.post(
          '/messages/conversations',
          data: {
            'participant_id': otherUserId,
            'listing_id': listingId,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $_authToken',
            },
          ),
        );

        return ConversationModel.fromJson(response.data['data']);
      } catch (e2) {
        throw Exception('Erreur lors de la création de la conversation: $e2');
      }
    }
  }

  @override
  Future<void> markAsRead(String conversationId) async {
    try {
      await _dio.put(
        '/messages/$conversationId/read',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_authToken',
          },
        ),
      );
    } catch (e) {
      // Ne pas faire échouer si le marquage échoue
      print('Erreur lors du marquage comme lu: $e');
    }
  }
}

