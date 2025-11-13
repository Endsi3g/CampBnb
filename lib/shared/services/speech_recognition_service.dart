import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class SpeechRecognitionService {
  SpeechRecognitionService._();

  static final stt.SpeechToText _speech = stt.SpeechToText();
  static bool _isListening = false;
  static bool _isAvailable = false;

  /// Initialiser le service de reconnaissance vocale
  static Future<bool> initialize() async {
    // Demander la permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      return false;
    }

    _isAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
        }
      },
      onError: (error) {
        _isListening = false;
      },
    );

    return _isAvailable;
  }

  /// Démarrer l'écoute
  static Future<String?> startListening({
    Function(String)? onResult,
    Function(String)? onError,
  }) async {
    if (!_isAvailable) {
      final initialized = await initialize();
      if (!initialized) {
        onError?.call('Reconnaissance vocale non disponible');
        return null;
      }
    }

    if (_isListening) {
      return null;
    }

    String? finalResult;

    _isListening = true;
    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          finalResult = result.recognizedWords;
          _isListening = false;
          onResult?.call(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      localeId: 'fr_CA', // Français québécois
    );

    return finalResult;
  }

  /// Arrêter l'écoute
  static Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }

  /// Annuler l'écoute
  static Future<void> cancelListening() async {
    if (_isListening) {
      await _speech.cancel();
      _isListening = false;
    }
  }

  /// Vérifier si l'écoute est en cours
  static bool get isListening => _isListening;

  /// Vérifier si le service est disponible
  static bool get isAvailable => _isAvailable;
}
