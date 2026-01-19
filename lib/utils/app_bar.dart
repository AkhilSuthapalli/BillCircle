import 'package:billcircle/main.dart';
import 'package:billcircle/utils/auth_service.dart';
import 'package:billcircle/utils/platform_resolver.dart';
import 'package:billcircle/utils/web_app_solver.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'android_app_solver.dart';
import 'app_constants.dart';
import 'theme_controller.dart';

enum _ProfileAction { profile, logout }

class CommonAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const CommonAppBar({
    super.key,
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
          title: TextButton(
            onPressed: () {
              if(kIsWeb){
                resolver.clearUrl();
              }
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const MainScreen(token: '',),
                ),
              );
              },
            child: Text(AppConstants.appName),),
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
            // TODO implement Google Sign in once completed
            //_signInOption(user),
            if (actions != null) ...actions!,
            const SizedBox(width: 8),
          ],
        );
      }
    );

  }

  Widget _signInOption(User? user){
    if (user != null) {
      return PopupMenuButton<_ProfileAction>(
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
      );
    } else {
      return TextButton(
        onPressed: () async {
          bool? successfulSignIn = await AuthService().signInWithGoogleWeb();
          print("Sign in Successful: $successfulSignIn");
        },
        child: const Text('Sign in with Google'),
      );
    }
  }

}
