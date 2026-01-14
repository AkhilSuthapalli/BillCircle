import 'package:cloud_firestore/cloud_firestore.dart';

class CircleModel {
  final String id; // document ID for referencing
  final String name; // Name of the circle
  final String description; // description of the circle
  final String currencyCode;
  final String visibility; // public | private
  final String accessToken; // For link creation
  bool isLocked; // To lock from the users to further modify. only works if the circle is created with account

  // To set permissions that the circle can be edited when link is used coupled with authentication
  // true: anyone with link can edit, false: no one can edit
  final bool linkCanEdit;

  final String? ownerUid; // valid if the circle created with Google UID
  final Timestamp createdAt; // First instance of creation
  final Timestamp updatedAt; // When it got updated

  CircleModel({
    required this.id,
    required this.name,
    required this.description,
    required this.visibility,
    required this.currencyCode,
    required this.accessToken,
    required this.isLocked,
    required this.linkCanEdit,
    required this.createdAt,
    required this.updatedAt,
    this.ownerUid,
  });

  factory CircleModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CircleModel(
      id: doc.id,
      name: data['name'],
      description: data['name'],
      visibility: data['visibility'],
      currencyCode: data['currencyCode'],
      accessToken: data['accessToken'],
      isLocked: data['isLocked'],
      linkCanEdit: data['linkCanEdit'],
      ownerUid: data['ownerUid'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'visibility': visibility,
      'accessToken': accessToken,
      'isLocked': isLocked,
      'currencyCode' : currencyCode,
      'linkCanEdit': linkCanEdit,
      'ownerUid': ownerUid,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
