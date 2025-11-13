import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/security/mfa_service.dart';
import '../../../../core/security/permissions_service.dart';
import '../../../../core/security/gdpr_service.dart';
import '../../../../core/config/app_config.dart';

/// Écran de paramètres de sécurité
class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends ConsumerState<SecuritySettingsScreen> {
  bool _mfaEnabled = false;
  bool _isLoading = false;
  String? _qrCodeData;
  List<String> _backupCodes = [];

  @override
  void initState() {
    super.initState();
    _checkMFAStatus();
  }

  Future<void> _checkMFAStatus() async {
    setState(() => _isLoading = true);
    try {
      _mfaEnabled = await MFAService.instance.isMFAEnabled();
    } catch (e) {
 AppConfig.logger.e('Erreur lors de la vérification du MFA: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _enableMFA() async {
    try {
      setState(() => _isLoading = true);
      final result = await MFAService.instance.enableTOTP();
      
      setState(() {
 _qrCodeData = result['qrCodeUrl'];
        _mfaEnabled = true;
      });

      // Générer les codes de secours
      _backupCodes = await MFAService.instance.generateBackupCodes();

      if (mounted) {
 _showMFAEnabledDialog(result['manualEntryKey'], _backupCodes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _disableMFA() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
 title: const Text('Désactiver l\'authentification à deux facteurs'),
        content: const Text(
 'Êtes-vous sûr de vouloir désactiver l\'authentification à deux facteurs ? '
 'Votre compte sera moins sécurisé.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
 child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
 child: const Text('Désactiver'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);
        await MFAService.instance.disableMFA();
        setState(() => _mfaEnabled = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('MFA désactivé')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(content: Text('Erreur: $e')),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMFAEnabledDialog(String? manualKey, List<String> backupCodes) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
 title: const Text('Authentification à deux facteurs activée'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_qrCodeData != null) ...[
 const Text('Scannez ce code QR avec votre application d\'authentification:'),
                const SizedBox(height: 16),
                QrImageView(
                  data: _qrCodeData!,
                  size: 200,
                ),
                const SizedBox(height: 16),
              ],
              if (manualKey != null) ...[
 const Text('Ou entrez cette clé manuellement:'),
                const SizedBox(height: 8),
                SelectableText(
                  manualKey,
 style: const TextStyle(fontFamily: 'monospace'),
                ),
                const SizedBox(height: 16),
              ],
 const Text('Codes de secours (sauvegardez-les en lieu sûr):'),
              const SizedBox(height: 8),
              ...backupCodes.map((code) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: SelectableText(
                  code,
 style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
 child: const Text('J\'ai sauvegardé les codes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
 title: const Text('Sécurité'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Section Authentification
 _buildSectionHeader('Authentification'),
                ListTile(
                  leading: const Icon(Icons.security),
 title: const Text('Authentification à deux facteurs'),
 subtitle: Text(_mfaEnabled ? 'Activée' : 'Désactivée'),
                  trailing: Switch(
                    value: _mfaEnabled,
                    onChanged: (value) {
                      if (value) {
                        _enableMFA();
                      } else {
                        _disableMFA();
                      }
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.lock),
 title: const Text('Changer le mot de passe'),
                  onTap: () {
                    // TODO: Implémenter le changement de mot de passe
                    ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('Fonctionnalité à venir')),
                    );
                  },
                ),

                // Section Permissions
 _buildSectionHeader('Permissions'),
                FutureBuilder<List<String>>(
                  future: PermissionsService.instance.getUserRoles(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const ListTile(
 title: Text('Chargement...'),
                      );
                    }
                    return ListTile(
                      leading: const Icon(Icons.verified_user),
 title: const Text('Rôles'),
 subtitle: Text(snapshot.data!.join(', ')),
                    );
                  },
                ),

                // Section RGPD
 _buildSectionHeader('Confidentialité (RGPD)'),
                FutureBuilder<Map<String, bool>>(
                  future: GDPRService.instance.getUserConsents(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const ListTile(
 title: Text('Chargement...'),
                      );
                    }
                    final consents = snapshot.data!;
                    return Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.privacy_tip),
 title: const Text('Traitement des données'),
 subtitle: Text(consents['data_processing'] == true ? 'Consenti' : 'Non consenti'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.marketing),
 title: const Text('Marketing'),
 subtitle: Text(consents['marketing'] == true ? 'Consenti' : 'Non consenti'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.analytics),
 title: const Text('Analytics'),
 subtitle: Text(consents['analytics'] == true ? 'Consenti' : 'Non consenti'),
                        ),
                      ],
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.download),
 title: const Text('Exporter mes données'),
                  onTap: () async {
                    try {
                      final data = await GDPRService.instance.exportUserData();
                      // TODO: Permettre le téléchargement du fichier
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('Export en cours...')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(content: Text('Erreur: $e')),
                        );
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
 title: const Text('Supprimer mon compte', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
 title: const Text('Supprimer mon compte'),
                        content: const Text(
 'Cette action est irréversible. Toutes vos données seront supprimées définitivement.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
 child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
 child: const Text('Supprimer'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      try {
                        await GDPRService.instance.deleteUserData();
                        if (mounted) {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(content: Text('Erreur: $e')),
                          );
                        }
                      }
                    }
                  },
                ),

                // Section Informations
 _buildSectionHeader('Informations'),
                ListTile(
                  leading: const Icon(Icons.description),
 title: const Text('Politique de confidentialité'),
                  onTap: () {
                    // TODO: Ouvrir la politique de confidentialité
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.gavel),
 title: const Text('Conditions d\'utilisation'),
                  onTap: () {
 // TODO: Ouvrir les conditions d'utilisation
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

