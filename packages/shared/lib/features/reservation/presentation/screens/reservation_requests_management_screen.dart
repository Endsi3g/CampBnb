import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/reservation_model.dart';
import '../../../../shared/models/listing_model.dart';
import '../providers/reservation_provider.dart';
import 'reservation_request_details_screen.dart';

class ReservationRequestsManagementScreen extends ConsumerStatefulWidget {
  const ReservationRequestsManagementScreen({super.key});

  @override
  ConsumerState<ReservationRequestsManagementScreen> createState() =>
      _ReservationRequestsManagementScreenState();
}

class _ReservationRequestsManagementScreenState
    extends ConsumerState<ReservationRequestsManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des réservations'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'En attente'),
            Tab(text: 'Confirmées'),
            Tab(text: 'Terminées'),
            Tab(text: 'Annulées'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReservationsList(ReservationStatus.pending),
          _buildReservationsList(ReservationStatus.confirmed),
          _buildReservationsList(ReservationStatus.completed),
          _buildReservationsList(ReservationStatus.cancelled),
        ],
      ),
    );
  }

  Widget _buildReservationsList(ReservationStatus status) {
    // Récupérer les réservations depuis le provider
    final reservationsAsync = ref.watch(reservationsProvider(
      status: status,
      isHost: true,
    ));

    return reservationsAsync.when(
      data: (reservations) {
        if (reservations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: AppColors.textSecondaryLight,
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune réservation ${_getStatusText(status)}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reservations.length,
          itemBuilder: (context, index) {
            final reservation = reservations[index];
            // TODO: Récupérer le listing depuis le provider
            final listing = _getMockListingForReservation(reservation.listingId);
            return _buildReservationCard(reservation, listing);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur: $error',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  ListingModel _getMockListingForReservation(String listingId) {
    // TODO: Récupérer depuis le provider
    return ListingModel(
      id: listingId,
      hostId: '1',
      title: 'Camping',
      description: 'Description',
      type: ListingType.tent,
      latitude: 46.5,
      longitude: -75.5,
      address: 'Adresse',
      city: 'Ville',
      province: 'QC',
      postalCode: 'H1A 1A1',
      pricePerNight: 50.0,
      maxGuests: 4,
      bedrooms: 1,
      bathrooms: 1,
      images: [],
      amenities: [],
    );
  }

  Widget _buildReservationCard(ReservationModel reservation, ListingModel listing) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.push(
            '/reservation/${reservation.id}/details',
            extra: {
              'reservation': reservation,
              'listing': listing,
              'isHost': true,
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Réservation #${reservation.id.substring(0, 8)}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusChip(reservation.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondaryLight),
                  const SizedBox(width: 8),
                  Text(
                    '${reservation.checkIn.day}/${reservation.checkIn.month}/${reservation.checkIn.year} - ${reservation.checkOut.day}/${reservation.checkOut.month}/${reservation.checkOut.year}',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: AppColors.textSecondaryLight),
                  const SizedBox(width: 8),
                  Text(
                    '${reservation.numberOfGuests} invité${reservation.numberOfGuests > 1 ? 's' : ''}',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const Spacer(),
                  Text(
                    '${reservation.totalPrice.toStringAsFixed(2)} \$',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ReservationStatus status) {
    Color color;
    String text;

    switch (status) {
      case ReservationStatus.pending:
        color = Colors.orange;
        text = 'En attente';
        break;
      case ReservationStatus.confirmed:
        color = Colors.green;
        text = 'Confirmée';
        break;
      case ReservationStatus.cancelled:
        color = Colors.red;
        text = 'Annulée';
        break;
      case ReservationStatus.completed:
        color = Colors.blue;
        text = 'Terminée';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getStatusText(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.pending:
        return 'en attente';
      case ReservationStatus.confirmed:
        return 'confirmée';
      case ReservationStatus.cancelled:
        return 'annulée';
      case ReservationStatus.completed:
        return 'terminée';
    }
  }

}

