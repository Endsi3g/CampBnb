import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/services/supabase_service.dart';
import '../providers/analytics_provider.dart';
import '../widgets/analytics_tracker.dart';
import '../widgets/metrics_card.dart';
import '../widgets/conversion_funnel_widget.dart';
import '../widgets/satisfaction_chart_widget.dart';
import '../widgets/user_behavior_widget.dart';

/// Dashboard Analytics pour visualiser les données d'utilisation
class AnalyticsDashboardScreen extends ConsumerStatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  ConsumerState<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState
    extends ConsumerState<AnalyticsDashboardScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedPeriod = 'daily'; // 'daily', 'weekly', 'monthly'

  @override
  Widget build(BuildContext context) {
    return AnalyticsTracker(
      screenName: 'analytics_dashboard',
      screenClass: 'AnalyticsDashboardScreen',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard Analytics'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // Naviguer vers les paramètres privacy
                context.push('/settings/privacy');
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sélecteur de période
                _buildPeriodSelector(),
                const SizedBox(height: 24),
                // Métriques principales
                _buildMainMetrics(),
                const SizedBox(height: 24),
                // Funnel de conversion
                _buildConversionFunnel(),
                const SizedBox(height: 24),
                // Satisfaction utilisateur
                _buildSatisfactionSection(),
                const SizedBox(height: 24),
                // Comportements utilisateur
                _buildUserBehaviorSection(),
                const SizedBox(height: 24),
                // Événements récents
                _buildRecentEvents(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [
        Expanded(
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'daily', label: Text('Jour')),
              ButtonSegment(value: 'weekly', label: Text('Semaine')),
              ButtonSegment(value: 'monthly', label: Text('Mois')),
            ],
            selected: {_selectedPeriod},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _selectedPeriod = newSelection.first;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() {
                _selectedDate = date;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildMainMetrics() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchMainMetrics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Erreur: ${snapshot.error}');
        }

        final metrics = snapshot.data ?? {};

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Métriques principales', style: AppTextStyles.h2),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                MetricsCard(
                  title: 'Utilisateurs actifs',
                  value: '${metrics['active_users'] ?? 0}',
                  icon: Icons.people,
                  color: AppColors.primary,
                  trend: metrics['active_users_trend'] as double?,
                ),
                MetricsCard(
                  title: 'Sessions',
                  value: '${metrics['sessions'] ?? 0}',
                  icon: Icons.timeline,
                  color: AppColors.secondary,
                  trend: metrics['sessions_trend'] as double?,
                ),
                MetricsCard(
                  title: 'Taux de rétention',
                  value:
                      '${(metrics['retention_rate'] ?? 0.0).toStringAsFixed(1)}%',
                  icon: Icons.trending_up,
                  color: Colors.green,
                  trend: metrics['retention_trend'] as double?,
                ),
                MetricsCard(
                  title: 'Taux de conversion',
                  value:
                      '${(metrics['conversion_rate'] ?? 0.0).toStringAsFixed(1)}%',
                  icon: Icons.check_circle,
                  color: Colors.orange,
                  trend: metrics['conversion_trend'] as double?,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildConversionFunnel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Funnel de conversion', style: AppTextStyles.h2),
        const SizedBox(height: 16),
        ConversionFunnelWidget(period: _selectedPeriod, date: _selectedDate),
      ],
    );
  }

  Widget _buildSatisfactionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Satisfaction utilisateur', style: AppTextStyles.h2),
        const SizedBox(height: 16),
        SatisfactionChartWidget(period: _selectedPeriod, date: _selectedDate),
      ],
    );
  }

  Widget _buildUserBehaviorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Analyse comportementale', style: AppTextStyles.h2),
        const SizedBox(height: 16),
        UserBehaviorWidget(period: _selectedPeriod, date: _selectedDate),
      ],
    );
  }

  Widget _buildRecentEvents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Événements récents', style: AppTextStyles.h2),
        const SizedBox(height: 16),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchRecentEvents(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return const Text('Aucun événement récent');
            }

            final events = snapshot.data!;

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length > 10 ? 10 : events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      _getEventIcon(event['event_type'] as String?),
                      color: AppColors.primary,
                    ),
                    title: Text(event['event_name'] as String? ?? ''),
                    subtitle: Text(
                      DateFormat(
                        'dd/MM/yyyy HH:mm',
                      ).format(DateTime.parse(event['created_at'] as String)),
                    ),
                    trailing: Chip(
                      label: Text(
                        event['event_category'] as String? ?? '',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  IconData _getEventIcon(String? eventType) {
    switch (eventType) {
      case 'screen_view':
        return Icons.visibility;
      case 'button_click':
        return Icons.touch_app;
      case 'search':
        return Icons.search;
      case 'listing_view':
        return Icons.home;
      case 'reservation':
        return Icons.calendar_today;
      default:
        return Icons.event;
    }
  }

  Future<Map<String, dynamic>> _fetchMainMetrics() async {
    try {
      // Récupérer les métriques depuis Supabase
      final startDate = _getStartDate();
      final endDate = _selectedDate.add(const Duration(days: 1));

      // Utilisateurs actifs
      final activeUsersResponse =
          await SupabaseService.from('analytics_sessions')
              .select('user_id, anonymous_id')
              .gte('started_at', startDate.toIso8601String())
              .lt('started_at', endDate.toIso8601String());

      final activeUsers = (activeUsersResponse as List)
          .map((e) => e['user_id'] ?? e['anonymous_id'])
          .toSet()
          .length;

      // Sessions
      final sessionsResponse = await SupabaseService.from('analytics_sessions')
          .select('id')
          .gte('started_at', startDate.toIso8601String())
          .lt('started_at', endDate.toIso8601String());

      final sessions = (sessionsResponse as List).length;

      // Conversions
      final conversionsResponse =
          await SupabaseService.from('analytics_conversions')
              .select('id')
              .gte('created_at', startDate.toIso8601String())
              .lt('created_at', endDate.toIso8601String());

      final conversions = (conversionsResponse as List).length;

      // Rétention (simplifié)
      final retentionRate = sessions > 0 ? (activeUsers / sessions * 100) : 0.0;
      final conversionRate = sessions > 0
          ? (conversions / sessions * 100)
          : 0.0;

      return {
        'active_users': activeUsers,
        'sessions': sessions,
        'retention_rate': retentionRate,
        'conversion_rate': conversionRate,
      };
    } catch (e) {
      return {
        'active_users': 0,
        'sessions': 0,
        'retention_rate': 0.0,
        'conversion_rate': 0.0,
      };
    }
  }

  Future<List<Map<String, dynamic>>> _fetchRecentEvents() async {
    try {
      final response = await SupabaseService.from(
        'analytics_events',
      ).select().order('created_at', ascending: false).limit(10);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  DateTime _getStartDate() {
    switch (_selectedPeriod) {
      case 'daily':
        return DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
        );
      case 'weekly':
        return _selectedDate.subtract(
          Duration(days: _selectedDate.weekday - 1),
        );
      case 'monthly':
        return DateTime(_selectedDate.year, _selectedDate.month, 1);
      default:
        return _selectedDate;
    }
  }
}
