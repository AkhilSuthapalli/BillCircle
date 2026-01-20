import 'package:billcircle/utils/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/circle_model.dart';
import '../models/expense_model.dart';
import '../models/member_model.dart';
import 'dart:math';

String generateSecureToken({int length = 24}) {
  const chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  final rand = Random.secure();
  return List.generate(
    length,
        (_) => chars[rand.nextInt(chars.length)],
  ).join();
}

String generateTempMemberId() {
  final rand = Random.secure();
  return 'm_${List.generate(8, (_) => rand.nextInt(36).toRadixString(36)).join()}';
}

class FirebaseHelper {
  FirebaseHelper._();
  static final FirebaseHelper instance = FirebaseHelper._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------------------
  // Circles
  // ---------------------------

  Future<CircleModel?> getCircleByToken(String token) async {
    final query = await _db
        .collection('circles')
        .where('accessToken', isEqualTo: token)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return CircleModel.fromDoc(query.docs.first);
  }

  Stream<CircleModel> watchCircle(String circleId) {
    return _db
        .collection(AppConstants.circlesCollection)
        .doc(circleId)
        .snapshots()
        .map((doc) => CircleModel.fromDoc(doc));
  }

  Future<DocumentReference> createCircle({
    required String name,
    required String description,
    required String visibility,
    required String currencyCode,
    required String accessToken,
    required bool linkCanEdit,
    String? ownerUid,
  }) {
    CircleModel circle = CircleModel(
        id: 'id',
        name: name,
        description: description,
        visibility: visibility,
        currencyCode: currencyCode,
        accessToken: accessToken,
        isLocked: false,
        linkCanEdit: linkCanEdit,
        createdAt: Timestamp.fromDate(DateTime.now()),
        updatedAt: Timestamp.fromDate(DateTime.now()));
    return _db.collection(AppConstants.circlesCollection).add(circle.toMap());
  }

  Future<void> lockCircle(String circleId, bool state) {
    return _db.collection(AppConstants.circlesCollection).doc(circleId).update({
      'isLocked': state,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> deleteCircle(String circleId) {
    return _db.collection(AppConstants.circlesCollection).doc(circleId).delete();
  }

  // ---------------------------
  // Expenses
  // ---------------------------

  Future<void> addExpense({
    required String circleId,
    required ExpenseModel expense,
  }) {
    return _db
        .collection(AppConstants.circlesCollection)
        .doc(circleId)
        .collection(AppConstants.expensesCollection)
        .add(expense.toMap());
  }

  Stream<List<ExpenseModel>> watchExpenses(String circleId) {
    return _db
        .collection(AppConstants.circlesCollection)
        .doc(circleId)
        .collection(AppConstants.expensesCollection)
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snapshot) =>
          snapshot.docs.map(ExpenseModel.fromDoc).toList(),
    );
  }

  // ---------------------------
  // Members
  // ---------------------------

  Future<void> addMember({
    required String circleId,
    required MemberModel member,
  }) {
    return _db
        .collection(AppConstants.circlesCollection)
        .doc(circleId)
        .collection(AppConstants.membersCollection)
        .doc(member.id)
        .set(member.toMap());
  }

  Stream<List<MemberModel>> watchMembers(String circleId) {
    return _db
        .collection(AppConstants.circlesCollection)
        .doc(circleId)
        .collection(AppConstants.membersCollection)
        .snapshots()
        .map(
          (snapshot) =>
          snapshot.docs.map(MemberModel.fromDoc).toList(),
    );
  }
}
