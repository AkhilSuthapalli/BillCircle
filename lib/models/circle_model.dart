import 'package:cloud_firestore/cloud_firestore.dart';

class CircleModel {
  final String id;
  final String name;
  final String mode; // anonymous | auth
  final String visibility; // link | private
  final String accessToken;
  final bool isLocked;
  final Map<String, dynamic> permissions;
  final String? ownerUid;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  CircleModel({
    required this.id,
    required this.name,
    required this.mode,
    required this.visibility,
    required this.accessToken,
    required this.isLocked,
    required this.permissions,
    required this.createdAt,
    required this.updatedAt,
    this.ownerUid,
  });

  factory CircleModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CircleModel(
      id: doc.id,
      name: data['name'],
      mode: data['mode'],
      visibility: data['visibility'],
      accessToken: data['accessToken'],
      isLocked: data['isLocked'],
      permissions: Map<String, dynamic>.from(data['permissions']),
      ownerUid: data['ownerUid'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'mode': mode,
      'visibility': visibility,
      'accessToken': accessToken,
      'isLocked': isLocked,
      'permissions': permissions,
      'ownerUid': ownerUid,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
