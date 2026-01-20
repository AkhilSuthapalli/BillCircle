import 'package:billcircle/utils/ui_helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../models/member_model.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;
  static UserCredential? userCredential;

  static DocumentSnapshot? userDetails;
  static String get userName => userDetails?.get("displayName") ?? "Guest";


  // Sign in with Google Popup
  Future<bool?> signInWithGoogleWeb() async {

    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      userCredential = await _auth.signInWithPopup(googleProvider);
      User? user = userCredential?.user;
      if (user != null) userDetails = await checkSync(user);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
    } catch (e) {
      showAnimatedAlert(context, title: "Logout Issue", message: "There seems to be an issue with logout, try again", primaryText: "Ok");
    }
  }
}
