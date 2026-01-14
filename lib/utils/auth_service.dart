import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/member_model.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;
  static UserCredential? userCredential;

  static DocumentSnapshot? userDetails;
  static String get userName => userDetails?.get("displayName") ?? "Guest";


  // Sign in with Google Popup
  Future<bool?> signInWithGoogleWeb() async {

    if(kIsWeb) {
      await _auth.signInAnonymously();
      return true;
    }

    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      userCredential = await _auth.signInWithPopup(googleProvider);
      User? user = userCredential?.user;
      if (user != null) userDetails = await checkSync(user);
      return true;
    } catch (e) {
      print("Error during Google Sign-In: $e");
      return false;
    }
  }

  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      print("User signed out successfully");
    } catch (e) {
      print("Error signing out: $e");
    }
  }
}
