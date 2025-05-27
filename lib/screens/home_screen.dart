import 'package:flutter/material.dart';
import 'dart:io';
import '../services/elevenlabs_service.dart';
import '../services/speech_recognition_service.dart';
import '../services/story_generator_service.dart';
import '../config/app_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isRecording = false;
  bool _imageLoadError = false;
  bool _isProcessing = false;
  String _statusMessage = '';
  String _storyPrompt = '';
  String _generatedStory = '';
  
  // Create instances of our services
  late ElevenLabsService _elevenLabsService;
  late SpeechRecognitionService _speechRecognitionService;
  late StoryGeneratorService _storyGeneratorService;

  @override
  void initState() {
    super.initState();
    _logDeviceInfo();
    
    // Initialize services
    _elevenLabsService = ElevenLabsService(
      apiKey: AppConfig.elevenLabsApiKey,
    );
    _speechRecognitionService = SpeechRecognitionService();
    _storyGeneratorService = StoryGeneratorService(
      apiKey: AppConfig.elevenLabsApiKey,
    );
    
    // Initialize speech recognition
    _speechRecognitionService.initialize();
    
    // Play greeting after a short delay
    Future.delayed(const Duration(seconds: 1), _playGreeting);
  }

  @override
  void dispose() {
    _elevenLabsService.stop();
    _speechRecognitionService.stopListening();
    super.dispose();
  }

  void _logDeviceInfo() {
    // Log device information to help troubleshoot simulator issues
    AppConfig.logError('Device Info', 'Platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}');
    AppConfig.logError('Device Info', 'Dart VM: ${Platform.version}');
    AppConfig.logError('Device Info', 'Locale: ${Platform.localeName}');
  }

  Future<void> _playGreeting() async {
    setState(() {
      _statusMessage = AppConfig.processingMessage;
      _isProcessing = true;
    });
    
    try {
      final greeting = _elevenLabsService.getDefaultGreeting();
      await _elevenLabsService.speak(greeting);
      
      setState(() {
        _statusMessage = 'What kind of story would you like to hear?';
        _isProcessing = false;
      });
    } catch (e) {
      AppConfig.logError('Error playing greeting', e);
      setState(() {
        _statusMessage = AppConfig.errorMessage;
        _isProcessing = false;
      });
    }
  }

  Future<void> _toggleRecording() async {
    if (_isProcessing) return;
    
    if (!_isRecording) {
      setState(() {
        _isRecording = true;
        _statusMessage = AppConfig.listeningMessage;
      });
      
      await _speechRecognitionService.startListening(
        onResult: (text) {
          setState(() {
            _storyPrompt = text;
          });
        },
        onListeningComplete: () {
          // This is called when speech recognition stops listening
        },
      );
    } else {
      await _speechRecognitionService.stopListening();
      
      setState(() {
        _isRecording = false;
        _isProcessing = true;
        _statusMessage = AppConfig.processingMessage;
      });
      
      if (_storyPrompt.isNotEmpty) {
        await _generateAndNarrateStory();
      } else {
        setState(() {
          _isProcessing = false;
          _statusMessage = AppConfig.noInputMessage;
        });
      }
    }
  }

  Future<void> _generateAndNarrateStory() async {
    try {
      // Generate the story
      final story = await _storyGeneratorService.generateStory(_storyPrompt);
      
      setState(() {
        _generatedStory = story;
        _statusMessage = AppConfig.narratingMessage;
      });
      
      // Narrate the story
      await _elevenLabsService.speak(story);
      
      setState(() {
        _isProcessing = false;
        _statusMessage = AppConfig.completedMessage;
      });
    } catch (e) {
      AppConfig.logError('Error generating or narrating story', e);
      setState(() {
        _isProcessing = false;
        _statusMessage = AppConfig.errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with error handling
          _imageLoadError 
            ? Container(
                color: Colors.grey[800],
                child: const Center(
                  child: Text(
                    'Image could not be loaded',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            : Image.asset(
                'assets/images/storyteller.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  AppConfig.logError('Error loading image', error);
                  AppConfig.logError('Image loading stack trace', stackTrace);
                  
                  // Mark that we had an error loading the image
                  Future.microtask(() {
                    setState(() {
                      _imageLoadError = true;
                    });
                  });
                  
                  // Return a placeholder
                  return Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  );
                },
              ),
          
          // Optional semi-transparent overlay to make content more visible
          Container(
            color: const Color.fromRGBO(0, 0, 0, 0.4),
          ),
          
          // Content
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Title text
                const Spacer(),
                const Text(
                  'Story Teller',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                
                // Status message
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 8,
                          color: Colors.black,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Story prompt (if any)
                if (_storyPrompt.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(255, 255, 255, 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                        child: Text(
                        '"$_storyPrompt"',
                        style: const TextStyle(
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                
                // Generated story (if any)
                if (_generatedStory.isNotEmpty)
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(255, 255, 255, 0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            _generatedStory,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  const Spacer(flex: 3),
                
                // Microphone button at the bottom
                Padding(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  child: GestureDetector(
                    onTap: _isProcessing ? null : _toggleRecording,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _isRecording ? 100 : 80,
                      height: _isRecording ? 100 : 80,
                      decoration: BoxDecoration(
                        color: _isProcessing 
                            ? Colors.grey 
                            : (_isRecording ? Colors.red : Colors.blue),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(76), // 0.3 * 255 ≈ 76
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: _isProcessing 
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Icon(
                              Icons.mic,
                              size: _isRecording ? 50 : 40,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
