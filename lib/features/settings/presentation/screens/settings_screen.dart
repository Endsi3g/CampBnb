import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/l10n_helper.dart';
import '../widgets/language_selector.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
 title: Text(context.t('settings')),
      ),
      body: ListView(
        children: [
 _buildSectionTitle('Compte'),
          _buildMenuItem(
            context,
            icon: Icons.person,
 title: 'Profil',
 subtitle: 'Informations personnelles',
            onTap: () {},
          ),
          _buildMenuItem(
            context,
            icon: Icons.security,
            title: 'Sécurité et compte',
            subtitle: 'Mot de passe, authentification',
            onTap: () {
              context.push('/settings/security');
            },
          ),
 _buildSectionTitle('Notifications'),
          _buildMenuItem(
            context,
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Gérer les notifications',
            onTap: () {
              context.push('/settings/notifications');
            },
          ),
 _buildSectionTitle(context.t('application') ?? 'Application'),
          const LanguageSelector(),
          _buildMenuItem(
            context,
            icon: Icons.dark_mode,
            title: context.t('theme') ?? 'Thème',
            subtitle: 'Clair, sombre, système',
            onTap: () {},
          ),
          _buildSectionTitle('Données et Analytics'),
          _buildMenuItem(
            context,
            icon: Icons.analytics,
            title: 'Dashboard Analytics',
            subtitle: 'Visualiser les données d\'utilisation',
            onTap: () {
              context.push('/analytics/dashboard');
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.privacy_tip,
            title: 'Confidentialité',
            subtitle: 'Gérer vos données et consentements',
            onTap: () {
              context.push('/settings/privacy');
            },
          ),
          _buildSectionTitle('Support'),
          _buildMenuItem(
            context,
            icon: Icons.help_outline,
            title: 'Aide et support',
            subtitle: 'FAQ, contact',
            onTap: () {
              context.push('/help');
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.info,
 title: 'À propos',
 subtitle: 'Version, conditions',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: AppTextStyles.labelLarge.copyWith(
          color: AppColors.textSecondaryLight,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyLarge),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            )
          : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

