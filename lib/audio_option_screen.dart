import 'package:flutter/material.dart';
import 'record_audio_screen.dart';
import 'upload_audio_screen.dart';
import 'auth_screen.dart'; // Import the authentication screen
import 'auth_service.dart'; // Import your AuthService

class AudioOptionScreen extends StatelessWidget {
  const AudioOptionScreen({Key? key}) : super(key: key); // Add key parameter

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Audio Option')), // Use const
      body: Center( // Use Center widget to center the entire column
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Add padding around the content
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // Center the buttons horizontally
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RecordAudioScreen()), // Use const
                  );
                },
                child: const Text('Record Audio'), // Use const
              ),
              const SizedBox(height: 20), // Add spacing between buttons
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UploadAudioScreen()), // Use const
                  );
                },
                child: const Text('Upload Audio'), // Use const
              ),
              const SizedBox(height: 20), // Add spacing between buttons
              ElevatedButton(
                onPressed: () async {
                  // Implement logout functionality
                  try {
                    await AuthService().signOut(); // Call your authentication service to log out
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logged out successfully!')),
                    );

                    // Navigate back to the Auth screen
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const AuthScreen()), // Navigate to Auth screen
                          (Route<dynamic> route) => false, // Remove all previous routes
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logout failed!')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Change the color to indicate logout
                ),
                child: const Text('Logout'), // Use const
              ),
            ],
          ),
        ),
      ),
    );
  }
}
