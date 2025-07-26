
// ignore_for_file: use_build_context_synchronously

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:institute_unified_complaint_system/pages/auth.dart';
import 'package:institute_unified_complaint_system/utils/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = "";
  String password = "";
  bool changeButton = false;
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String errorMessage = "";
  bool isLoading = false; // Added loading state

  void moveToHome(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true; // Show loading animation
      });

      try {
        // Perform email/password authentication
        await _auth.signInWithEmailAndPassword(email, password);

        // Delay for a short duration (for the sake of UI, can be adjusted)
        await Future.delayed(const Duration(seconds: 1));

        // Check if authentication is successful (user is not null)
        User? currentUser = _auth.getCurrentUser();

        if (currentUser != null) {
          // Check user role
          String userRole = await getUserRole(currentUser.uid);

          // Navigate to the appropriate page based on the user's role
          if (userRole == 'admin') {
            await Navigator.pushNamed(context, MyRoutes.adminRoute);
          } else {
            await Navigator.pushNamed(context, MyRoutes.homeRoute);
          }
        } else {
          setState(() {
            errorMessage = "Authentication failed. Incorrect email or password.";
          });
        }
      } on FirebaseAuthException catch (e) {
        // Handle specific authentication errors
        debugPrint("Authentication failed: $e");
        setState(() {
          errorMessage = "Authentication failed. Incorrect email or password.";
        });
      } catch (e) {
        // Handle other errors (not related to authentication)
        debugPrint("Error: $e");
      } finally {
        setState(() {
          isLoading = false; // Hide loading animation
        });
      }
    }
  }

  Future<String> getUserRole(String userId) async {
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

  void moveToRegister(BuildContext context) {
    // Navigate to the registration page
    Navigator.pushNamed(context, MyRoutes.registerRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Image.asset(
                "assets/images/hey.png",
                height: 300,
                fit: BoxFit.cover,
              ),
              const SizedBox(
                height: 20.0,
              ),
              Text(
                "Welcome $email",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: "Enter Email",
                        labelText: "Email",
                      ),
                      onChanged: (value) {
                        email = value;
                        setState(() {});
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Email cannot be empty!";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: "Enter Password",
                        labelText: "Password",
                      ),
                      onChanged: (value) {
                        password = value;
                        setState(() {});
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Password cannot be empty!";
                        } else if (value.length < 6) {
                          return "Password length should be at least 6";
                        }
                        return null;
                      },
                    ),
                    Text(
                      errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(
                      height: 40.0,
                    ),
                    Material(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(isLoading ? 50 : 8),
                      child: InkWell(
                        onTap: () => moveToHome(context),
                        child: AnimatedContainer(
                          duration: const Duration(seconds: 1),
                          width: isLoading ? 50 : 150,
                          height: 50,
                          alignment: Alignment.center,
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : changeButton
                                  ? const Icon(Icons.done, color: Colors.white)
                                  : const Text(
                                      "Login",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    // Button to navigate to the registration page
                    InkWell(
                      onTap: () => moveToRegister(context),
                      child: const Text(
                        "New User? Register here",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
