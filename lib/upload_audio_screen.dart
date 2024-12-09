import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'audio_service.dart'; // Import AudioService

class UploadAudioScreen extends StatefulWidget {
  final List<String> symptoms;

  const UploadAudioScreen({Key? key, required this.symptoms}) : super(key: key);

  @override
  _UploadAudioScreenState createState() => _UploadAudioScreenState();
}

class _UploadAudioScreenState extends State<UploadAudioScreen> {
  bool _isUploading = false;

  // Method to upload the audio file and store the diagnosis in Firestore
  void _uploadAudio(BuildContext context) async {
    setState(() {
      _isUploading = true;
    });

    // Picking an audio file
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result == null) {
      _showDialog(context, 'No file selected');
      setState(() {
        _isUploading = false;
      });
      return;
    }

    String filePath = result.files.single.path!;
    String? response = await AudioService().uploadAudioFile(filePath);

    _showDialog(context, response ?? 'Upload Failed');

    if (response != null) {
      // Get the current user's ID from FirebaseAuth
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        await AudioService().storeDiagnosisRecord(response, widget.symptoms, userId); // Pass the user ID
      } else {
        _showDialog(context, 'User not logged in');
      }
    }

    setState(() {
      _isUploading = false;
    });
  }

  // Method to show the result in a dialog
  void _showDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Result'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[300],
        elevation: 0,
        title: const Text('Upload Audio', style: TextStyle(fontWeight: FontWeight.w600)),
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
                _isUploading
                    ? const CircularProgressIndicator()
                    : _buildUploadButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.teal[100],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _uploadAudio(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal[400], // Teal color background
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text(
          'Choose Audio File',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
