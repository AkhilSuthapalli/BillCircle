import 'package:billcircle/main.dart';
import 'package:billcircle/utils/platform_resolver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'circle_screen.dart';
import 'utils/firebase_helper.dart';

class LoadCircleScreen extends StatelessWidget {
  final String token;

  const LoadCircleScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseHelper.instance.getCircleByToken(token),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return InvalidLinkScreen();
        }

        return CircleScreen(circleId: snapshot.data!.id);
      },
    );
  }

}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading…',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InvalidLinkScreen extends StatelessWidget {
  const InvalidLinkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.link_off,
                size: 64,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 24),
              const Text(
                'Invalid or expired link',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'This Bill Circle link does not exist or is no longer accessible.',
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
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
                child: const Text('Go back to main screen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
