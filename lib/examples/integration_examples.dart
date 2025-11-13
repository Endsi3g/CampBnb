/// Exemples d'intégration des fonctionnalités IA dans les écrans
/// Ce fichier montre comment utiliser les widgets IA dans différents contextes

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/ai_chat/widgets/gemini_chat_widget.dart';
import '../features/ai_features/widgets/destination_suggestions_widget.dart';
import '../features/ai_features/widgets/review_summary_widget.dart';
import '../features/ai_features/widgets/translation_widget.dart';
import '../features/ai_features/widgets/local_experiences_widget.dart';
import '../features/ai_features/widgets/faq_ai_widget.dart';

/// Exemple: Écran de recherche avec suggestions IA
class SearchScreenExample extends ConsumerWidget {
  const SearchScreenExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recherche')),
      body: ListView(
        children: [
          // Barre de recherche normale
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un camping...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          // Suggestions IA basées sur la recherche
          DestinationSuggestionsWidget(
            region: 'Mauricie',
            month: 'octobre',
            groupType: 'familles',
            preferences: 'près d\'un lac',
            onSuggestionTap: (suggestion) {
              // Naviguer vers les détails du camping
              Navigator.pushNamed(context, '/campsite/${suggestion.name}');
            },
          ),

          // Bouton pour ouvrir le chatbot
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => GeminiChatWidget(
                    title: 'Aide à la recherche',
                    userContext:
                        'Utilisateur recherchant un camping en Mauricie',
                  ),
                );
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Demander à l\'assistant IA'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Exemple: Écran de détails de camping avec fonctionnalités IA
class CampsiteDetailsScreenExample extends ConsumerWidget {
  final String campsiteId;
  final String campsiteDescription;
  final List<String> reviews;
  final String location;

  const CampsiteDetailsScreenExample({
    super.key,
    required this.campsiteId,
    required this.campsiteDescription,
    required this.reviews,
    required this.location,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détails du camping')),
      body: ListView(
        children: [
          // Description avec traduction
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TranslationWidget(
                  text: campsiteDescription,
                  targetLanguage: 'en',
                ),
              ],
            ),
          ),

          // Résumé d'avis IA
          ReviewSummaryWidget(reviews: reviews),

          // Expériences locales suggérées
          LocalExperiencesWidget(
            location: location,
            preferences: 'nature et activités en plein air',
          ),

          // Bouton flottant pour le chatbot
        ],
      ),
      floatingActionButton: GeminiChatFloatingButton(
        userContext: 'Consultation du camping $campsiteId',
      ),
    );
  }
}

/// Exemple: Écran d'aide et support avec FAQ IA
class HelpSupportScreenExample extends ConsumerWidget {
  const HelpSupportScreenExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aide et support')),
      body: ListView(
        children: [
          // FAQ avec réponses IA
          FAQAIWidget(
            question: 'Comment annuler une réservation ?',
            context: 'Utilisateur avec réservation active',
          ),
          FAQAIWidget(question: 'Quels sont les modes de paiement acceptés ?'),
          FAQAIWidget(
            question: 'Puis-je modifier les dates de ma réservation ?',
          ),

          // Chatbot intégré
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/ai-chat');
              },
              icon: const Icon(Icons.chat),
              label: const Text('Chatter avec l\'assistant IA'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Exemple: Écran de réservation avec assistance IA
class ReservationScreenExample extends ConsumerWidget {
  const ReservationScreenExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Réserver votre séjour')),
      body: const Center(child: Text('Formulaire de réservation...')),
      // Chatbot flottant pour assistance
      floatingActionButton: GeminiChatFloatingButton(
        userContext: 'Processus de réservation en cours',
      ),
    );
  }
}

/// Exemple: Écran avec génération d'itinéraire
class ItineraryScreenExample extends ConsumerWidget {
  const ItineraryScreenExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Utiliser le provider pour générer un itinéraire
    // final itineraryAsync = ref.watch(
    //   itineraryProvider(
    //     ItineraryParams(
    // destination: 'Parc national de la Mauricie',
    //       days: 3,
    // preferences: 'activités familiales',
    //     ),
    //   ),
    // );

    return Scaffold(
      appBar: AppBar(title: const Text('Mon itinéraire')),
      body: const Center(child: Text('Itinéraire généré par IA...')),
    );
  }
}
