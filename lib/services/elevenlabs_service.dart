import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../config/app_config.dart';

class ElevenLabsService {
  final String apiKey; // Your ElevenLabs API key
  final String voiceId; // Voice ID to use for storytelling
  final player = AudioPlayer();
  bool _isPlaying = false;

  ElevenLabsService({
    required this.apiKey,
    this.voiceId = AppConfig.defaultVoiceId,
  });

  bool get isPlaying => _isPlaying;

  Future<void> speak(String text) async {
    try {
      _isPlaying = true;
      
      // Get audio data from ElevenLabs
      final audioData = await _getAudioFromText(text);
      
      // Play the audio
      await _playAudio(audioData);
      
      _isPlaying = false;
    } catch (e) {
      _isPlaying = false;
      rethrow;
    }
  }

  Future<void> stop() async {
    if (_isPlaying) {
      await player.stop();
      _isPlaying = false;
    }
  }

  Future<Uint8List> _getAudioFromText(String text) async {
    final url = Uri.parse('${AppConfig.elevenLabsApiUrl}/$voiceId');
    
    final response = await http.post(
      url,
      headers: {
        'Accept': 'audio/mpeg',
        'xi-api-key': apiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'text': text,
        'model_id': AppConfig.voiceModel,
        'voice_settings': {
          'stability': AppConfig.voiceStability,
          'similarity_boost': AppConfig.voiceSimilarityBoost,
        }
      }),
    );
    
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      AppConfig.logError(
        'ElevenLabs API error: ${response.statusCode}',
        'Response body: ${response.body}'
      );
      throw Exception('Failed to get audio from ElevenLabs: ${response.statusCode}');
    }
  }

  Future<void> _playAudio(Uint8List audioData) async {
    try {
      // Save audio data to a temporary file
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/elevenlabs_audio.mp3';
      final file = File(tempPath);
      await file.writeAsBytes(audioData);
      
      // Play the audio file
      await player.setFilePath(tempPath);
      await player.play();
    } catch (e) {
      AppConfig.logError('Error playing audio', e);
      rethrow;
    }
  }

  String getDefaultGreeting() {
    return AppConfig.defaultGreeting;
  }
}
