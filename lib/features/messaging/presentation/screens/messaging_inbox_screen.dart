import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class MessagingInboxScreen extends StatelessWidget {
  const MessagingInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
 title: const Text('Messages'),
      ),
      body: ListView(
        children: [
          _buildConversationTile(
            context,
 name: 'Jean Dupont',
 lastMessage: 'Bonjour, je suis intéressé par votre camping...',
 time: 'Il y a 2h',
            unread: true,
          ),
          _buildConversationTile(
            context,
 name: 'Marie Tremblay',
 lastMessage: 'Merci pour votre réponse !',
 time: 'Hier',
            unread: false,
          ),
          _buildConversationTile(
            context,
 name: 'Pierre Gagnon',
 lastMessage: 'Parfait, à bientôt !',
 time: 'Il y a 3 jours',
            unread: false,
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(
    BuildContext context, {
    required String name,
    required String lastMessage,
    required String time,
    required bool unread,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary,
        child: Text(
          name[0].toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        name,
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: unread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        lastMessage,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondaryLight,
          fontWeight: unread ? FontWeight.w500 : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            time,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          if (unread)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      onTap: () {
        context.push('/messages/${name.toLowerCase().replaceAll(' ', '-')}');
      },
    );
  }
}

