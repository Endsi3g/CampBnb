import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';

class HostDashboardScreen extends StatelessWidget {
  const HostDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
 title: const Text('Tableau de bord hôte'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
 'Réservations',
 '12',
                    Icons.book_online,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
 'Revenus',
 '\$2,450',
                    Icons.attach_money,
                    AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
 'Annonces',
 '3',
                    Icons.home,
                    AppColors.accent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
 'Note moyenne',
 '4.8',
                    Icons.star,
                    AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Quick Actions
            Text(
 'Actions rapides',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 16),
            CustomButton(
 text: 'Ajouter une annonce',
 onPressed: () => context.push('/host/add-listing'),
              icon: Icons.add,
            ),
            const SizedBox(height: 16),
            // Recent Reservations
            Text(
 'Réservations récentes',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 16),
            // TODO: Liste des réservations
            _buildReservationCard(
 'Camping du Lac',
 'Jean Dupont',
 '20-22 juin 2024',
 '\$90',
            ),
            const SizedBox(height: 8),
            _buildReservationCard(
 'Chalet Boréal',
 'Marie Tremblay',
 '25-27 juin 2024',
 '\$360',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.h3.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationCard(
    String listingName,
    String guestName,
    String dates,
    String amount,
  ) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: Text(listingName, style: AppTextStyles.bodyLarge),
 subtitle: Text('$guestName • $dates'),
        trailing: Text(
          amount,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          // TODO: Naviguer vers les détails de la réservation
        },
      ),
    );
  }
}

