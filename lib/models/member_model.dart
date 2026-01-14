import 'dart:math';

import 'package:billcircle/utils/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum MemberRole {temp, editor, owner, viewer}

class MemberModel {
  final String id;
  final String displayName;
  final MemberRole role; // owner | editor | viewer | temp

  MemberModel({
    required this.id,
    required this.displayName,
    required this.role,
  });

  factory MemberModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MemberModel(
      id: doc.id,
      displayName: data['displayName'],
      role: MemberRole.values.byName(data['role']),
    );
  }

  factory MemberModel.createNew({required String id,required String displayName, required MemberRole role}) {
    return MemberModel(
      id: id,
      displayName: displayName,
      role: role,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'role': role.name,
    };
  }

}

Future<DocumentSnapshot> checkSync(User user) async {

  FirebaseFirestore db = FirebaseFirestore.instance;
  final userDoc = await db.collection(AppConstants.membersCollection).doc(user.uid).get();
  if (!userDoc.exists) {
    // First time login: Create the profile with default preferences
    await db.collection(AppConstants.membersCollection).doc(user.uid).set({
      'displayName': user.displayName,
      'email': user.email,
      'photoUrl': user.photoURL,
      'lastLogin': FieldValue.serverTimestamp(),
      'devicesSubscription' : [],
    });
  } else {
    // Returning user: Just update the last login time
    await FirebaseFirestore.instance.collection(AppConstants.membersCollection).doc(user.uid).update({
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }

  return await db.collection(AppConstants.membersCollection).doc(user.uid).get();

}
