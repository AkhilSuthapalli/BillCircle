import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String id;
  final int amount;
  final String currency;
  final String paidBy;
  final Map<String, int> splits;
  final String note;
  final Timestamp createdAt;

  ExpenseModel({
    required this.id,
    required this.amount,
    required this.currency,
    required this.paidBy,
    required this.splits,
    required this.note,
    required this.createdAt,
  });

  factory ExpenseModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ExpenseModel(
      id: doc.id,
      amount: data['amount'],
      currency: data['currency'],
      paidBy: data['paidBy'],
      splits: Map<String, int>.from(data['splits']),
      note: data['note'],
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'currency': currency,
      'paidBy': paidBy,
      'splits': splits,
      'note': note,
      'createdAt': createdAt,
    };
  }
}
