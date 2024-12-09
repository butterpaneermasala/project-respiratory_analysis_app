import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  List<Map<String, dynamic>> _records = [];
  bool _loading = true; // Add loading state

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    if (_user != null) {
      _loadRecords();
    }
  }

  // Load previous diagnosis records from Firestore
  Future<void> _loadRecords() async {
    try {
      final recordsRef = _firestore.collection('diagnosis_records').where('user_id', isEqualTo: _user!.uid);
      final snapshot = await recordsRef.get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _loading = false;
          _records = []; // No records found
        });
      } else {
        setState(() {
          _loading = false;
          _records = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading records: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.teal[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_user != null)
              Text(
                'Welcome, ${_user!.displayName ?? 'User'}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 20),
            const Text(
              'Previous Diagnosis Records:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (_loading) // Show loading indicator
              const Center(child: CircularProgressIndicator())
            else if (_records.isEmpty) // Show message when no records
              const Center(child: Text('No previous diagnosis records found.'))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _records.length,
                  itemBuilder: (context, index) {
                    final record = _records[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      elevation: 4.0,
                      child: ListTile(
                        title: Text('Date: ${record['date']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Result: ${record['result']}'),
                            Text('Symptoms: ${record['symptoms'].join(', ')}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
