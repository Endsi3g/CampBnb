import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/services/supabase_service.dart';

/// Widget pour visualiser la satisfaction utilisateur
class SatisfactionChartWidget extends StatefulWidget {
  final String period;
  final DateTime date;

  const SatisfactionChartWidget({
    super.key,
    required this.period,
    required this.date,
  });

  @override
  State<SatisfactionChartWidget> createState() => _SatisfactionChartWidgetState();
}

class _SatisfactionChartWidgetState extends State<SatisfactionChartWidget> {
  Map<String, dynamic>? _satisfactionData;

  @override
  void initState() {
    super.initState();
    _loadSatisfactionData();
  }

  @override
  void didUpdateWidget(SatisfactionChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period != widget.period || oldWidget.date != widget.date) {
      _loadSatisfactionData();
    }
  }

  Future<void> _loadSatisfactionData() async {
    try {
      final startDate = _getStartDate();
      final endDate = widget.date.add(const Duration(days: 1));

 final response = await SupabaseService.from('analytics_satisfaction')
 .select('nps_score, csat_score, rating, sentiment')
 .gte('created_at', startDate.toIso8601String())
 .lt('created_at', endDate.toIso8601String());

      final data = response as List;

      if (data.isEmpty) {
        setState(() {
          _satisfactionData = {
 'nps': 0.0,
 'csat': 0.0,
 'average_rating': 0.0,
 'positive_sentiment': 0.0,
 'total_feedback': 0,
          };
        });
        return;
      }

      double npsSum = 0;
      double csatSum = 0;
      double ratingSum = 0;
      int positiveCount = 0;
      int npsCount = 0;
      int csatCount = 0;
      int ratingCount = 0;

      for (final item in data) {
 if (item['nps_score'] != null) {
 npsSum += (item['nps_score'] as num).toDouble();
          npsCount++;
        }
 if (item['csat_score'] != null) {
 csatSum += (item['csat_score'] as num).toDouble();
          csatCount++;
        }
 if (item['rating'] != null) {
 ratingSum += (item['rating'] as num).toDouble();
          ratingCount++;
        }
 if (item['sentiment'] == 'positive') {
          positiveCount++;
        }
      }

      setState(() {
        _satisfactionData = {
 'nps': npsCount > 0 ? npsSum / npsCount : 0.0,
 'csat': csatCount > 0 ? csatSum / csatCount : 0.0,
 'average_rating': ratingCount > 0 ? ratingSum / ratingCount : 0.0,
 'positive_sentiment': data.length > 0 ? (positiveCount / data.length * 100) : 0.0,
 'total_feedback': data.length,
        };
      });
    } catch (e) {
      setState(() {
        _satisfactionData = {
 'nps': 0.0,
 'csat': 0.0,
 'average_rating': 0.0,
 'positive_sentiment': 0.0,
 'total_feedback': 0,
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
    if (_satisfactionData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
 '${_satisfactionData!['total_feedback']} retours collectés',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 24),
            _buildMetricRow(
 'NPS',
 _satisfactionData!['nps'],
              10,
              Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
 'CSAT',
 _satisfactionData!['csat'],
              5,
              Colors.green,
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
 'Note moyenne',
 _satisfactionData!['average_rating'],
              5,
              Colors.orange,
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
 'Sentiment positif',
 _satisfactionData!['positive_sentiment'],
              100,
              Colors.purple,
              isPercentage: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, double value, double maxValue, Color color, {bool isPercentage = false}) {
    final percentage = maxValue > 0 ? (value / maxValue * 100) : 0.0;

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
              isPercentage
 ? '${value.toStringAsFixed(1)}%'
                  : value.toStringAsFixed(1),
              style: AppTextStyles.bodyLarge.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 16,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

