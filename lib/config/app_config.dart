import 'package:flutter/foundation.dart';

class AppConfig {
  // API Keys
  static const String elevenLabsApiKey = String.fromEnvironment('ELEVENLABS_API_KEY', defaultValue: '');
  
  // ElevenLabs Configuration
  static const String elevenLabsApiUrl = 'https://api.elevenlabs.io/v1/text-to-speech';
  static const String elevenlabsTextGenerationUrl = 'https://api.elevenlabs.io/v1/text-generation';
  static const String defaultVoiceId = 'pNInz6obpgDQGcFmaJgB'; // Default storyteller voice
  static const double voiceStability = 0.5;
  static const double voiceSimilarityBoost = 0.75;
  static const String voiceModel = 'eleven_monolingual_v1';
  
  // Story Generator Configuration
  static const double storyTemperature = 0.7;
  static const int storyMaxTokens = 500;
  static const String storySystemPrompt = 'You are a creative storyteller. Create a short, engaging story based on the user\'s prompt. The story should be about 150-200 words.';
  
  // Speech Recognition Configuration
  static const Duration speechListenDuration = Duration(seconds: 30);
  static const Duration speechPauseDuration = Duration(seconds: 3);
  
  // UI Text
  static const String appTitle = 'Story Teller';
  static const String defaultGreeting = "Hello there! I'm your storyteller for today. Would you like to hear a story? Just tell me what kind of story you'd like to hear, and I'll create one just for you!";
  static const String listeningMessage = 'Listening...';
  static const String processingMessage = 'Generating your story...';
  static const String narratingMessage = 'Narrating your story...';
  static const String completedMessage = 'Story complete! Want to hear another one?';
  static const String noInputMessage = 'I didn\'t catch that. Please try again.';
  static const String errorMessage = 'Error creating your story. Please try again.';
  
  // Debug options
  static void logInfo(String message) {
    if (kDebugMode) {
      print(message);
    }
  }
  
  static void logError(String message, [dynamic error]) {
    if (kDebugMode) {
      print('ERROR: $message');
      if (error != null) {
        print('$error');
      }
    }
  }
}
