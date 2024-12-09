import 'package:flutter/material.dart';
import 'audio_option_screen.dart'; // Import AudioOptionScreen
import 'auth_service.dart';
import 'auth_screen.dart';
import 'profile_screen.dart'; // Import the ProfileScreen

class SymptomChecklist extends StatefulWidget {
  const SymptomChecklist({Key? key}) : super(key: key);

  @override
  _SymptomChecklistState createState() => _SymptomChecklistState();
}

class _SymptomChecklistState extends State<SymptomChecklist> {
  Map<String, bool> symptoms = {
    'Mucus': false,
    'Sound in chest': false,
    'Pain in chest': false,
    'Cough during night': false,
    'Frequent cough': false,
    'Difficulty breathing': false,
  };

  // Logout functionality
  Future<void> _logout() async {
    await AuthService().signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
          (route) => false,
    );
  }

  // Profile click handler
  void _goToProfile() {
    // Navigate to the profile screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Symptom Checklist'),
        backgroundColor: Colors.teal[300],
        actions: [
          // Profile icon in the top right corner
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: _goToProfile,
            tooltip: 'Profile',
          ),
          // Popup menu for logout
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'Logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'Logout',
                  child: Text('Logout'),
                ),
              ];
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select the symptoms you are experiencing:',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 3.0,
              child: Column(
                children: symptoms.keys.map((symptom) {
                  return CheckboxListTile(
                    activeColor: Colors.teal,
                    title: Text(
                      symptom,
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    value: symptoms[symptom],
                    onChanged: (bool? value) {
                      setState(() {
                        symptoms[symptom] = value!;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        List<String> selectedSymptoms = symptoms.entries
                            .where((entry) => entry.value)
                            .map((entry) => entry.key)
                            .toList();
                        return AlertDialog(
                          title: const Text('Selected Symptoms'),
                          content: Text(
                            selectedSymptoms.isEmpty
                                ? 'No symptoms selected'
                                : selectedSymptoms.join(', '),
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          actions: [
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.checklist),
                  label: const Text('Show Symptoms'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[50],
                    textStyle: const TextStyle(fontSize: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    List<String> selectedSymptoms = symptoms.entries
                        .where((entry) => entry.value)
                        .map((entry) => entry.key)
                        .toList();

                    if (selectedSymptoms.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AudioOptionScreen(symptoms: selectedSymptoms),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select symptoms first!')),
                      );
                    }
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Proceed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[50],
                    textStyle: const TextStyle(fontSize: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
