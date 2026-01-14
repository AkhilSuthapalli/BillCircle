import 'package:billcircle/utils/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_constants.dart';
import 'theme_controller.dart';

enum _ProfileAction { profile, logout }

class CommonAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String? title;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const CommonAppBar({
    super.key,
    this.title,
    this.showBack = false,
    this.onBack,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final themeController = context.read<ThemeController>();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        return AppBar(
          leading: showBack
              ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack,
          )
              : null,
          title: Text(title ?? AppConstants.appName),
          actions: [
            IconButton(
              tooltip: 'Toggle theme',
              icon: Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: themeController.toggle,
            ),
            if (user != null)
              PopupMenuButton<_ProfileAction>(
                tooltip: 'Account',
                onSelected: (action) async {
                  switch (action) {
                    case _ProfileAction.profile:
                      /// TODO: We need to build profile screen
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) => const ProfileScreen(),
                      //   ),
                      // );
                      break;
                    case _ProfileAction.logout:
                      await AuthService.signOut();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _ProfileAction.profile,
                    child: Row(
                      children: const [
                        Icon(Icons.person_outline, size: 18),
                        SizedBox(width: 12),
                        Text('Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: _ProfileAction.logout,
                    child: Row(
                      children: const [
                        Icon(Icons.logout, size: 18),
                        SizedBox(width: 12),
                        Text('Sign out'),
                      ],
                    ),
                  ),
                ],
              )
            else
              TextButton(
                onPressed: () async {
                  bool? successfulSignIn = await AuthService().signInWithGoogleWeb();
                  print("Sign in Successful: $successfulSignIn");
                },
                child: const Text('Sign in with Google'),
              ),
            if (actions != null) ...actions!,
            const SizedBox(width: 8),
          ],
        );
      }
    );

  }
}
