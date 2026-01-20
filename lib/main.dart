import 'package:billcircle/loading_circle_screen.dart';
import 'package:billcircle/utils/app_bar.dart';
import 'package:billcircle/utils/app_constants.dart';
import 'package:billcircle/utils/platform_resolver.dart';
import 'package:billcircle/utils/android_app_solver.dart';
import 'package:billcircle/utils/theme_controller.dart';
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

class MyApp extends StatefulWidget {
  final String? token;
  final String? action;
  const MyApp({super.key, required this.token, required this.action});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // We store the widget in a variable so it never changes
  // when the theme toggles.
  late Widget _initialScreen;

  @override
  void initState() {
    super.initState();
    // Logic runs ONCE at startup
    _initialScreen = _defineAction();
  }

  Widget _defineAction() {
    if (widget.action == "create") {
      return const CreateCircleScreen();
    } else if (widget.token != '' && widget.token != null) {
      return LoadCircleScreen(token: widget.token!);
    } else {
      return MainScreen(token: widget.token);
    }
  }

  @override
  Widget build(BuildContext context) {
    // This watch only triggers a repaint of colors now,
    // it doesn't re-run _defineAction()
    final theme = context.watch<ThemeController>();

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: theme.mode,
      home: _initialScreen, // Use the cached variable
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
