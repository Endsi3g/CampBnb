import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/speech_recognition_service.dart';

class VoiceSearchButton extends StatefulWidget {
  final Function(String)? onResult;
  final Function(String)? onError;

  const VoiceSearchButton({super.key, this.onResult, this.onError});

  @override
  State<VoiceSearchButton> createState() => _VoiceSearchButtonState();
}

class _VoiceSearchButtonState extends State<VoiceSearchButton> {
  bool _isListening = false;

  Future<void> _startListening() async {
    setState(() => _isListening = true);

    try {
      final result = await SpeechRecognitionService.startListening(
        onResult: (text) {
          setState(() => _isListening = false);
          widget.onResult?.call(text);
        },
        onError: (error) {
          setState(() => _isListening = false);
          widget.onError?.call(error);
        },
      );
    } catch (e) {
      setState(() => _isListening = false);
      widget.onError?.call('Erreur: $e');
    }
  }

  Future<void> _stopListening() async {
    await SpeechRecognitionService.stopListening();
    setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: _isListening ? _stopListening : _startListening,
      backgroundColor: _isListening ? AppColors.error : AppColors.primary,
      child: Icon(
        _isListening ? Icons.mic : Icons.mic_none,
        color: Colors.white,
      ),
    );
  }
}
