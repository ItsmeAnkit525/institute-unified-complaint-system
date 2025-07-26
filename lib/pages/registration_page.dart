// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:institute_unified_complaint_system/pages/auth.dart';
import 'package:institute_unified_complaint_system/utils/routes.dart';
import 'package:firebase_database/firebase_database.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  RegistrationPageState createState() => RegistrationPageState();
}

class RegistrationPageState extends State<RegistrationPage> {
  String name = "";
  String email = "";
  String password = "";
  bool changeButton = false;
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String errorMessage = "";

  void registerUser(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        changeButton = true;
      });

      try {
        // Perform user registration
        await _auth.registerWithEmailAndPassword(email, password);

        // Get the current user after registration
        final User? user = FirebaseAuth.instance.currentUser;

        // Add user data to the database using ref()
        if (user != null) {
          FirebaseDatabase.instance
              .ref()
              .child('users')
              .child(user.uid)
              .set({
            'name': name,
            'email': email,
            'role': 'user', // Default role for a registered user
            'managedComplaints': 'null', // Default to null or modify as needed
          });
        }

        // Delay for a short duration (for the sake of UI, can be adjusted)
        await Future.delayed(const Duration(seconds: 1));

        // Navigate to the login route after successful registration
        Navigator.pushReplacementNamed(context, MyRoutes.loginRoute);
      } on FirebaseAuthException catch (e) {
        // Handle specific registration errors
        debugPrint("Registration failed: $e");

        // Set the error message to be displayed on the screen
        setState(() {
          errorMessage = "Registration failed. Please try again.";
        });
      } catch (e) {
        // Handle other errors (not related to registration)
        debugPrint("Error: $e");
        setState(() {
          changeButton = false;
        });
      }
    }
  }

  void navigateToLogin(BuildContext context) {
    // Navigate to the login page
    Navigator.pushReplacementNamed(context, MyRoutes.loginRoute);
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
                "assets/images/registration_image.png", // Replace with the actual image path
                height: 300,
                fit: BoxFit.cover,
              ),
              const SizedBox(
                height: 20.0,
              ),
              const Text(
                "Create an Account",
                style: TextStyle(
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
                        hintText: "Enter Full Name",
                        labelText: "Full Name",
                      ),
                      onChanged: (value) {
                        name = value;
                        setState(() {});
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Name cannot be empty!";
                        }
                        return null;
                      },
                    ),
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
                        // Add more email validation if needed
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
                      borderRadius: BorderRadius.circular(changeButton ? 50 : 8),
                      child: InkWell(
                        onTap: () => registerUser(context),
                        child: AnimatedContainer(
                          duration: const Duration(seconds: 1),
                          width: changeButton ? 50 : 150,
                          height: 50,
                          alignment: Alignment.center,
                          child: changeButton
                              ? const Icon(Icons.done, color: Colors.white)
                              : const Text(
                                  "Register",
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
                    InkWell(
                      onTap: () => navigateToLogin(context),
                      child: const Text(
                        "Already have an account? Login here",
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
