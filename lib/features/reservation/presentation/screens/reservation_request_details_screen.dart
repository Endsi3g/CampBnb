import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/models/reservation_model.dart';
import '../../../../shared/models/listing_model.dart';
import '../providers/reservation_provider.dart';

class ReservationRequestDetailsScreen extends ConsumerWidget {
  final ReservationModel reservation;
  final ListingModel listing;
  final bool isHost;

  const ReservationRequestDetailsScreen({
    super.key,
    required this.reservation,
    required this.listing,
    this.isHost = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détails de la réservation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statut de la réservation
            _buildStatusCard(context),
            const SizedBox(height: 24),

            // Informations du camping
            _buildListingInfo(context),
            const SizedBox(height: 24),

            // Dates
            _buildDatesSection(context),
            const SizedBox(height: 24),

            // Invités
            _buildGuestsSection(context),
            const SizedBox(height: 24),

            // Prix
            _buildPriceSection(context),
            const SizedBox(height: 24),

            // Message du client
            if (reservation.message != null) ...[
              _buildMessageSection(context),
              const SizedBox(height: 24),
            ],

            // Actions
            if (isHost && reservation.status == ReservationStatus.pending)
              _buildHostActions(context, ref),
            if (!isHost && reservation.status == ReservationStatus.pending)
              _buildGuestActions(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    Color statusColor;
    String statusText;

    switch (reservation.status) {
      case ReservationStatus.pending:
        statusColor = Colors.orange;
        statusText = 'En attente';
        break;
      case ReservationStatus.confirmed:
        statusColor = Colors.green;
        statusText = 'Confirmée';
        break;
      case ReservationStatus.cancelled:
        statusColor = Colors.red;
        statusText = 'Annulée';
        break;
      case ReservationStatus.completed:
        statusColor = Colors.blue;
        statusText = 'Terminée';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: statusColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              statusText,
              style: AppTextStyles.headingMedium.copyWith(color: statusColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListingInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Camping', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  color: AppColors.primary.withOpacity(0.1),
                  child: listing.images.isNotEmpty
                      ? Image.network(listing.images.first, fit: BoxFit.cover)
                      : Icon(Icons.image, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${listing.city}, ${listing.province}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDatesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dates', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildDateRow(
                context,
                'Arrivée',
                reservation.checkIn,
                Icons.calendar_today,
              ),
              const Divider(),
              _buildDateRow(
                context,
                'Départ',
                reservation.checkOut,
                Icons.calendar_today,
              ),
              const Divider(),
              _buildDateRow(
                context,
                'Durée',
                null,
                Icons.hotel,
                subtitle:
                    '${reservation.numberOfNights} nuit${reservation.numberOfNights > 1 ? 's' : ''}',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateRow(
    BuildContext context,
    String label,
    DateTime? date,
    IconData icon, {
    String? subtitle,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall),
              Text(
                subtitle ??
                    (date != null
                        ? '${date.day}/${date.month}/${date.year}'
                        : ''),
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGuestsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Invités', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.people, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                '${reservation.numberOfGuests} invité${reservation.numberOfGuests > 1 ? 's' : ''}',
                style: AppTextStyles.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Prix', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Prix total', style: AppTextStyles.bodyLarge),
                  Text(
                    '${reservation.totalPrice.toStringAsFixed(2)} \$',
                    style: AppTextStyles.headingMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Message', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(reservation.message!, style: AppTextStyles.bodyMedium),
        ),
      ],
    );
  }

  Widget _buildHostActions(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(reservationNotifierProvider.notifier);
    final isLoading = ref.watch(reservationNotifierProvider).isLoading;

    return Column(
      children: [
        CustomButton(
          text: 'Accepter',
          onPressed: isLoading
              ? null
              : () async {
                  try {
                    await notifier.acceptReservation(reservation.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Réservation acceptée avec succès'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      context.pop();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: 'Refuser',
          onPressed: isLoading
              ? null
              : () async {
                  final reason = await showDialog<String>(
                    context: context,
                    builder: (context) {
                      final controller = TextEditingController();
                      return AlertDialog(
                        title: const Text('Refuser la réservation'),
                        content: TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            labelText: 'Raison du refus (optionnel)',
                          ),
                          maxLines: 3,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, controller.text),
                            child: const Text('Refuser'),
                          ),
                        ],
                      );
                    },
                  );

                  if (reason != null || reason == '') {
                    try {
                      await notifier.rejectReservation(
                        reservation.id,
                        reason: reason,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Réservation refusée'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        context.pop();
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
          variant: ButtonVariant.outline,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            context.push('/reservation/${reservation.id}/suggest-dates');
          },
          child: const Text('Suggérer d\'autres dates'),
        ),
      ],
    );
  }

  Widget _buildGuestActions(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(reservationNotifierProvider.notifier);
    final isLoading = ref.watch(reservationNotifierProvider).isLoading;

    return CustomButton(
      text: 'Annuler la réservation',
      onPressed: isLoading
          ? null
          : () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Annuler la réservation'),
                  content: const Text(
                    'Êtes-vous sûr de vouloir annuler cette réservation ?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Non'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Oui'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                try {
                  await notifier.cancelReservation(reservation.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Réservation annulée'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    context.pop();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
      variant: ButtonVariant.outline,
    );
  }
}
