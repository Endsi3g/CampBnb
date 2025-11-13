import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/models/reservation_model.dart';
import '../providers/reservation_provider.dart';

class SuggestAlternativeDatesScreen extends ConsumerStatefulWidget {
  final ReservationModel reservation;

  const SuggestAlternativeDatesScreen({super.key, required this.reservation});

  @override
  ConsumerState<SuggestAlternativeDatesScreen> createState() =>
      _SuggestAlternativeDatesScreenState();
}

class _SuggestAlternativeDatesScreenState
    extends ConsumerState<SuggestAlternativeDatesScreen> {
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Suggérer d\'autres dates')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dates originales', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Arrivée', style: AppTextStyles.bodySmall),
                      Text(
                        '${widget.reservation.checkIn.day}/${widget.reservation.checkIn.month}/${widget.reservation.checkIn.year}',
                        style: AppTextStyles.bodyLarge,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Départ', style: AppTextStyles.bodySmall),
                      Text(
                        '${widget.reservation.checkOut.day}/${widget.reservation.checkOut.month}/${widget.reservation.checkOut.year}',
                        style: AppTextStyles.bodyLarge,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Nouvelles dates suggérées', style: AppTextStyles.labelLarge),
            const SizedBox(height: 16),
            TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedStartDate, day) ||
                    isSameDay(_selectedEndDate, day);
              },
              rangeSelectionMode: RangeSelectionMode.enforced,
              rangeStartDay: _selectedStartDate,
              rangeEndDay: _selectedEndDate,
              onDaySelected: _onDaySelected,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
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
                  color: AppColors.primary.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                rangeEndDecoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                rangeDayDecoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            if (_selectedStartDate != null && _selectedEndDate != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nouvelle arrivée',
                          style: AppTextStyles.bodyMedium,
                        ),
                        Text(
                          '${_selectedStartDate!.day}/${_selectedStartDate!.month}/${_selectedStartDate!.year}',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Nouveau départ', style: AppTextStyles.bodyMedium),
                        Text(
                          '${_selectedEndDate!.day}/${_selectedEndDate!.month}/${_selectedEndDate!.year}',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Durée', style: AppTextStyles.bodyMedium),
                        Text(
                          '${_selectedEndDate!.difference(_selectedStartDate!).inDays} nuit${_selectedEndDate!.difference(_selectedStartDate!).inDays > 1 ? 's' : ''}',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            Consumer(
              builder: (context, ref, child) {
                final notifier = ref.read(reservationNotifierProvider.notifier);
                final isLoading = ref
                    .watch(reservationNotifierProvider)
                    .isLoading;

                return CustomButton(
                  text: 'Envoyer la suggestion',
                  onPressed:
                      (_selectedStartDate != null &&
                          _selectedEndDate != null &&
                          !isLoading)
                      ? () async {
                          try {
                            await notifier.suggestAlternativeDates(
                              reservationId: widget.reservation.id,
                              newCheckIn: _selectedStartDate!,
                              newCheckOut: _selectedEndDate!,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Suggestion envoyée au client'),
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
                        }
                      : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

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
}
