import 'package:flutter/material.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isRecording = false;
  bool _imageLoadError = false;

  @override
  void initState() {
    super.initState();
    _logDeviceInfo();
  }

  void _logDeviceInfo() {
    // Log device information to help troubleshoot simulator issues
    print('Platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}');
    print('Dart VM: ${Platform.version}');
    print('Locale: ${Platform.localeName}');
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });
    // Here you would implement the actual recording functionality
    if (_isRecording) {
      print('Recording started');
      // Start recording logic
    } else {
      print('Recording stopped');
      // Stop recording logic
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
                  print('Error loading image: $error');
                  print('Stack trace: $stackTrace');
                  
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
          
          // Optional semi-transparent overlay to make button more visible
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          
          // Content
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Title text (optional)
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
                const Spacer(flex: 5),
                
                // Microphone button at the bottom
                Padding(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  child: GestureDetector(
                    onTap: _toggleRecording,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _isRecording ? 100 : 80,
                      height: _isRecording ? 100 : 80,
                      decoration: BoxDecoration(
                        color: _isRecording ? Colors.red : Colors.blue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
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
