/// Widget pour la traduction instantanée FR/EN
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/gemini_providers.dart';

class TranslationWidget extends ConsumerStatefulWidget {
  final String text;
  final String sourceLanguage;
  final String targetLanguage;
  final Widget Function(String translatedText)? builder;

  const TranslationWidget({
    super.key,
    required this.text,
 this.sourceLanguage = 'fr',
 this.targetLanguage = 'en',
    this.builder,
  });

  @override
  ConsumerState<TranslationWidget> createState() => _TranslationWidgetState();
}

class _TranslationWidgetState extends ConsumerState<TranslationWidget> {
  bool _showTranslation = false;

  @override
  Widget build(BuildContext context) {
    final translationAsync = ref.watch(
      translationProvider(
        TranslationParams(
          text: widget.text,
          targetLanguage: widget.targetLanguage,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Texte original
        if (widget.builder != null)
          widget.builder!(widget.text)
        else
          Text(widget.text),

        // Bouton de traduction
        TextButton.icon(
          onPressed: () {
            setState(() {
              _showTranslation = !_showTranslation;
            });
          },
          icon: const Icon(Icons.translate, size: 18),
 label: Text(_showTranslation ? 'Masquer la traduction' : 'Traduire'),
        ),

        // Texte traduit
        if (_showTranslation)
          translationAsync.when(
            data: (translated) => Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      translated,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (error, stack) => Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
 'Erreur de traduction: $error',
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
    );
  }
}


