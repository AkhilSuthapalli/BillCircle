import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SnackbarHelper {
  static void show(
      BuildContext context,
      String message,
      ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

/// Call this function to show the animated popup
Future<void> showAnimatedAlert(
    BuildContext context, {
      required String title,
      required String message,
      String? primaryText,
      VoidCallback? onPrimary,
      String? secondaryText,
      VoidCallback? onSecondary,
      bool dismissible = true,
    }) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: dismissible,
    barrierLabel: 'Animated Alert',
    barrierColor: Colors.black.withOpacity(0.55),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, __, ___) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (context, animation, _, __) {
      final curved =
      CurvedAnimation(parent: animation, curve: Curves.easeOut);

      return Transform.scale(
        scale: 0.94 + (0.06 * curved.value),
        child: Opacity(
          opacity: curved.value,
          child: _AnimatedAlert(
            title: title,
            message: message,
            primaryText: primaryText,
            onPrimary: onPrimary,
            secondaryText: secondaryText,
            onSecondary: onSecondary,
          ),
        ),
      );
    },
  );
}

class _AnimatedAlert extends StatelessWidget {
  final String title;
  final String message;
  final String? primaryText;
  final VoidCallback? onPrimary;
  final String? secondaryText;
  final VoidCallback? onSecondary;

  const _AnimatedAlert({
    required this.title,
    required this.message,
    this.primaryText,
    this.onPrimary,
    this.secondaryText,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final scheme = theme.colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),

        child: Material(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          elevation: 8,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                width: 1.2,
                color: scheme.primary.withOpacity(
                  theme.brightness == Brightness.dark ? 0.45 : 0.35,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /// Title
                  Text(
                    title,
                    style: text.titleMedium,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  /// Message
                  Text(
                    message,
                    style: text.bodyMedium,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  /// Actions
                  Row(
                    children: [
                      if (secondaryText != null)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              onSecondary?.call();
                            },
                            child: Text(secondaryText!),
                          ),
                        ),

                      if (secondaryText != null &&
                          primaryText != null)
                        const SizedBox(width: 12),

                      if (primaryText != null)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              onPrimary?.call();
                            },
                            child: Text(primaryText!),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ),
      ),
    );
  }
}

void shareCircle(BuildContext context, String accessToken) {
  final url = 'https://app.billcircle.in?circle=$accessToken';

  showModalBottomSheet(
    context: context,
    builder: (_) => Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Share circle',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          SelectableText(
            url,
            style: const TextStyle(fontSize: 14),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text('Copy link'),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: url));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Link copied to clipboard'),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

