import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _reservationsEnabled = true;
  bool _messagesEnabled = true;
  bool _reviewsEnabled = true;
  bool _promotionsEnabled = false;
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _smsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        children: [
          _buildSectionTitle('Types de notifications'),
          SwitchListTile(
            title: const Text('Réservations'),
            subtitle: const Text(
              'Nouvelles réservations, confirmations, annulations',
            ),
            value: _reservationsEnabled,
            onChanged: (value) {
              setState(() {
                _reservationsEnabled = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Messages'),
            subtitle: const Text('Nouveaux messages de la messagerie'),
            value: _messagesEnabled,
            onChanged: (value) {
              setState(() {
                _messagesEnabled = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Avis et évaluations'),
            subtitle: const Text('Nouveaux avis sur vos campings'),
            value: _reviewsEnabled,
            onChanged: (value) {
              setState(() {
                _reviewsEnabled = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Promotions et offres'),
            subtitle: const Text('Offres spéciales et promotions'),
            value: _promotionsEnabled,
            onChanged: (value) {
              setState(() {
                _promotionsEnabled = value;
              });
            },
          ),

          _buildSectionTitle('Canaux de notification'),
          SwitchListTile(
            title: const Text('Notifications push'),
            subtitle: const Text(
              'Recevoir des notifications sur votre appareil',
            ),
            value: _pushEnabled,
            onChanged: (value) {
              setState(() {
                _pushEnabled = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Email'),
            subtitle: const Text('Recevoir des notifications par email'),
            value: _emailEnabled,
            onChanged: (value) {
              setState(() {
                _emailEnabled = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('SMS'),
            subtitle: const Text('Recevoir des notifications par SMS'),
            value: _smsEnabled,
            onChanged: (value) {
              setState(() {
                _smsEnabled = value;
              });
            },
          ),

          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Les notifications importantes (comme les confirmations de réservation) seront toujours envoyées, même si vous désactivez certaines notifications.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondaryLight,
              ),
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
}
