// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:institute_unified_complaint_system/pages/complaint_model.dart';
// import 'package:intl/intl.dart';

// class ViewComplaintsPage extends StatefulWidget {
//   const ViewComplaintsPage({Key? key}) : super(key: key);

//   @override
//   ViewComplaintsPageState createState() => ViewComplaintsPageState();
// }

// class ViewComplaintsPageState extends State<ViewComplaintsPage> {
//   late DatabaseReference _complaintsRef;
//   late List<Complaint> _complaints;

//   @override
//   void initState() {
//     super.initState();
//     _complaintsRef = FirebaseDatabase.instance.ref().child('complaints');
//     _complaints = [];
//     _fetchComplaints();
//   }

//   Future<void> _fetchComplaints() async {
//     User? user = FirebaseAuth.instance.currentUser;

//     if (user != null) {
//       try {
//         List<Complaint> fetchedComplaints = [];

//         // Fetch complaints under "Mess"
//         await _fetchComplaintsUnderNode('Mess', user.uid, fetchedComplaints);

//         // Fetch complaints under "Hostel"
//         await _fetchComplaintsUnderNode('Hostel', user.uid, fetchedComplaints);

//         setState(() {
//           _complaints = fetchedComplaints;
//         });
//       } catch (e) {
//         debugPrint("Error fetching complaints: $e");
//         // Handle the error, e.g., show an error message to the user
//       }
//     }
//   }

//   Future<void> _fetchComplaintsUnderNode(String nodeName, String userId, List<Complaint> fetchedComplaints) async {
//   DatabaseEvent event = await _complaintsRef.child(nodeName).orderByChild('user_id').equalTo(userId).once();
//   DataSnapshot snapshot = event.snapshot;

//   // Print the raw Firebase data
//   //debugPrint("Raw Firebase Data for Node $nodeName: ${snapshot.value}");

//   if (snapshot.value != null) {
//     try {
//       Map<dynamic, dynamic>? complaintsData = snapshot.value as Map<dynamic, dynamic>?;

//       if (complaintsData != null) {
//         complaintsData.forEach((complaintId, complaintDetails) {
//           if (complaintDetails is Map<dynamic, dynamic>) {
//             // Add the complaint ID to details
//             complaintDetails['id'] = complaintId;

//             debugPrint("Received complaintDetails for complaintId $complaintId: $complaintDetails");

//             // Validate the fields within the map
//             if (complaintDetails.containsKey('user_id') &&
//                 complaintDetails.containsKey('category') &&
//                 complaintDetails.containsKey('complaint_text') &&
//                 complaintDetails.containsKey('assignedTo') &&
//                 complaintDetails.containsKey('timestamp') &&
//                 complaintDetails.containsKey('status')) {
//               // Use conditional cast to handle type safety
//               Complaint? complaint = Complaint.fromMap(complaintDetails);
//               fetchedComplaints.add(complaint);
//             } else {
//               debugPrint("Incomplete data for complaintId $complaintId: $complaintDetails");
//             }
//           } else {
//             debugPrint("Invalid data type for complaintDetails: $complaintDetails");
//           }
//         });
//       }
//     } catch (e) {
//       debugPrint("Error processing Firebase data: $e");
//     }
//   }
// }

//   @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: AppBar(
//       title: const Text('My Complaints'),
//     ),
//     body: _complaints.isEmpty
//         ? const Center(child: Text('No complaints registered'))
//         : ListView.builder(
//             itemCount: _complaints.length,
//             itemBuilder: (context, index) {
//               final complaint = _complaints[index];
//               return Card(
//                 margin: const EdgeInsets.all(8.0),
//                 child: ListTile(
//                   title: Text(complaint.category),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(complaint.complaintText),
//                       const SizedBox(height: 8.0),
//                       Text(
//                         'Date: ${DateFormat.yMMMMd().format(complaint.timestamp)}',
//                         style: const TextStyle(fontSize: 12.0),
//                       ),
//                     ],
//                   ),
//                   trailing: Text(complaint.status),
//                 ),
//               );
//             },
//           ),
//   );
// }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:institute_unified_complaint_system/pages/complaint_model.dart';
import 'package:intl/intl.dart';

