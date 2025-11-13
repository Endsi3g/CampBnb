import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/services/supabase_service.dart';
import '../../../../shared/models/analytics_event_model.dart';

/// Widget pour afficher l'analyse comportementale utilisateur
class UserBehaviorWidget extends StatefulWidget {
  final String period;
  final DateTime date;

  const UserBehaviorWidget({
    super.key,
    required this.period,
    required this.date,
  });

  @override
  State<UserBehaviorWidget> createState() => _UserBehaviorWidgetState();
}

class _UserBehaviorWidgetState extends State<UserBehaviorWidget> {
  Map<String, dynamic>? _behaviorData;

  @override
  void initState() {
    super.initState();
    _loadBehaviorData();
  }

  @override
  void didUpdateWidget(UserBehaviorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period != widget.period || oldWidget.date != widget.date) {
      _loadBehaviorData();
    }
  }

  Future<void> _loadBehaviorData() async {
    try {
      final startDate = _getStartDate();
      final endDate = widget.date.add(const Duration(days: 1));

      // Récupérer les comportements analysés
 final response = await SupabaseService.from('analytics_user_behaviors')
          .select()
 .eq('analysis_date', startDate.toIso8601String().split('T')[0])
 .eq('analysis_period', widget.period)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _behaviorData = response as Map<String, dynamic>;
        });
      } else {
        setState(() {
          _behaviorData = {
 'engagement_score': 0.0,
 'personalization_score': 0.0,
 'retention_probability': 0.0,
 'ai_insights': 'Analyse en cours...',
          };
        });
      }
    } catch (e) {
      setState(() {
        _behaviorData = {
 'engagement_score': 0.0,
 'personalization_score': 0.0,
 'retention_probability': 0.0,
 'ai_insights': 'Erreur lors du chargement',
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
    if (_behaviorData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
 'Scores comportementaux',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 16),
            _buildScoreCard(
 'Engagement',
 _behaviorData!['engagement_score'] ?? 0.0,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildScoreCard(
 'Personnalisation',
 _behaviorData!['personalization_score'] ?? 0.0,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildScoreCard(
 'Probabilité de rétention',
 _behaviorData!['retention_probability'] ?? 0.0,
              Colors.orange,
            ),
 if (_behaviorData!['ai_insights'] != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text(
 'Insights IA',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
 _behaviorData!['ai_insights'] ?? 'Aucun insight disponible',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(String label, double score, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.bodyLarge,
            ),
            Text(
 '${(score * 100).toStringAsFixed(1)}%',
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
            value: score,
            minHeight: 12,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

