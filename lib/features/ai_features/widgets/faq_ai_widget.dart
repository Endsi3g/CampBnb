/// Widget pour les réponses FAQ avec IA
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/gemini_providers.dart';

class FAQAIWidget extends ConsumerStatefulWidget {
  final String question;
  final String? context;

  const FAQAIWidget({super.key, required this.question, this.context});

  @override
  ConsumerState<FAQAIWidget> createState() => _FAQAIWidgetState();
}

class _FAQAIWidgetState extends ConsumerState<FAQAIWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final answerAsync = ref.watch(
      faqResponseProvider(
        FAQParams(question: widget.question, context: widget.context),
      ),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: const Icon(Icons.auto_awesome, size: 20),
        title: Text(
          widget.question,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        onExpandedChanged: (expanded) {
          setState(() {
            _expanded = expanded;
          });
        },
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: answerAsync.when(
              data: (answer) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      answer,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Erreur: $error',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
