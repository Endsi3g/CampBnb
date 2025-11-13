import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/services/analytics_service.dart';
import '../../analytics/presentation/widgets/analytics_tracker.dart';

/// Écran de paramètres privacy pour gérer les consentements analytics
class PrivacySettingsScreen extends ConsumerStatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<PrivacySettingsScreen> createState() =>
      _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends ConsumerState<PrivacySettingsScreen> {
  bool _analyticsEnabled = true;
  bool _personalizationEnabled = true;
  bool _dataSharingEnabled = false;
  String _anonymizationLevel = 'standard';
  int _dataRetentionDays = 365;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
  }

  Future<void> _loadPrivacySettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Les paramètres sont gérés par le service Analytics
      // On récupère les valeurs par défaut
      final analytics = AnalyticsService.instance;
      _analyticsEnabled = analytics.isAnalyticsEnabled;
    } catch (e) {
      // Erreur silencieuse
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _savePrivacySettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await AnalyticsService.instance.updatePrivacyConsent(
        analyticsEnabled: _analyticsEnabled,
        personalizationEnabled: _personalizationEnabled,
        dataSharingEnabled: _dataSharingEnabled,
        dataRetentionDays: _dataRetentionDays,
        anonymizationLevel: _anonymizationLevel,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paramètres de confidentialité sauvegardés'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnalyticsTracker(
      screenName: 'privacy_settings',
      screenClass: 'PrivacySettingsScreen',
      child: Scaffold(
        appBar: AppBar(title: const Text('Confidentialité et Données')),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête
                    Text('Gestion de vos données', style: AppTextStyles.h2),
                    const SizedBox(height: 8),
                    Text(
                      'Contrôlez comment vos données sont collectées et utilisées pour améliorer votre expérience.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Analytics
                    _buildSection(
                      title: 'Analytics et Mesures',
                      description:
                          'Autoriser la collecte de données d\'utilisation pour améliorer l\'application',
                      child: SwitchListTile(
                        title: const Text('Analytics activé'),
                        subtitle: const Text(
                          'Collecte anonyme de données d\'utilisation (écrans visités, actions, etc.)',
                        ),
                        value: _analyticsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _analyticsEnabled = value;
                          });
                          _savePrivacySettings();
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Personnalisation
                    _buildSection(
                      title: 'Personnalisation',
                      description:
                          'Utiliser vos données pour personnaliser votre expérience',
                      child: SwitchListTile(
                        title: const Text('Personnalisation activée'),
                        subtitle: const Text(
                          'Recommandations personnalisées basées sur vos préférences',
                        ),
                        value: _personalizationEnabled,
                        onChanged: _analyticsEnabled
                            ? (value) {
                                setState(() {
                                  _personalizationEnabled = value;
                                });
                                _savePrivacySettings();
                              }
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Partage de données
                    _buildSection(
                      title: 'Partage de données',
                      description:
                          'Autoriser le partage de données anonymisées avec des partenaires',
                      child: SwitchListTile(
                        title: const Text('Partage de données'),
                        subtitle: const Text(
                          'Partage de données agrégées et anonymisées pour la recherche',
                        ),
                        value: _dataSharingEnabled,
                        onChanged: _analyticsEnabled
                            ? (value) {
                                setState(() {
                                  _dataSharingEnabled = value;
                                });
                                _savePrivacySettings();
                              }
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Niveau d'anonymisation
                    _buildSection(
                      title: 'Niveau d\'anonymisation',
                      description:
                          'Choisissez le niveau de protection de vos données',
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            title: const Text('Minimal'),
                            subtitle: const Text('Données de base uniquement'),
                            value: 'minimal',
                            groupValue: _anonymizationLevel,
                            onChanged: (value) {
                              setState(() {
                                _anonymizationLevel = value!;
                              });
                              _savePrivacySettings();
                            },
                          ),
                          RadioListTile<String>(
                            title: const Text('Standard'),
                            subtitle: const Text('Anonymisation recommandée'),
                            value: 'standard',
                            groupValue: _anonymizationLevel,
                            onChanged: (value) {
                              setState(() {
                                _anonymizationLevel = value!;
                              });
                              _savePrivacySettings();
                            },
                          ),
                          RadioListTile<String>(
                            title: const Text('Maximum'),
                            subtitle: const Text('Anonymisation maximale'),
                            value: 'maximum',
                            groupValue: _anonymizationLevel,
                            onChanged: (value) {
                              setState(() {
                                _anonymizationLevel = value!;
                              });
                              _savePrivacySettings();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Rétention des données
                    _buildSection(
                      title: 'Rétention des données',
                      description:
                          'Durée de conservation de vos données anonymes',
                      child: Column(
                        children: [
                          Slider(
                            value: _dataRetentionDays.toDouble(),
                            min: 30,
                            max: 730,
                            divisions: 14,
                            label: '$_dataRetentionDays jours',
                            onChanged: (value) {
                              setState(() {
                                _dataRetentionDays = value.toInt();
                              });
                            },
                            onChangeEnd: (_) {
                              _savePrivacySettings();
                            },
                          ),
                          Text(
                            'Vos données anonymes seront conservées pendant $_dataRetentionDays jours',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Informations légales
                    _buildInfoSection(),
                    const SizedBox(height: 24),
                    // Bouton de suppression des données
                    Center(
                      child: TextButton(
                        onPressed: () {
                          _showDeleteDataDialog();
                        },
                        child: Text(
                          'Supprimer toutes mes données',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h3),
        const SizedBox(height: 4),
        Text(
          description,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 12),
        Card(child: child),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Card(
      color: AppColors.surfaceLight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vos droits',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• Accès à vos données\n'
              '• Rectification des données\n'
              '• Suppression des données\n'
              '• Portabilité des données\n'
              '• Opposition au traitement',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Toutes les données sont anonymisées et ne peuvent pas être liées à votre identité personnelle.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondaryLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer toutes les données'),
        content: const Text(
          'Cette action supprimera définitivement toutes vos données analytics. '
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implémenter la suppression des données
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Suppression des données en cours...'),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
