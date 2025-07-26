// ignore_for_file: prefer_const_constructors, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:institute_unified_complaint_system/pages/auth.dart';
import 'package:institute_unified_complaint_system/utils/drawer.dart';
import 'package:institute_unified_complaint_system/utils/routes.dart';

class HomePage extends StatelessWidget {
  final AuthService _authService = AuthService();

  HomePage({super.key});
  @override
  Widget build(BuildContext context) {
  return Scaffold(
    drawer: MyDrawer(),
    appBar: AppBar(
      title: Text('Home Page'),
      actions: [
        // Logout Icon Button
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: () => _logout(context),
        ),
      ],
    ),
    body: SingleChildScrollView(
      // Add a SingleChildScrollView to make content scrollable if needed
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/institute_image.png',
            // Replace with the actual image path
            height: 200,
            // Adjust the height as needed
            width: 200,
            // Make the image take up the full width
            fit: BoxFit.cover,
            // Adjust the fit as needed
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to the Home Page!',
                  style: TextStyle(fontSize: 24,),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to the Complaints List Page
                      Navigator.pushNamed(context, MyRoutes.viewComplaintsRoute);
                    },
                    child: Text('View Complaints', textAlign: TextAlign.center),
                  ),
                ),
                SizedBox(height: 20.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to the New Complaint Form Page
                      Navigator.pushNamed(context, MyRoutes.newComplaintRoute);
                    },
                    child: Text('File a New Complaint', textAlign: TextAlign.center),
                  ),
                ),
                // Add more announcements as needed
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
  // Function to handle logout
  Future<void> _logout(BuildContext context) async {
    await _authService.signOut();
    Navigator.pushReplacementNamed(context, MyRoutes.loginRoute);
  }
}

