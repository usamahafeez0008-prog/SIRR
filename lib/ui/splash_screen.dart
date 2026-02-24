import 'package:driver/controller/splash_controller.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      init: SplashController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFFFAF9F6), // Professional Off-White
          body: Stack(
            children: [
              // Subtle Moroccan Pattern Background
              Positioned.fill(
                child: CustomPaint(
                  painter: MoroccanPatternPainter(),
                ),
              ),

              // Central Logo with Fade-in
              Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 2000),
                  curve: Curves.easeIn,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.scale(
                        scale: 0.8 + (0.2 * value),
                        child: child,
                      ),
                    );
                  },
                  child: Hero(
                    tag: 'app_logo',
                    child: Image.asset(
                      "assets/images/splash_image.png",
                      width: 320,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // Bottom Accents
              const Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: 50,
                    child: Divider(
                      color: AppColors.moroccoRed,
                      thickness: 3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MoroccanPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.moroccoGreen.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const double patternSize = 100.0;

    for (double x = -patternSize / 2;
        x < size.width + patternSize;
        x += patternSize) {
      for (double y = -patternSize / 2;
          y < size.height + patternSize;
          y += patternSize) {
        _drawEightPointStar(canvas, Offset(x, y), patternSize * 0.4, paint);
      }
    }

    // Add some corner decorations
    final cornerPaint = Paint()
      ..color = AppColors.moroccoRed.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    Path cornerPath = Path();
    cornerPath.moveTo(0, 0);
    cornerPath.lineTo(80, 0);
    cornerPath.quadraticBezierTo(40, 40, 0, 80);
    cornerPath.close();

    canvas.drawPath(cornerPath, cornerPaint);

    canvas.save();
    canvas.translate(size.width, size.height);
    canvas.rotate(math.pi);
    canvas.drawPath(cornerPath, cornerPaint);
    canvas.restore();
  }

  void _drawEightPointStar(
      Canvas canvas, Offset center, double radius, Paint paint) {
    Path path = Path();
    for (int i = 0; i < 8; i++) {
      double angle = i * math.pi / 4;
      double x = center.dx + radius * math.cos(angle);
      double y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Points in between
      double nextAngle = (i + 0.5) * math.pi / 4;
      double nextX = center.dx + (radius * 0.7) * math.cos(nextAngle);
      double nextY = center.dy + (radius * 0.7) * math.sin(nextAngle);
      path.lineTo(nextX, nextY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
