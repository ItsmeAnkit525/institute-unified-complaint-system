import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ComplaintsPage extends StatefulWidget {
  const ComplaintsPage({Key? key}) : super(key: key);

  @override
  ComplaintsPageState createState() => ComplaintsPageState();
}

class ComplaintsPageState extends State<ComplaintsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _complaintsRef = FirebaseDatabase.instance.ref().child('complaints');

  String _selectedCategory = "Mess"; // Default category
  late TextEditingController _complaintTextController;

  @override
  void initState() {
    super.initState();
    _complaintTextController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File a Complaint'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
              items: <String>['Mess', 'Hostel'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Complaint:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _complaintTextController,
              decoration: const InputDecoration(
                hintText: 'Enter your complaint',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _submitComplaint();
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitComplaint() async {
    User? user = _auth.currentUser;

    if (user != null) {
      String userId = user.uid;

      Map<String, dynamic> complaintData = {
        'category': _selectedCategory,
        'user_id': userId,
        'complaint_text': _complaintTextController.text,
        'assignedTo': '', // You can set the default assignedTo value
        'timestamp': ServerValue.timestamp,
        'status': 'pending', // Default status
      };

      _complaintsRef.child(_selectedCategory).push().set(complaintData);

      // Optionally, you can navigate to another page or show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complaint submitted successfully!'),
        ),
      );

      // Clear text field after submission
      _complaintTextController.clear();
    }
  }
}
