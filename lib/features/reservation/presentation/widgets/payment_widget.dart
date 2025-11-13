import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/services/payment_service.dart';
import '../../../../shared/widgets/custom_button.dart';

class PaymentWidget extends ConsumerStatefulWidget {
  final String reservationId;
  final double amount;
  final Function(bool)? onPaymentComplete;

  const PaymentWidget({
    super.key,
    required this.reservationId,
    required this.amount,
    this.onPaymentComplete,
  });

  @override
  ConsumerState<PaymentWidget> createState() => _PaymentWidgetState();
}

class _PaymentWidgetState extends ConsumerState<PaymentWidget> {
  bool _isProcessing = false;

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    try {
      final session = await PaymentService.createPaymentSession(
        reservationId: widget.reservationId,
        amount: widget.amount,
 currency: 'CAD',
 successUrl: 'campbnb://payment/success',
 cancelUrl: 'campbnb://payment/cancel',
      );

 // TODO: Ouvrir l'URL de paiement Stripe dans un navigateur ou WebView
 // Pour l'instant, on simule un succès
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        widget.onPaymentComplete?.call(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
 content: Text('Paiement réussi !'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        widget.onPaymentComplete?.call(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
 content: Text('Erreur de paiement: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
 'Paiement',
              style: AppTextStyles.h4,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
 'Total',
                  style: AppTextStyles.bodyLarge,
                ),
                Text(
 '\$${widget.amount.toStringAsFixed(2)} CAD',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomButton(
 text: 'Payer maintenant',
              onPressed: _isProcessing ? null : _processPayment,
              isLoading: _isProcessing,
            ),
            const SizedBox(height: 8),
            Text(
 'Paiement sécurisé via Stripe',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

