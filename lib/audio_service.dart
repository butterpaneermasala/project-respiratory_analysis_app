import 'dart:io';
import 'dart:convert';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class AudioService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  String? _recordingPath;

  // Start recording audio and save it to a file
  Future<void> startRecording() async {
    try {
      // Initialize recorder if not already initialized
      if (!_recorder.isRecording) {
        await _recorder.openRecorder();  // Open the recorder explicitly
      }

      Directory tempDir = await getTemporaryDirectory();
      _recordingPath = '${tempDir.path}/recorded_audio.wav';

      if (_recordingPath != null) {
        await _recorder.startRecorder(
          toFile: _recordingPath,
          codec: Codec.pcm16WAV,
        );
      }
    } catch (e) {
      print("Error starting recording: $e");
    }
  }

  // Stop recording and return the file path of the recorded audio
  Future<String?> stopRecording() async {
    try {
      if (_recorder.isRecording) {
        await _recorder.stopRecorder();
      }
      return _recordingPath;
    } catch (e) {
      print("Error stopping recording: $e");
      return null;
    }
  }

  // Upload the recorded audio file to the server
  Future<String?> uploadAudioFile(String filePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.46.146:5000/predict'), // Your Flask API URL
      );
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final decodedResponse = jsonDecode(responseBody);
        return decodedResponse['predicted_class']; // Return predicted class
      } else {
        return 'Error uploading audio: ${response.statusCode}';
      }
    } catch (e) {
      print("Error uploading audio: $e");
      return 'Error uploading audio';
    }
  }

  // Dispose resources (close the recorder)
  Future<void> dispose() async {
    try {
      if (_recorder.isRecording) {
        await _recorder.stopRecorder();  // Ensure it's stopped before closing
      }
      await _recorder.closeRecorder();
    } catch (e) {
      print("Error disposing recorder: $e");
    }
  }
}
