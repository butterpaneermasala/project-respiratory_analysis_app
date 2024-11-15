import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'audio_service.dart';

class UploadAudioScreen extends StatelessWidget {
  const UploadAudioScreen({Key? key}) : super(key: key); // Add key parameter

  void _uploadAudio(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      String filePath = result.files.single.path!;
      String? response = await AudioService().uploadAudioFile(filePath);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Upload Result'), // Use const
          content: Text(response ?? 'Upload Failed'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'), // Use const
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Audio')), // Use const
      body: Center(
        child: ElevatedButton(
          onPressed: () => _uploadAudio(context),
          child: const Text('Choose Audio File'), // Use const
        ),
      ),
    );
  }
}
