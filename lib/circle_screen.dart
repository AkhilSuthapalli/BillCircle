import 'dart:async';
import 'dart:math';

import 'package:billcircle/utils/app_bar.dart';
import 'package:billcircle/utils/app_constants.dart';
import 'package:billcircle/utils/split_expense.dart';
import 'package:billcircle/utils/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'utils/firebase_helper.dart';
import 'utils/currency_helper.dart';
import 'models/circle_model.dart';
import 'models/member_model.dart';
import 'models/expense_model.dart';

class CircleScreen extends StatefulWidget {
  final String circleId;

  const CircleScreen({
    super.key,
    required this.circleId,
  });

  @override
  State<CircleScreen> createState() => _CircleScreenState();
}

class _CircleScreenState extends State<CircleScreen> {

  bool _isLoggedIn = false;
  late final StreamSubscription<User?> _authSub;
  late final StreamSubscription<List<MemberModel>> _membersSub;
  List<MemberModel> _members = [];
  bool _membersLoading = true;
  Map<String, String> _memberNameMap = {};

  // Trying to initialize the stream at the start of the page build
  late Stream<List<MemberModel>> _membersStream;
  late Stream<CircleModel> _circleStream;
  late Stream<List<ExpenseModel>> _expensesStream;


  @override
  void initState() {
    super.initState();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        setState(() => _isLoggedIn = user != null);
      }
    });
    _membersStream = FirebaseHelper.instance.watchMembers(widget.circleId);
    _circleStream = FirebaseHelper.instance.watchCircle(widget.circleId);
    _expensesStream = FirebaseHelper.instance.watchExpenses(widget.circleId);
    _membersSub = FirebaseHelper.instance.watchMembers(widget.circleId)
        .listen((members) {
      if (mounted) {
        setState(() {
          _members = members;
          _memberNameMap = {
            for (final m in members) m.id: m.displayName
          };
          _membersLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _authSub.cancel();
    _membersSub.cancel();
    super.dispose();
  }

  // --------------------------------------------------
  // Permission logic (AUTHORITATIVE)
  // --------------------------------------------------

  bool _canEdit(CircleModel circle) {
    if (circle.isLocked) return false;
    if (circle.visibility == 'public') {
      return circle.linkCanEdit == true;
    }
    return _isLoggedIn ? circle.ownerUid ==  FirebaseAuth.instance.currentUser?.uid : false;
  }

  // --------------------------------------------------
  // UI
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CircleModel>(
      stream: _circleStream,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final circle = snap.data!;
        final canEdit = _canEdit(circle);
        final currency = currencyRegistry[circle.currencyCode]!;

        return Scaffold(
          appBar: CommonAppBar(),
          floatingActionButton: canEdit
              ? FloatingActionButton(
            onPressed: () =>
                showExpenseDialog(context, circle, _members ),
            child: const Icon(Icons.add),
          )
              : null,
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppConstants.maxPageWidth),
              child: ListView(
                children: [
                  _headerSection(circle, canEdit),
                  Divider(),
                  _membersSection(circle, canEdit),
                  Divider(),
                  _expensesSection(circle, currency.symbol, canEdit),
                  Divider(),
                  _settlementSection(circle, currency.symbol),
                ],
              ),
            ),
          )
        );
      },
    );
  }

  /* ======================================================
     1️⃣ HEADER SECTION
  ====================================================== */

  Widget _headerSection(CircleModel circle, bool canEdit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide()),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  circle.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (circle.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      circle.description,
                    ),
                  ),
              ],
            ),
          ),
          if (canEdit && circle.ownerUid != null)
            IconButton(
              icon: Icon(
                circle.isLocked ? Icons.lock : Icons.lock_open,
              ),
              onPressed: () {
                FirebaseHelper.instance.lockCircle(widget.circleId, !circle.isLocked);
              },
            ),
          IconButton(
            tooltip: 'Share link',
            icon: const Icon(Icons.share),
            onPressed: () => shareCircle(context, circle.accessToken),
          ),
        ],
      ),
    );
  }

  /* ======================================================
     2️⃣ MEMBERS SECTION
  ====================================================== */

  Widget _membersSection(CircleModel circle, bool canEdit) {
    return StreamBuilder<List<MemberModel>>(
      stream: _membersStream,
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox();
        final members = snap.data!;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Members',
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: [
                  ...members.map(
                        (m) => GestureDetector(
                      onTap: canEdit
                          ? () =>
                          _editMemberName(context, circle.id, m)
                          : null,
                      child: CircleAvatar(
                        child: Text(
                          m.displayName
                              .substring(0, 1)
                              .toUpperCase(),
                        ),
                      ),
                    ),
                  ),
                  if (canEdit)
                    IconButton(
                      icon:
                      const Icon(Icons.add_circle_outline),
                      onPressed: () =>
                          _addMember(context, circle.id),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /* ======================================================
     3️⃣ EXPENSES SECTION
  ====================================================== */

  Widget _expensesSection(CircleModel circle, String symbol, bool canEdit,) {
    return StreamBuilder<List<ExpenseModel>>(
      stream: _expensesStream,
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox();

        final expenses = snap.data!;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Expenses',
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (expenses.isEmpty)
                const Text('No expenses yet'),
              ...expenses.map(
                    (e) => ListTile(
                  title: Text(e.note.isEmpty ? 'Expense' : e.note),
                  subtitle: Text('Paid by ${_memberNameMap[e.paidBy]}'),
                  trailing: Text('$symbol${e.amount}'),
                      onTap: canEdit ? () => showExpenseDialog(
                        context,
                        circle,
                        _members,
                        expense: e, // <-- THIS enables edit
                      ) : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /* ======================================================
     4️⃣ SETTLEMENT SECTION
  ====================================================== */

  Widget _settlementSection(CircleModel circle, String symbol) {
    return StreamBuilder<List<ExpenseModel>>(
      stream: FirebaseHelper.instance.watchExpenses(circle.id),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox();

        final balances = _computeBalances(snap.data!);
        final settlements = _computeSettlements(balances);

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settlement',
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (settlements.isEmpty)
                const Text('All settled 🎉'),
              ...settlements.map(
                    (s) => Text(
                  '${_memberNameMap[s.from]} pays ${_memberNameMap[s.to]} $symbol${s.amount}',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
/* ======================================================
   MEMBER ACTIONS
====================================================== */

void _addMember(BuildContext context, String circleId) {
  final controller = TextEditingController();

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Add member'),
      content: TextField(
        controller: controller,
        decoration:
        const InputDecoration(labelText: 'Name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final name = controller.text.trim();
            if (name.isEmpty) return;

            final member = MemberModel(
              id: generateTempMemberId(),
              displayName: name,
              role: MemberRole.temp,
            );

            await FirebaseHelper.instance.addMember(
              circleId: circleId,
              member: member,
            );

            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    ),
  );
}

void _editMemberName(
    BuildContext context,
    String circleId,
    MemberModel member,
    ) {
  final controller =
  TextEditingController(text: member.displayName);

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Edit name'),
      content: TextField(
        controller: controller,
        decoration:
        const InputDecoration(labelText: 'Name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final name = controller.text.trim();
            if (name.isEmpty) return;

            await FirebaseFirestore.instance
                .collection('circles')
                .doc(circleId)
                .collection('members')
                .doc(member.id)
                .update({'displayName': name});

            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

/* ======================================================
   ADD EXPENSE
====================================================== */


/* ======================================================
   SETTLEMENT HELPERS
====================================================== */

Map<String, int> _computeBalances(List<ExpenseModel> expenses) {
  final Map<String, int> balances = {};
  for (final e in expenses) {
    balances[e.paidBy] =
        (balances[e.paidBy] ?? 0) + e.amount;
    e.splits.forEach((id, share) {
      balances[id] = (balances[id] ?? 0) - share;
    });
  }
  return balances;
}

class Settlement {
  final String from;
  final String to;
  final int amount;
  Settlement(this.from, this.to, this.amount);
}

List<Settlement> _computeSettlements(Map<String, int> balances) {
  final debtors = <String, int>{};
  final creditors = <String, int>{};

  balances.forEach((k, v) {
    if (v < 0) debtors[k] = -v;
    if (v > 0) creditors[k] = v;
  });

  final List<Settlement> result = [];

  for (final d in debtors.entries) {
    int remaining = d.value;
    for (final c in creditors.entries) {
      if (remaining == 0 || c.value == 0) continue;
      final amt = remaining < c.value ? remaining : c.value;
      result.add(Settlement(d.key, c.key, amt));
      remaining -= amt;
      creditors[c.key] = c.value - amt;
    }
  }
  return result;
}