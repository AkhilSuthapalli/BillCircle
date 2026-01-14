import 'dart:async';

import 'package:billcircle/utils/currency_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/app_constants.dart';
import '../utils/ui_helpers.dart';
import '../utils/app_bar.dart';
import 'firebase_helper.dart';
import 'loading_circle_screen.dart';

class CreateCircleScreen extends StatefulWidget {
  const CreateCircleScreen({super.key});

  @override
  State<CreateCircleScreen> createState() => _CreateCircleScreenState();
}

class _CreateCircleScreenState extends State<CreateCircleScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isPrivate = false;
  bool _isLoading = false;

  // Only relevant when _isPrivate == false
  bool _publicCanEdit = true; // false = view only, true = edit

  late final StreamSubscription<User?> _authSub;
  bool _isLoggedIn = false;

  String _selectedCurrencyCode = 'INR';

  @override
  void initState() {
    super.initState();

    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        setState(() {
          _isLoggedIn = user != null;
          if (!_isLoggedIn) _publicCanEdit = true;
        });
      }
    });
  }


  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _authSub.cancel();
    super.dispose();
  }

  Future<void> _createCircle(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final String accessToken = generateSecureToken();

    try {
      print("token $accessToken");
      var a = await FirebaseHelper.instance.createCircle(
        name: _nameController.text,
        description: _descriptionController.text,
        visibility: _isPrivate ? 'private' : 'public',
        accessToken: accessToken,
        linkCanEdit: _publicCanEdit,
        ownerUid: _isLoggedIn ? FirebaseAuth.instance.currentUser?.uid : null,
        currencyCode: _selectedCurrencyCode,
      ).then((e){
        print("Creation successful");
        SnackbarHelper.show(context, 'Circle created successfully');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => LoadCircleScreen(token: accessToken),
          ),
        );
      });

    } catch (e) {
      SnackbarHelper.show(context, 'Failed to create circle $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;

    return AnimatedTheme(
      data: theme,
      duration: const Duration(milliseconds: 180),
      child: Scaffold(
        appBar: const CommonAppBar(
          title: 'Create Circle',
          showBack: false,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints:
            const BoxConstraints(maxWidth: AppConstants.maxPageWidth),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        /// Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.colorScheme.primaryContainer,
                              ),
                              child: Icon(
                                Icons.groups_outlined,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'New Bill Circle',
                                    style: text.titleLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Split expenses with friends effortlessly',
                                    style: text.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        /// Circle name
                        Text(
                          'Circle details',
                          style: text.titleMedium,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Circle name',
                            hintText: 'Goa Trip',
                          ),
                          validator: (v) =>
                          v == null || v.trim().isEmpty
                              ? 'Circle name is required'
                              : null,
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Description (optional)',
                            hintText: 'Friends trip – January',
                          ),
                        ),

                        const SizedBox(height: 24),
                        CurrencyDropdown(
                          selectedCode: _selectedCurrencyCode,
                          onChanged: (code) {
                            setState(() => _selectedCurrencyCode = code);
                          },
                        ),
                        const SizedBox(height: 24),

                        /// Privacy section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: theme.colorScheme.surfaceContainerHighest,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Privacy', style: text.titleMedium),
                              const SizedBox(height: 8),

                              SwitchListTile(
                                title: Text('Private circle', style: text.bodyLarge),
                                subtitle: Text(
                                  _isPrivate
                                      ? 'Only signed-in members can edit'
                                      : 'Anyone with the link can access',
                                ),
                                value: _isPrivate,
                                onChanged: _isLoggedIn
                                    ? (v) => setState(() => _isPrivate = v)
                                    : null,
                              ),

                              if (!_isPrivate) ...[
                                const Divider(),
                                SwitchListTile(
                                  title: Text(
                                    _publicCanEdit
                                        ? 'Anyone with the link can edit'
                                        : 'Anyone with the link can view only',
                                  ),
                                  value: _publicCanEdit,
                                  onChanged: _isLoggedIn
                                      ? (v) => setState(() => _publicCanEdit = v)
                                      : null,
                                ),
                              ],
                            ],
                          ),
                        ),


                        if (!_isLoggedIn)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              'Sign in to sync circles across devices',
                              style: text.bodySmall,
                            ),
                          ),

                        const SizedBox(height: 28),

                        /// CTA
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () => _createCircle(context),
                            child: _isLoading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                                : const Text('Create Circle'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
