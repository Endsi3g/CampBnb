/// Widget pour afficher le résumé d'avis généré par IA
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/gemini_models.dart';
import '../../../core/providers/gemini_providers.dart';

class ReviewSummaryWidget extends ConsumerWidget {
  final List<String> reviews;

  const ReviewSummaryWidget({super.key, required this.reviews});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(reviewSummaryProvider(reviews));

    return summaryAsync.when(
      data: (summary) => _ReviewSummaryContent(summary: summary),
      loading: () => const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
 'Erreur lors de l\'analyse des avis: $error',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}

class _ReviewSummaryContent extends StatelessWidget {
  final ReviewSummary summary;

  const _ReviewSummaryContent({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, size: 20),
                const SizedBox(width: 8),
                Text(
 'Résumé IA des avis',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Note moyenne
            Row(
              children: [
                Text(
                  summary.averageRating.toStringAsFixed(1),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                ...List.generate(5, (index) {
                  return Icon(
                    index < summary.averageRating.round()
                        ? Icons.star
                        : Icons.star_border,
                    size: 20,
                    color: Colors.amber,
                  );
                }),
                const Spacer(),
                Text(
 '${summary.totalReviews} avis',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Distribution des notes
            _buildRatingDistribution(theme),
            const SizedBox(height: 16),

            // Aspects positifs
            if (summary.positiveAspects.isNotEmpty) ...[
              Text(
 'Points forts',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...summary.positiveAspects.map((aspect) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle,
                            size: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(child: Text(aspect)),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
            ],

            // Aspects négatifs
            if (summary.negativeAspects.isNotEmpty) ...[
              Text(
 'Points à améliorer',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...summary.negativeAspects.map((aspect) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 16, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(child: Text(aspect)),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRatingDistribution(ThemeData theme) {
    final maxCount = summary.ratingDistribution.values
        .reduce((a, b) => a > b ? a : b);

    return Column(
      children: [5, 4, 3, 2, 1].map((rating) {
        final count = summary.ratingDistribution[rating.toString()] ?? 0;
        final percentage = maxCount > 0 ? count / maxCount : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
 Text('$rating', style: theme.textTheme.bodySmall),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
 Text('$count', style: theme.textTheme.bodySmall),
            ],
          ),
        );
      }).toList(),
    );
  }
}


