import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../ai_features/widgets/faq_ai_widget.dart';
import '../../../ai_chat/widgets/gemini_chat_widget.dart';

class HelpSupportCenterScreen extends ConsumerStatefulWidget {
  const HelpSupportCenterScreen({super.key});

  @override
  ConsumerState<HelpSupportCenterScreen> createState() =>
      _HelpSupportCenterScreenState();
}

class _HelpSupportCenterScreenState
    extends ConsumerState<HelpSupportCenterScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aide et support')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recherche
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher dans l\'aide...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
              onChanged: (value) {
                // TODO: Implémenter recherche
              },
            ),
            const SizedBox(height: 24),

            // FAQ avec IA
            Text('Questions fréquentes', style: AppTextStyles.headingSmall),
            const SizedBox(height: 16),
            FAQAIWidget(
              question: _searchController.text.isEmpty
                  ? 'Comment puis-je réserver un camping ?'
                  : _searchController.text,
            ),
            const SizedBox(height: 24),

            // Catégories d'aide
            Text('Catégories', style: AppTextStyles.headingSmall),
            const SizedBox(height: 16),
            _buildCategoryCard(
              context,
              icon: Icons.calendar_today,
              title: 'Réservations',
              subtitle: 'Gérer vos réservations',
              onTap: () {
                // TODO: Naviguer vers FAQ réservations
              },
            ),
            const SizedBox(height: 12),
            _buildCategoryCard(
              context,
              icon: Icons.payment,
              title: 'Paiements',
              subtitle: 'Questions sur les paiements',
              onTap: () {
                // TODO: Naviguer vers FAQ paiements
              },
            ),
            const SizedBox(height: 12),
            _buildCategoryCard(
              context,
              icon: Icons.home,
              title: 'Devenir hôte',
              subtitle: 'Comment devenir hôte',
              onTap: () {
                // TODO: Naviguer vers guide hôte
              },
            ),
            const SizedBox(height: 12),
            _buildCategoryCard(
              context,
              icon: Icons.account_circle,
              title: 'Compte',
              subtitle: 'Gérer votre compte',
              onTap: () {
                // TODO: Naviguer vers FAQ compte
              },
            ),
            const SizedBox(height: 24),

            // Chat avec assistant IA
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  Text('Besoin d\'aide ?', style: AppTextStyles.headingSmall),
                  const SizedBox(height: 8),
                  Text(
                    'Discutez avec notre assistant IA',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Ouvrir le chat',
                    onPressed: () {
                      context.push('/help/chat');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Contact
            Text('Contact', style: AppTextStyles.headingSmall),
            const SizedBox(height: 16),
            _buildContactOption(
              context,
              icon: Icons.email,
              title: 'Email',
              subtitle: 'support@campbnb.quebec',
              onTap: () {
                // TODO: Ouvrir email
              },
            ),
            const SizedBox(height: 12),
            _buildContactOption(
              context,
              icon: Icons.phone,
              title: 'Téléphone',
              subtitle: '1-800-CAMPBNB',
              onTap: () {
                // TODO: Appeler
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTextStyles.bodyLarge),
        subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildContactOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTextStyles.bodyLarge),
        subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
