import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ScanlinePainter extends CustomPainter {
  final double lineHeight;
  final double gap;
  final Color lineColor;

  ScanlinePainter({
    this.lineHeight = 2,
    this.gap = 4,
    this.lineColor = AppColors.scanline,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    double y = 0;
    while (y < size.height) {
      canvas.drawRect(
        Rect.fromLTWH(0, y, size.width, lineHeight),
        paint,
      );
      y += lineHeight + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
