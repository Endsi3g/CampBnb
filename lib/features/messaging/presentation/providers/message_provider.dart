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