class ViewComplaintsPage extends StatefulWidget {
  const ViewComplaintsPage({Key? key}) : super(key: key);

  @override
  ViewComplaintsPageState createState() => ViewComplaintsPageState();
}

class ViewComplaintsPageState extends State<ViewComplaintsPage> {
  late DatabaseReference _complaintsRef;
  late List<Complaint> _complaints;

  @override
  void initState() {
    super.initState();
    _complaintsRef = FirebaseDatabase.instance.ref().child('complaints');
    _complaints = [];
    _fetchComplaints();
  }

  Future<void> _fetchComplaints() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        List<Complaint> fetchedComplaints = [];

        // Fetch complaints under "Mess"
        await _fetchComplaintsUnderNode('Mess', user.uid, fetchedComplaints);

        // Fetch complaints under "Hostel"
        await _fetchComplaintsUnderNode('Hostel', user.uid, fetchedComplaints);

        fetchedComplaints.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort by timestamp

        setState(() {
          _complaints = fetchedComplaints;
        });
      } catch (e) {
        debugPrint("Error fetching complaints: $e");
        // Handle the error, e.g., show an error message to the user
      }
    }
  }

  Future<void> _fetchComplaintsUnderNode(
      String nodeName, String userId, List<Complaint> fetchedComplaints) async {
    DatabaseEvent event = await _complaintsRef
        .child(nodeName)
        .orderByChild('user_id')
        .equalTo(userId)
        .once();
    DataSnapshot snapshot = event.snapshot;

    // Print the raw Firebase data
    //debugPrint("Raw Firebase Data for Node $nodeName: ${snapshot.value}");

    if (snapshot.value != null) {
      try {
        Map<dynamic, dynamic>? complaintsData =
            snapshot.value as Map<dynamic, dynamic>?;

        if (complaintsData != null) {
          complaintsData.forEach((complaintId, complaintDetails) {
            if (complaintDetails is Map<dynamic, dynamic>) {
              // Add the complaint ID to details
              complaintDetails['id'] = complaintId;

              debugPrint(
                  "Received complaintDetails for complaintId $complaintId: $complaintDetails");

              // Validate the fields within the map
              if (complaintDetails.containsKey('user_id') &&
                  complaintDetails.containsKey('category') &&
                  complaintDetails.containsKey('complaint_text') &&
                  complaintDetails.containsKey('assignedTo') &&
                  complaintDetails.containsKey('timestamp') &&
                  complaintDetails.containsKey('status')) {
                // Use conditional cast to handle type safety
                Complaint? complaint = Complaint.fromMap(complaintDetails);
                fetchedComplaints.add(complaint);
              } else {
                debugPrint(
                    "Incomplete data for complaintId $complaintId: $complaintDetails");
              }
            } else {
              debugPrint(
                  "Invalid data type for complaintDetails: $complaintDetails");
            }
          });
        }
      } catch (e) {
        debugPrint("Error processing Firebase data: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Complaints'),
      ),
      body: _complaints.isEmpty
          ? const Center(child: Text('No complaints registered'))
          : ListView.builder(
              reverse: false, // Reverse the order of items
              itemCount: _complaints.length,
              itemBuilder: (context, index) {
                final complaint = _complaints[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(complaint.category),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(complaint.complaintText),
                        const SizedBox(height: 8.0),
                        Text(
                          'Date: ${DateFormat.yMMMMd().format(complaint.timestamp)}',
                          style: const TextStyle(fontSize: 12.0),
                        ),
                      ],
                    ),
                    trailing: Text(complaint.status),
                    leading: Icon(_getStatusIcon(complaint.status)),
                  ),
                );
              },
            ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'resolved':
        return Icons.check_circle_outline;
      case 'pending':
        return Icons.info_outline;
      default:
        return Icons.help_outline;
    }
  }
}
