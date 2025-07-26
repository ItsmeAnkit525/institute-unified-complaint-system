
// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:institute_unified_complaint_system/utils/routes.dart';
import 'package:intl/intl.dart'; // Import intl package for date formatting
import 'package:institute_unified_complaint_system/pages/complaint_model.dart';
import 'package:institute_unified_complaint_system/utils/drawer.dart';

class AdminComplaintsPage extends StatefulWidget {
  const AdminComplaintsPage({Key? key}) : super(key: key);

  @override
  AdminComplaintsPageState createState() => AdminComplaintsPageState();
}

class AdminComplaintsPageState extends State<AdminComplaintsPage> {
  late DatabaseReference _complaintsRef;
  late List<Complaint> _complaints;
  late User? _user;
  late String _managedComplaints;

  @override
  void initState() {
    super.initState();
    _complaintsRef = FirebaseDatabase.instance.ref().child('complaints');
    _complaints = [];
    _user = FirebaseAuth.instance.currentUser;
    _managedComplaints = '';
    _fetchManagedComplaints();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchComplaints(); // Fetch complaints when the widget is first built
  }

  Future<void> _fetchManagedComplaints() async {
    try {
      if (_user != null && _user!.uid.isNotEmpty) {
        DatabaseEvent event = await FirebaseDatabase.instance
            .ref()
            .child('users')
            .child(_user!.uid)
            .child('managedComplaints')
            .once();
        DataSnapshot snapshot = event.snapshot;
        if (snapshot.value != null) {
          _managedComplaints = snapshot.value.toString();
        }
      }
    } catch (e) {
      debugPrint("Error fetching managedComplaints: $e");
    }
  }

  Future<void> _fetchComplaints() async {
    if (_user != null && _user!.uid.isNotEmpty) {
      try {
        // Use onValue event to listen for real-time updates
        _complaintsRef.onValue.listen((event) async {
          await _fetchManagedComplaints();
          await _fetchComplaintsData(event.snapshot);
        });
      } catch (e) {
        debugPrint("Error fetching complaints: $e");
      }
    }
  }

  Future<void> _fetchComplaintsData(DataSnapshot snapshot) async {
    if (snapshot.value != null) {
      Map<dynamic, dynamic>? complaintsData = snapshot.value as Map<dynamic, dynamic>?;

      List<Complaint> fetchedComplaints = [];

      for (var category in complaintsData?.keys ?? []) {
        Map<dynamic, dynamic>? categoryComplaints = complaintsData?[category];

        if (categoryComplaints != null) {
          for (var complaintId in categoryComplaints.keys) {
            Map<dynamic, dynamic>? complaintDetails = categoryComplaints[complaintId];

            if (complaintDetails != null) {
              complaintDetails['id'] = complaintId;

              if (_isComplaintMap(complaintDetails)) {
                Complaint? complaint = await _buildComplaintWithUserName(complaintDetails);
                if (complaint != null && complaint.status == 'pending') {
                  if (_managedComplaints == 'mess' && category == 'Mess') {
                    fetchedComplaints.add(complaint);
                  } else if (_managedComplaints == 'hostel' && category == 'Hostel') {
                    fetchedComplaints.add(complaint);
                  }
                } else {
                  debugPrint("Invalid data for complaintId $complaintId: $complaintDetails");
                }
              } else {
                debugPrint("Incomplete data for complaintId $complaintId: $complaintDetails");
              }
            } else {
              debugPrint("Invalid data type for complaintDetails: $complaintDetails");
            }
          }
        } else {
          debugPrint("Invalid data type for categoryComplaints: $categoryComplaints");
        }
      }

      setState(() {
        _complaints = fetchedComplaints;
      });
    }
  }

  bool _isComplaintMap(Map<dynamic, dynamic> map) {
    return map.containsKey('id') &&
        map.containsKey('user_id') &&
        map.containsKey('category') &&
        map.containsKey('complaint_text') &&
        map.containsKey('assignedTo') &&
        map.containsKey('timestamp') &&
        map.containsKey('status');
  }

  Future<Complaint?> _buildComplaintWithUserName(Map<dynamic, dynamic> complaintDetails) async {
    String user_id = complaintDetails['user_id'];
    String userName = await _fetchUserName(user_id);

    if (userName.isNotEmpty) {
      return Complaint.fromMap({...complaintDetails, 'userName': userName});
    } else {
      return null;
    }
  }

  Future<String> _fetchUserName(String user_id) async {
    try {
      DatabaseEvent event = await FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user_id)
          .child('name')
          .once();
      DataSnapshot userSnapshot = event.snapshot;
      return userSnapshot.value.toString();
    } catch (e) {
      debugPrint("Error fetching user name: $e");
      return '';
    }
  }

  Future<void> _markComplaintResolved(String category, String complaintId) async {
    try {
      await _complaintsRef.child(category).child(complaintId).child('status').set('resolved');
      _fetchComplaints();
    } catch (e) {
      debugPrint("Error marking complaint as resolved: $e");
    }
  }

  Future<void> _signOutAndNavigateToLogin() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, MyRoutes.loginRoute); // Replace '/login' with your login page route
    } catch (e) {
      debugPrint("Error signing out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaints'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _signOutAndNavigateToLogin();
            },
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: _complaints.isEmpty
          ? const Center(child: Text('No pending complaints'))
          : ListView.builder(
              itemCount: _complaints.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(_complaints[index].userName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(_complaints[index].timestamp)}',
                          style: const TextStyle(fontSize: 12.0),
                        ),
                        const SizedBox(height: 8),
                        Text(_complaints[index].complaintText),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        _markComplaintResolved(_complaints[index].category, _complaints[index].id);
                      },
                      child: const Text('Mark Resolved'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
