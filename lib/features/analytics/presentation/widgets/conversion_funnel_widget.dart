import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/services/supabase_service.dart';

/// Widget pour visualiser le funnel de conversion
class ConversionFunnelWidget extends StatefulWidget {
  final String period;
  final DateTime date;

  const ConversionFunnelWidget({
    super.key,
    required this.period,
    required this.date,
  });

  @override
  State<ConversionFunnelWidget> createState() => _ConversionFunnelWidgetState();
}

class _ConversionFunnelWidgetState extends State<ConversionFunnelWidget> {
  Map<String, int>? _funnelData;

  @override
  void initState() {
    super.initState();
    _loadFunnelData();
  }

  @override
  void didUpdateWidget(ConversionFunnelWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period != widget.period || oldWidget.date != widget.date) {
      _loadFunnelData();
    }
  }

  Future<void> _loadFunnelData() async {
    try {
      final startDate = _getStartDate();
      final endDate = widget.date.add(const Duration(days: 1));

      // Compter les conversions par étape du funnel
      final conversions = await SupabaseService.from('analytics_conversions')
          .select('funnel_step, conversion_type')
          .gte('created_at', startDate.toIso8601String())
          .lt('created_at', endDate.toIso8601String());

      final funnel = <String, int>{
        'awareness': 0,
        'interest': 0,
        'consideration': 0,
        'purchase': 0,
        'retention': 0,
      };

      for (final conversion in conversions as List) {
        final step = conversion['funnel_step'] as String?;
        if (step != null && funnel.containsKey(step)) {
          funnel[step] = (funnel[step] ?? 0) + 1;
        }
      }

      // Calculer les sessions pour awareness
      final sessions = await SupabaseService.from('analytics_sessions')
          .select('id')
          .gte('started_at', startDate.toIso8601String())
          .lt('started_at', endDate.toIso8601String());

      funnel['awareness'] = (sessions as List).length;

      setState(() {
        _funnelData = funnel;
      });
    } catch (e) {
      setState(() {
        _funnelData = {
          'awareness': 0,
          'interest': 0,
          'consideration': 0,
          'purchase': 0,
          'retention': 0,
        };
      });
    }
  }

  DateTime _getStartDate() {
    switch (widget.period) {
      case 'daily':
        return DateTime(widget.date.year, widget.date.month, widget.date.day);
      case 'weekly':
        return widget.date.subtract(Duration(days: widget.date.weekday - 1));
      case 'monthly':
        return DateTime(widget.date.year, widget.date.month, 1);
      default:
        return widget.date;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_funnelData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final maxValue = _funnelData!.values.reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('Aucune donnée disponible')),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildFunnelStep(
              'Conscience',
              _funnelData!['awareness'] ?? 0,
              maxValue,
              AppColors.primary,
            ),
            const SizedBox(height: 8),
            _buildFunnelStep(
              'Intérêt',
              _funnelData!['interest'] ?? 0,
              maxValue,
              AppColors.secondary,
            ),
            const SizedBox(height: 8),
            _buildFunnelStep(
              'Considération',
              _funnelData!['consideration'] ?? 0,
              maxValue,
              Colors.orange,
            ),
            const SizedBox(height: 8),
            _buildFunnelStep(
              'Achat',
              _funnelData!['purchase'] ?? 0,
              maxValue,
              Colors.green,
            ),
            const SizedBox(height: 8),
            _buildFunnelStep(
              'Rétention',
              _funnelData!['retention'] ?? 0,
              maxValue,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFunnelStep(String label, int value, int maxValue, Color color) {
    final percentage = maxValue > 0 ? (value / maxValue * 100) : 0.0;
    final conversionRate = _funnelData!['awareness']! > 0
        ? (value / _funnelData!['awareness']! * 100)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$value (${conversionRate.toStringAsFixed(1)}%)',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 24,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
