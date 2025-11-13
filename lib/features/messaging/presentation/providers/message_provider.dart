import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../shared/services/supabase_service.dart';
import '../../domain/repositories/message_repository.dart';
import '../../data/repositories/message_repository_impl.dart';

part 'message_provider.g.dart';

/// Provider pour le repository de messages
@riverpod
MessageRepository messageRepository(MessageRepositoryRef ref) {
  return MessageRepositoryImpl();
}

/// Provider pour récupérer les conversations
@riverpod
Future<List<ConversationModel>> conversations(ConversationsRef ref) async {
  final repository = ref.watch(messageRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  return await repository.getConversations(userId);
}

/// Provider pour récupérer l'ID de l'utilisateur actuel
@riverpod
String? currentUserId(CurrentUserIdRef ref) {
  return SupabaseService.client.auth.currentUser?.id;
}

/// Provider pour récupérer les messages d'une conversation
@riverpod
Future<List<MessageModel>> messages(
  MessagesRef ref,
  String conversationId,
) async {
  final repository = ref.watch(messageRepositoryProvider);
  return await repository.getMessages(conversationId);
}

/// Provider pour récupérer les infos d'une conversation par ID
@riverpod
Future<Map<String, dynamic>> conversationById(
  ConversationByIdRef ref,
  String conversationId,
) async {
  final repository = ref.watch(messageRepositoryProvider);
  final currentUserId = SupabaseService.client.auth.currentUser?.id ?? '';

  if (currentUserId.isEmpty) {
    return {
      'id': conversationId,
      'recipientId': '',
      'recipientName': 'Utilisateur',
    };
  }

  final conversations = await repository.getConversations(currentUserId);

  final conversation = conversations.firstWhere(
    (c) => c.id == conversationId,
    orElse: () => conversations.isNotEmpty
        ? conversations.first
        : ConversationModel(
            id: conversationId,
            participant1Id: currentUserId,
            participant2Id: '',
          ),
  );

  // Récupérer le nom du destinataire depuis le profil
  final recipientId = conversation.participant1Id == currentUserId
      ? conversation.participant2Id
      : conversation.participant1Id;

  // TODO: Récupérer le nom depuis le profil utilisateur via Supabase
  // Pour l'instant, retourner un nom par défaut
  return {
    'id': conversation.id,
    'recipientId': recipientId,
    'recipientName':
        'Utilisateur', // À remplacer par le vrai nom depuis le profil
  };
}

/// Notifier pour gérer les messages
@riverpod
class MessageNotifier extends _$MessageNotifier {
  @override
  FutureOr<void> build() {
    // État initial vide
  }

  /// Envoyer un message
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String receiverId,
    required String content,
  }) async {
    final repository = ref.read(messageRepositoryProvider);
    final message = await repository.sendMessage(
      conversationId: conversationId,
      receiverId: receiverId,
      content: content,
    );

    // Invalider les providers pour rafraîchir
    ref.invalidate(messagesProvider(conversationId));
    ref.invalidate(conversationsProvider);

    return message;
  }

  /// Marquer comme lu
  Future<void> markAsRead(String conversationId) async {
    final repository = ref.read(messageRepositoryProvider);
    await repository.markAsRead(conversationId);

    // Invalider les providers
    ref.invalidate(conversationsProvider);
    ref.invalidate(messagesProvider(conversationId));
  }
}
