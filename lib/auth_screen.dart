import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'audio_option_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key); // Add key parameter

  Future<void> _handleSignIn(BuildContext context) async {
    final account = await AuthService().signIn();

    if (account != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AudioOptionScreen()), // Use const
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Sign-In')), // Use const
      body: Center(
        child: ElevatedButton(
          onPressed: () => _handleSignIn(context),
          child: const Text('Sign in with Google'), // Use const
        ),
      ),
    );
  }
}
