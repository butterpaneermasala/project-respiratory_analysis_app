import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'audio_service.dart'; // Import the AudioService

class RecordAudioScreen extends StatefulWidget {
  @override
  _RecordAudioScreenState createState() => _RecordAudioScreenState();
}

class _RecordAudioScreenState extends State<RecordAudioScreen> {
  AudioService _audioService = AudioService();
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _filePath;
  String _serverResponse = '';

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    // Request permissions first
    await _requestPermissions();

    // Ensure that the recorder is initialized properly
    await _audioService.startRecording();
  }

  Future<void> _requestPermissions() async {
    // Request microphone and storage permissions
    await Permission.microphone.request();
    await Permission.storage.request();
  }


  // Start or stop recording based on the state
  Future<void> _toggleRecording() async {
    if (_isRecording) {
      String? filePath = await _audioService.stopRecording();
      setState(() {
        _isRecording = false;
        _filePath = filePath;
      });
    } else {
      await _audioService.startRecording();
      setState(() {
        _isRecording = true;
      });
    }
  }

  // Start or stop audio playback (optional, this part uses FlutterSoundPlayer)
  Future<void> _togglePlayback() async {
    if (_filePath != null) {
      if (_isPlaying) {
        await _audioService.stopRecording(); // Or use player.stop
        setState(() {
          _isPlaying = false;
        });
      } else {
        await _audioService.startRecording(); // Or use player.play
        setState(() {
          _isPlaying = true;
        });
      }
    }
  }

  // Upload the recorded audio to the Flask server
  Future<void> _uploadAudio() async {
    if (_filePath != null) {
      String? response = await _audioService.uploadAudioFile(_filePath!);
      setState(() {
        _serverResponse = response ?? 'Error uploading audio';
      });
    }
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Record Audio'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _toggleRecording,
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
            ElevatedButton(
              onPressed: _togglePlayback,
              child: Text(_isPlaying ? 'Stop Playback' : 'Start Playback'),
            ),
            ElevatedButton(
              onPressed: _uploadAudio,
              child: Text('Upload Audio'),
            ),
            SizedBox(height: 20),
            Text(
              _serverResponse.isNotEmpty ? 'Response: $_serverResponse' : '',
              style: TextStyle(fontSize: 16, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
