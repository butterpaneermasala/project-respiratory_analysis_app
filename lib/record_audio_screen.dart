import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'audio_service.dart';

class RecordAudioScreen extends StatefulWidget {
  final List<String> symptoms;
  const RecordAudioScreen({Key? key, required this.symptoms}) : super(key: key);

  @override
  _RecordAudioScreenState createState() => _RecordAudioScreenState();
}

class _RecordAudioScreenState extends State<RecordAudioScreen> {
  final AudioService _audioService = AudioService();
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _filePath;
  String _serverResponse = '';
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final micStatus = await Permission.microphone.request();
    final storageStatus = await Permission.storage.request();

    if (micStatus != PermissionStatus.granted ||
        storageStatus != PermissionStatus.granted) {
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text('Microphone and storage permissions are needed to record and upload audio.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleRecording() async {
    try {
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
          _serverResponse = ''; // Clear previous response
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error during recording: ${e.toString()}');
    }
  }

  Future<void> _togglePlayback() async {
    if (_filePath == null) return;

    try {
      if (_isPlaying) {
        // Stop the playback
        await _audioService.stopPlayback();
        setState(() {
          _isPlaying = false;  // Update state to stop playback
        });
      } else {
        // Start the playback
        await _audioService.startPlayback();
        setState(() {
          _isPlaying = true;  // Update state to start playback
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error during playback: ${e.toString()}');
    }
  }


  Future<void> _uploadAudio() async {
    if (_filePath == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      String? response = await _audioService.uploadAudioFile(_filePath!);
      if (response != null) {
        // Get the current user's ID from FirebaseAuth
        final userId = FirebaseAuth.instance.currentUser?.uid;

        if (userId != null) {
          await AudioService().storeDiagnosisRecord(response, widget.symptoms, userId); // Pass the user ID
        } else {
          _serverResponse =  'User not logged in';
        }
      }
      setState(() {
        _serverResponse = response ?? 'Audio uploaded successfully';
        _isUploading = false;
      });
    } catch (e) {
      setState(() {
        _serverResponse = 'Error uploading audio: ${e.toString()}';
        _isUploading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
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
        title: const Text('Record Audio'),
        backgroundColor: Colors.teal[300],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.mic,
                size: 100.0,
                color: _isRecording ? Colors.red : Colors.teal,
              ),
              const SizedBox(height: 20),
              Text(
                _isRecording
                    ? 'Recording in progress...'
                    : (_filePath != null
                    ? 'Recording saved'
                    : 'Ready to Record'),
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: _isRecording ? Colors.red : Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              _buildRecordButton(),
              const SizedBox(height: 15),
              _buildPlaybackButton(),
              const SizedBox(height: 15),
              _buildUploadButton(),
              const SizedBox(height: 20),
              if (_serverResponse.isNotEmpty)
                _buildResponseCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordButton() {
    return ElevatedButton.icon(
      onPressed: _toggleRecording,
      icon: Icon(_isRecording ? Icons.stop : Icons.mic),
      label: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
      style: ElevatedButton.styleFrom(
        backgroundColor: _isRecording ? Colors.red : Colors.teal,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        textStyle: const TextStyle(fontSize: 16.0),
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }

  Widget _buildPlaybackButton() {
    return ElevatedButton.icon(
      onPressed: _filePath != null ? _togglePlayback : null,
      icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
      label: Text(_isPlaying ? 'Stop Playback' : 'Start Playback'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        textStyle: const TextStyle(fontSize: 16.0),
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }

  Widget _buildUploadButton() {
    return ElevatedButton.icon(
      onPressed: _filePath != null && !_isUploading ? _uploadAudio : null,
      icon: _isUploading
          ? const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      )
          : const Icon(Icons.cloud_upload),
      label: Text(_isUploading ? 'Uploading...' : 'Upload Audio'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        textStyle: const TextStyle(fontSize: 16.0),
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }

  Widget _buildResponseCard() {
    return Card(
      elevation: 4.0,
      color: _serverResponse.contains('Error')
          ? Colors.red.shade50
          : Colors.teal.shade50,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Response: $_serverResponse',
          style: TextStyle(
            fontSize: 16,
            color: _serverResponse.contains('Error')
                ? Colors.red
                : Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}