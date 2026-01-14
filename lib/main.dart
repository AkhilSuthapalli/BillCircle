import 'package:billcircle/loading_circle_screen.dart';
import 'package:billcircle/utils/app_bar.dart';
import 'package:billcircle/utils/app_constants.dart';
import 'package:billcircle/utils/platform_resolver.dart';
import 'package:billcircle/utils/android_app_solver.dart';
import 'package:billcircle/utils/theme_controller.dart';
import 'package:billcircle/utils/ui_helpers.dart';
import 'package:billcircle/utils/web_app_solver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'create_circle_screen.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final PlatformResolver resolver = kIsWeb ? WebAppSolver() : AndroidAppSolver();

  final token = resolver.getInitialCircleToken();
  final action = resolver.getAction();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: MyApp(token: token,action: action),
    ),
  );
}

class MyApp extends StatelessWidget {

  final String? token;
  final String? action;
  const MyApp({super.key, required this.token, required this.action});

  Widget _defineAction(){

    if (action == "create") {
      print("Action Create received");
      return const CreateCircleScreen();
    }else if(token != '' && token != null){
      print("Found token $token, loading it");
      return LoadCircleScreen(token: token!);
    }else {
      print("Default");
      return MainScreen(token: token);
    }

  }


  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: theme.mode,
      home: _defineAction(),
    );
  }
}

class MainScreen extends StatelessWidget {
  final String? token;
  const MainScreen({super.key, required this.token});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(),
      body: Center(
        child: ConstrainedBox(
          constraints:
          const BoxConstraints(maxWidth: AppConstants.maxPageWidth),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 56,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Split bills effortlessly',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create a circle or join one with a shared link.\nNo login required.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          print("moving to creation screen");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateCircleScreen(),
                            ),
                          );
                        },
                        child: Text('Create a Circle'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: Join circle
                        },
                        child: Text('Join a Circle'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
