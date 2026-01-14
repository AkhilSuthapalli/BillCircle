import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/circle_model.dart';
import '../models/expense_model.dart';
import '../models/member_model.dart';
import 'firebase_helper.dart';

void showExpenseDialog(
    BuildContext context,
    CircleModel circle,
    List<MemberModel> members, {
      ExpenseModel? expense, // null = add, non-null = edit
    }) {
  final isEdit = expense != null;

  final amountController = TextEditingController(
    text: isEdit ? expense.amount.toString() : '',
  );
  final noteController = TextEditingController(
    text: isEdit ? expense.note : '',
  );

  String payerId = isEdit ? expense.paidBy : members.first.id;

  /// infer split mode if editing
  String splitMode = 'equal';
  if (isEdit) {
    final values = expense.splits.values.toSet();
    if (values.length != 1) {
      splitMode = 'custom';
    }
  }

  String? errorText;

  final Map<String, TextEditingController> splitControllers = {
    for (final m in members)
      m.id: TextEditingController(
        text: isEdit ? expense.splits[m.id]?.toString() ?? '' : '',
      ),
  };

  void fillEqually() {
    final total = int.tryParse(amountController.text);
    if (total == null || total <= 0) return;

    if (splitMode == 'custom') {
      final share = total ~/ members.length;
      for (final c in splitControllers.values) {
        c.text = share.toString();
      }
    }

    if (splitMode == 'percent') {
      final base = 100 ~/ members.length;
      int used = 0;
      for (int i = 0; i < members.length; i++) {
        final v = (i == members.length - 1)
            ? 100 - used
            : base;
        splitControllers[members[i].id]!.text = v.toString();
        used += v;
      }
    }
  }

  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit expense' : 'Add expense'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Total amount
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Total amount',
                  ),
                  onChanged: (_) {
                    if (splitMode != 'equal') fillEqually();
                  },
                ),

                const SizedBox(height: 8),

                /// Note
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                ),

                const SizedBox(height: 8),

                /// Paid by
                DropdownButtonFormField<String>(
                  value: payerId,
                  decoration: const InputDecoration(labelText: 'Paid by'),
                  items: members
                      .map(
                        (m) => DropdownMenuItem(
                      value: m.id,
                      child: Text(m.displayName),
                    ),
                  )
                      .toList(),
                  onChanged: (v) => payerId = v!,
                ),

                const SizedBox(height: 16),

                /// Split mode
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'equal', label: Text('Equal')),
                          ButtonSegment(value: 'custom', label: Text('Custom')),
                          ButtonSegment(value: 'percent', label: Text('%')),
                        ],
                        selected: {splitMode},
                        onSelectionChanged: (s) {
                          setState(() {
                            splitMode = s.first;
                            errorText = null;
                            if (splitMode != 'equal') fillEqually();
                          });
                        },
                      ),
                    ),
                    if (splitMode != 'equal')
                      TextButton(
                        onPressed: fillEqually,
                        child: const Text('Split equally'),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                /// Custom / percentage fields
                if (splitMode != 'equal')
                  Column(
                    children: members.map((m) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TextField(
                          controller: splitControllers[m.id],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: m.displayName,
                            suffixText:
                            splitMode == 'percent' ? '%' : null,
                          ),
                          onChanged: (_) => setState(() {
                            errorText = null;
                          }),
                        ),
                      );
                    }).toList(),
                  ),

                if (errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      errorText!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final total = int.tryParse(amountController.text);
                if (total == null || total <= 0) {
                  setState(() => errorText = 'Enter a valid amount');
                  return;
                }

                final Map<String, int> splits = {};

                if (splitMode == 'equal') {
                  final share = total ~/ members.length;
                  for (final m in members) {
                    splits[m.id] = share;
                  }
                }

                if (splitMode == 'custom') {
                  int sum = 0;
                  for (final m in members) {
                    final v = int.tryParse(
                        splitControllers[m.id]!.text) ??
                        0;
                    splits[m.id] = v;
                    sum += v;
                  }
                  if (sum != total) {
                    setState(() =>
                    errorText = 'Split must sum to $total');
                    return;
                  }
                }

                if (splitMode == 'percent') {
                  int percentSum = 0;
                  for (final m in members) {
                    percentSum +=
                        int.tryParse(splitControllers[m.id]!.text) ??
                            0;
                  }
                  if (percentSum != 100) {
                    setState(() =>
                    errorText = 'Percentages must total 100');
                    return;
                  }

                  for (final m in members) {
                    final p = int.tryParse(
                        splitControllers[m.id]!.text) ??
                        0;
                    splits[m.id] =
                        ((p / 100) * total).round();
                  }
                }

                final newExpense = ExpenseModel(
                  id: expense?.id ?? '',
                  amount: total,
                  currency: circle.currencyCode,
                  paidBy: payerId,
                  splits: splits,
                  note: noteController.text.trim(),
                  createdAt:
                  expense?.createdAt ?? Timestamp.now(),
                );

                if (isEdit) {
                  await FirebaseFirestore.instance
                      .collection('circles')
                      .doc(circle.id)
                      .collection('expenses')
                      .doc(expense.id)
                      .update(newExpense.toMap());
                } else {
                  await FirebaseHelper.instance.addExpense(
                    circleId: circle.id,
                    expense: newExpense,
                  );
                }

                Navigator.pop(context);
              },
              child: Text(isEdit ? 'Save' : 'Add'),
            ),
          ],
        );
      },
    ),
  );
}

