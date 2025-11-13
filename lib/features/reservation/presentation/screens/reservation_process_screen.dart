import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/models/listing_model.dart';

class ReservationProcessScreen extends ConsumerStatefulWidget {
  final ListingModel listing;

  const ReservationProcessScreen({super.key, required this.listing});

  @override
  ConsumerState<ReservationProcessScreen> createState() =>
      _ReservationProcessScreenState();
}

class _ReservationProcessScreenState
    extends ConsumerState<ReservationProcessScreen> {
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  DateTime _focusedDay = DateTime.now();
  int _adults = 2;
  int _children = 0;

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (_selectedStartDate == null || _selectedEndDate != null) {
      setState(() {
        _selectedStartDate = selectedDay;
        _selectedEndDate = null;
      });
    } else if (selectedDay.isAfter(_selectedStartDate!)) {
      setState(() {
        _selectedEndDate = selectedDay;
      });
    } else {
      setState(() {
        _selectedStartDate = selectedDay;
        _selectedEndDate = null;
      });
    }
  }

  double _calculateTotal() {
    if (_selectedStartDate == null || _selectedEndDate == null) {
      return 0.0;
    }
    final nights = _selectedEndDate!.difference(_selectedStartDate!).inDays;
    return widget.listing.pricePerNight * nights;
  }

  @override
  Widget build(BuildContext context) {
    final total = _calculateTotal();

    return Scaffold(
      appBar: AppBar(title: const Text('Réserver votre séjour')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dates Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sélectionnez vos dates', style: AppTextStyles.h2),
                  const SizedBox(height: 16),
                  TableCalendar(
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 365)),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedStartDate, day) ||
                          isSameDay(_selectedEndDate, day);
                    },
                    rangeSelectionMode: RangeSelectionMode.enforced,
                    rangeStartDay: _selectedStartDate,
                    rangeEndDay: _selectedEndDate,
                    onDaySelected: _onDaySelected,
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                    },
                    calendarStyle: CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      rangeStartDecoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      rangeEndDecoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      rangeDayDecoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Guests Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Qui vous accompagne ?', style: AppTextStyles.h2),
                  const SizedBox(height: 16),
                  _buildGuestCounter(
                    icon: Icons.person,
                    label: 'Adultes',
                    subtitle: '13 ans et plus',
                    count: _adults,
                    onDecrement: () {
                      if (_adults > 1) {
                        setState(() => _adults--);
                      }
                    },
                    onIncrement: () {
                      setState(() => _adults++);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildGuestCounter(
                    icon: Icons.child_care,
                    label: 'Enfants',
                    subtitle: '2-12 ans',
                    count: _children,
                    onDecrement: () {
                      if (_children > 0) {
                        setState(() => _children--);
                      }
                    },
                    onIncrement: () {
                      setState(() => _children++);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: AppTextStyles.h3,
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Afficher les détails du prix
                    },
                    child: const Text('Détails du prix'),
                  ),
                ],
              ),
              CustomButton(
                text: 'Confirmer la demande',
                onPressed:
                    (_selectedStartDate != null && _selectedEndDate != null)
                    ? () {
                        // TODO: Créer la réservation
                      }
                    : null,
                width: 180,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuestCounter({
    required IconData icon,
    required String label,
    required String subtitle,
    required int count,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.textPrimaryLight),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodyLarge),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: onDecrement,
              icon: const Icon(Icons.remove),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surfaceLight,
                shape: const CircleBorder(),
              ),
            ),
            const SizedBox(width: 16),
            Text(count.toString(), style: AppTextStyles.bodyLarge),
            const SizedBox(width: 16),
            IconButton(
              onPressed: onIncrement,
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
