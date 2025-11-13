/// Widget de chat IA contextuel réutilisable
/// Peut être intégré dans différents écrans de l'application
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/gemini_models.dart';
import '../../../core/providers/gemini_providers.dart';

class GeminiChatWidget extends ConsumerStatefulWidget {
  /// Titre du chat (optionnel)
  final String? title;

  /// Contexte utilisateur pour personnaliser les réponses
  final String? userContext;

  /// Placeholder pour le champ de saisie
  final String? inputPlaceholder;

  /// Callback appelé quand le chat est fermé
  final VoidCallback? onClose;

 /// Mode compact (pour intégration dans d'autres écrans)
  final bool compact;

  const GeminiChatWidget({
    super.key,
    this.title,
    this.userContext,
    this.inputPlaceholder,
    this.onClose,
    this.compact = false,
  });

  @override
  ConsumerState<GeminiChatWidget> createState() => _GeminiChatWidgetState();
}

class _GeminiChatWidgetState extends ConsumerState<GeminiChatWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.userContext != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(chatProvider.notifier).setUserContext(widget.userContext);
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    _focusNode.unfocus();

    await ref.read(chatProvider.notifier).sendMessage(message);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: widget.compact
            ? BorderRadius.circular(16)
            : const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // En-tête
          if (!widget.compact) _buildHeader(theme),
          
          // Messages
          Expanded(
            child: chatState.messages.isEmpty
                ? _buildEmptyState(theme)
                : _buildMessagesList(chatState.messages, theme),
          ),

          // Indicateur de chargement
          if (chatState.isLoading) _buildLoadingIndicator(theme),

          // Erreur
          if (chatState.error != null) _buildError(chatState.error!, theme),

          // Champ de saisie
          _buildInputField(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
 widget.title ?? 'Assistant Campbnb',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
 'Comment puis-je vous aider ?',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          if (widget.onClose != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: widget.onClose,
              iconSize: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 48,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
 'Bonjour ! ',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
 'Je suis votre assistant IA pour vous aider à trouver le camping parfait.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
 _buildSuggestionChip('Trouver un camping', theme),
 _buildSuggestionChip('Questions sur les réservations', theme),
 _buildSuggestionChip('Conseils de camping', theme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text, ThemeData theme) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        _messageController.text = text;
        _sendMessage();
      },
      backgroundColor: theme.primaryColor.withOpacity(0.1),
      labelStyle: TextStyle(color: theme.primaryColor),
    );
  }

  Widget _buildMessagesList(List<ChatMessage> messages, ThemeData theme) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildMessageBubble(message, theme);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, ThemeData theme) {
    final isUser = message.isUser;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? theme.primaryColor
                    : theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: isUser ? const Radius.circular(4) : null,
                  bottomLeft: !isUser ? const Radius.circular(4) : null,
                ),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isUser ? Colors.white : theme.textTheme.bodyMedium?.color,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person,
                color: theme.primaryColor,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
 'Erreur: $error',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withOpacity(0.1),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                decoration: InputDecoration(
 hintText: widget.inputPlaceholder ?? 'Tapez votre message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: theme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget compact pour intégration dans d'autres écrans
class GeminiChatFloatingButton extends ConsumerWidget {
  final String? userContext;

  const GeminiChatFloatingButton({super.key, this.userContext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) => GeminiChatWidget(
              userContext: userContext,
              onClose: () => Navigator.of(context).pop(),
            ),
          ),
        );
      },
      child: const Icon(Icons.auto_awesome),
    );
  }
}


