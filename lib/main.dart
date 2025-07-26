
// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:institute_unified_complaint_system/pages/admin_page.dart';
import 'package:institute_unified_complaint_system/pages/home_page.dart';
import 'package:institute_unified_complaint_system/pages/login_page.dart';
import 'package:institute_unified_complaint_system/pages/new_complaint.dart';
import 'package:institute_unified_complaint_system/pages/registration_page.dart';
import 'package:institute_unified_complaint_system/pages/view_complaints_page.dart';
import 'package:institute_unified_complaint_system/utils/routes.dart';
import 'package:institute_unified_complaint_system/utils/widgets/themes.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyCC6_2G-bPayjDkp4NHAvG5firHwNSSYoA',
      authDomain: 'unified-complaint-system-app.firebaseapp.com',
      projectId: 'unified-complaint-system-app',
      messagingSenderId: '899352968207',
      appId: '1:899352968207:android:2d0a0533d6243f794a777a',
      databaseURL: 'https://unified-complaint-system-app-default-rtdb.asia-southeast1.firebasedatabase.app'
    ),
  );

  runApp(
    const MyApp()
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.light,
      theme: MyTheme.lightTheme(context),
      darkTheme: MyTheme.darkTheme(context),
      home: const SplashScreen(),
      routes: {
        MyRoutes.adminRoute: (context) => const AdminComplaintsPage(),
        MyRoutes.loginRoute: (context) => const LoginPage(),
        MyRoutes.registerRoute: (context) => const RegistrationPage(),
        MyRoutes.homeRoute: (context) => HomePage(),
        MyRoutes.newComplaintRoute: (context) => const ComplaintsPage(),
        MyRoutes.viewComplaintsRoute: (context) => const ViewComplaintsPage(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}


class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay for 3 seconds and then check if the user is signed in
    Timer(const Duration(seconds: 2), () {
      navigateToNextScreen();
    });
  }

  void navigateToNextScreen() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Fetch the user role from the database
      String userRole = await fetchUserRole(user.uid);

      // Navigate based on the user role
      if (userRole == 'admin') {
        Navigator.of(context).pushReplacementNamed(MyRoutes.adminRoute);
      } else if (userRole == 'user') {
        Navigator.of(context).pushReplacementNamed(MyRoutes.homeRoute);
      } else {
        // Handle other roles or scenarios as needed
        // For now, navigate to login page
        Navigator.of(context).pushReplacementNamed(MyRoutes.loginRoute);
      }
    } else {
      Navigator.of(context).pushReplacementNamed(MyRoutes.loginRoute);
    }
  }

  Future<String> fetchUserRole(String userId) async {
    try {
      // Fetch user role from the database based on userId
      DatabaseEvent event = await FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(userId)
          .child('role')
          .once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        return snapshot.value.toString();
      }
    } catch (e) {
      debugPrint("Error fetching user role: $e");
    }

    // Return a default role or handle the scenario as needed
    return 'user';
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Unified Complaint App",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
