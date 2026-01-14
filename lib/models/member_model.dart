import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class MemberModel {
  final String id;
  final String displayName;
  final String role; // owner | editor | viewer | temp
  final Timestamp joinedAt;

  MemberModel({
    required this.id,
    required this.displayName,
    required this.role,
    required this.joinedAt,
  });

  factory MemberModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MemberModel(
      id: doc.id,
      displayName: data['displayName'],
      role: data['role'],
      joinedAt: data['joinedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'role': role,
      'joinedAt': joinedAt,
    };
  }
}
