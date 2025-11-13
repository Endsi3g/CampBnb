/// Écran dédié au chat IA
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/gemini_chat_widget.dart';

class AIChatScreen extends ConsumerWidget {
  final String? userContext;

  const AIChatScreen({super.key, this.userContext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
 title: const Text('Assistant IA'),
        elevation: 0,
      ),
      body: GeminiChatWidget(
 title: 'Assistant Campbnb',
        userContext: userContext,
      ),
    );
  }
}


