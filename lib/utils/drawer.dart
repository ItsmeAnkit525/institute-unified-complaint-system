import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:institute_unified_complaint_system/utils/routes.dart';
import 'package:url_launcher/url_launcher.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> _getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users').child(user.uid);

      return userRef.once().then((event) {
        DataSnapshot snapshot = event.snapshot;
        Map<String, dynamic>? userData;
        if (snapshot.value != null && snapshot.value is Map<dynamic, dynamic>) {
          userData = Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);
        }
        return userData ?? {};
      });
    }

    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.deepPurple,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else {
              Map<String, dynamic> userData = snapshot.data ?? {};

              return ListView(
                children: [
                  DrawerHeader(
                    padding: EdgeInsets.zero,
                    child: UserAccountsDrawerHeader(
                      margin: EdgeInsets.zero,
                      accountName: Text(userData['name'] ?? ''),
                      accountEmail: Text(userData['email'] ?? ''),
                      currentAccountPicture: const CircleAvatar(
                        backgroundImage: AssetImage("assets/images/profile.png"),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.home,
                      color: Colors.white,
                    ),
                    title: const Text(
                      "Home",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pushReplacementNamed(context, MyRoutes.homeRoute);
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.mail,
                      color: Colors.white,
                    ),
                    title: const Text(
                      "Email me",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () async {
                      // ignore: deprecated_member_use
                      await launch("mailto:${userData['email']}");
                    },
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

