import 'package:flutter/material.dart';

/// This activity will be used as splash screen for Android app similar to web app


class AnimatedBillLogo extends StatefulWidget {
  final double scale;
  const AnimatedBillLogo({super.key, this.scale = 1.0});

  @override
  State<AnimatedBillLogo> createState() => _AnimatedBillLogoState();
}

class _AnimatedBillLogoState extends State<AnimatedBillLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Accessing your AppTheme variables
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: Size(60 * widget.scale, 60 * widget.scale),
              painter: BillGraphPainter(
                progress: _controller.value,
                // Passing theme-based colors
                primaryColor: colorScheme.primary,
                lightColor: colorScheme.primaryContainer,
                mediumColor: colorScheme.secondary,
              ),
            );
          },
        ),
        SizedBox(height: 24 * widget.scale),
        Text(
          "BILLCIRCLE",
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 2 * widget.scale,
            fontSize: 24 * widget.scale,
          ),
        ),
      ],
    );
  }
}

class BillGraphPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color lightColor;
  final Color mediumColor;

  BillGraphPainter({
    required this.progress,
    required this.primaryColor,
    required this.lightColor,
    required this.mediumColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final double barW = size.width * 0.23;
    final double gap = size.width * 0.13;

    // Matches the CSS 'bill-pump' logic for uniformity
    double calcHeight(double delay) {
      double t = (progress + delay) % 1.0;
      return (t < 0.5 ? t * 2 : 2 - (t * 2));
    }

    void drawBar(double x, double heightFactor, Color color) {
      final double minH = size.height * 0.4;
      final double dynamicH = minH + (size.height - minH) * heightFactor;
      canvas.drawRRect(
        RRect.fromLTRBR(x, size.height - dynamicH, x + barW, size.height, const Radius.circular(4)),
        paint..color = color,
      );
    }

    drawBar(0, calcHeight(0.0), lightColor);           // Left
    drawBar(barW + gap, calcHeight(0.2), primaryColor); // Center
    drawBar((barW + gap) * 2, calcHeight(0.4), mediumColor); // Right
  }

  @override
  bool shouldRepaint(covariant BillGraphPainter oldDelegate) => true;
}