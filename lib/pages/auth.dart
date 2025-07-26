// import 'package:firebase_auth/firebase_auth.dart';


// class AuthService {

//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // sign in anon
//   late Future FirebaseUser; signInAnon() async {

//     try {
//       AuthResult result = await _auth.signInAnonymously();
//       User user = result.user;

//       return user;
//     } catch(e) {
//       debugPrint(e.toString());

//       return null;
//     }
//   }

//   // sign in with email & password

//   // register with email & password

//   // sign out 

// }


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in anonymously
  Future<User?> signInAnonymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User user = result.user!;
      return user;
    } catch (e) {
      debugPrint("Error signing in anonymously: $e");
      return null;
    }
  }

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User user = result.user!;
      return user;
    } catch (e) {
      debugPrint("Error signing in with email and password: $e");
      return null;
    }
  }

  // Register with email and password
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User user = result.user!;
      return user;
    } catch (e) {
      debugPrint("Error registering with email and password: $e");
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint("Error signing out: $e");
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
