import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class StoryGeneratorService {
  final String? apiKey; // ElevenLabs API key for story generation
  final String elevenlabsApiUrl = 'https://api.elevenlabs.io/v1/text-generation';

  StoryGeneratorService({this.apiKey});

  Future<String> generateStory(String prompt) async {
    // If you have an ElevenLabs API key, use it for story generation
    if (apiKey != null && apiKey!.isNotEmpty) {
      return await _generateWithElevenLabs(prompt);
    } else {
      // Fallback to simple template if no API key
      return _generateSimpleStory(prompt);
    }
  }

  Future<String> _generateWithElevenLabs(String prompt) async {
    try {
      final url = Uri.parse(elevenlabsApiUrl);
      
      final response = await http.post(
        url,
        headers: {
          'xi-api-key': apiKey!,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'prompt': 'Create a short, engaging story about: $prompt. The story should be about 150-200 words.',
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['text'].trim();
      } else {
        if (kDebugMode) {
          print('ElevenLabs API error: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
        // Fallback to simple story if API fails
        return _generateSimpleStory(prompt);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error generating story with ElevenLabs: $e');
      }
      return _generateSimpleStory(prompt);
    }
  }

  String _generateSimpleStory(String prompt) {
    // Simple story template when no API is available
    return '''
Once upon a time, in a world where $prompt, there lived a curious adventurer. 
The adventurer's name was whispered in legends across the land.

One day, when the morning sun painted the sky with hues of orange and pink, 
our hero decided to embark on a journey unlike any other. 
Through dense forests and over rolling hills, across rushing rivers and beneath starlit skies, 
the adventure unfolded in ways no one could have imagined.

Along the way, friendships were forged, challenges were overcome, and wisdom was gained. 
The greatest discovery, however, wasn't found in ancient treasures or magical artifacts, 
but in the realization that courage resided within all along.

And so, with a heart full of experiences and a mind rich with stories, 
our adventurer returned home, forever changed by the journey that began with $prompt.
''';
  }
}
