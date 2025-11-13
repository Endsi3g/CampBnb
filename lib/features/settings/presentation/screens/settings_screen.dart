import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/l10n_helper.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/cache/cache_validator.dart';
import '../../../../core/cache/cache_service.dart';
import '../widgets/language_selector.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t('settings'))),
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
          // Section Debug (visible uniquement en mode développement)
          if (AppConfig.isDevelopment) ...[
            _buildSectionTitle('Debug'),
            _buildMenuItem(
              context,
              icon: Icons.bug_report,
              title: 'Tester le Cache',
              subtitle: 'Valider le fonctionnement du cache',
              onTap: () => _testCache(context),
            ),
            _buildMenuItem(
              context,
              icon: Icons.storage,
              title: 'Informations Cache',
              subtitle: 'Voir la taille et les statistiques',
              onTap: () => _showCacheInfo(context),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _testCache(BuildContext context) async {
    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Exécuter la validation
      await CacheValidator.printValidationReport();

      final results = await CacheValidator.validateCache();

      if (context.mounted) {
        Navigator.of(context).pop(); // Fermer le loading

        // Afficher les résultats
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Résultats du Test Cache'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Score: ${results['score']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Taux de réussite: ${results['success_rate']}%'),
                  if (results['cache_size_mb'] != null) ...[
                    const SizedBox(height: 8),
                    Text('Taille du cache: ${results['cache_size_mb']} MB'),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    'Tests:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...(results['tests'] as Map<String, bool>).entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            entry.value ? Icons.check_circle : Icons.error,
                            color: entry.value ? Colors.green : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(entry.key)),
                        ],
                      ),
                    ),
                  ),
                  if (results['errors'].isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Erreurs:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...(results['errors'] as List<String>).map(
                      (error) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          '• $error',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fermer'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Fermer le loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du test: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _showCacheInfo(BuildContext context) async {
    try {
      final cacheService = CacheService();
      final size = await cacheService.getCacheSize();
      final sizeMB = (size / 1024 / 1024).toStringAsFixed(2);
      final sizeKB = (size / 1024).toStringAsFixed(2);

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Informations Cache'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Taille totale', '$sizeMB MB ($sizeKB KB)'),
                _buildInfoRow('Taille en octets', size.toString()),
                const SizedBox(height: 16),
                const Text(
                  'Types de cache:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Listings', '24 heures'),
                _buildInfoRow('Réservations', '1 heure'),
                _buildInfoRow('Données utilisateur', '12 heures'),
                _buildInfoRow('Résultats de recherche', '24 heures'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await cacheService.clearCache();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cache vidé avec succès'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                child: const Text(
                  'Vider le Cache',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fermer'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
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
