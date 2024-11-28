import 'package:flutter/material.dart';
import 'record_audio_screen.dart';
import 'upload_audio_screen.dart';
import 'auth_screen.dart';
import 'auth_service.dart';

class AudioOptionScreen extends StatelessWidget {
  const AudioOptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[300],
        elevation: 0,
        title: const Text('Audio Options', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildOptionCard(
                  context,
                  icon: Icons.mic,
                  label: 'Record Audio',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RecordAudioScreen()),
                  ),
                ),
                const SizedBox(height: 20),
                _buildOptionCard(
                  context,
                  icon: Icons.cloud_upload,
                  label: 'Upload Audio',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UploadAudioScreen()),
                  ),
                ),
                const SizedBox(height: 20),
                _buildOptionCard(
                  context,
                  icon: Icons.logout,
                  label: 'Logout',
                  onPressed: () => _handleLogout(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onPressed,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal, size: 28),
        title: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
        onTap: onPressed,
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await AuthService().signOut();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout failed!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
