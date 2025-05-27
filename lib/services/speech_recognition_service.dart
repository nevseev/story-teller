import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../config/app_config.dart';

class SpeechRecognitionService {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isInitialized = false;

  Future<bool> initialize() async {
    if (!_isInitialized) {
      _isInitialized = await _speechToText.initialize(
        onError: (error) => AppConfig.logError('Speech recognition error', error),
        onStatus: (status) {
          AppConfig.logInfo('Speech recognition status: $status');
        },
      );
    }
    return _isInitialized;
  }

  Future<void> startListening({
    required Function(String) onResult,
    required Function() onListeningComplete,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        AppConfig.logError('Failed to initialize speech recognition');
        return;
      }
    }

    if (_speechToText.isAvailable && !_speechToText.isListening) {
      await _speechToText.listen(
        onResult: (result) {
          final recognizedWords = result.recognizedWords;
          if (recognizedWords.isNotEmpty) {
            onResult(recognizedWords);
          }
        },
        listenFor: AppConfig.speechListenDuration,
        pauseFor: AppConfig.speechPauseDuration,
        listenOptions: stt.SpeechListenOptions(partialResults: true),
        onSoundLevelChange: (level) {
          // You can use this to show a visual mic level indicator
        },
      );
    } else {
      AppConfig.logError('Speech recognition not available');
    }
  }

  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
  }

  bool get isListening => _speechToText.isListening;
}
