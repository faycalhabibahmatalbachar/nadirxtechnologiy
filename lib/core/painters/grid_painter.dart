import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class GridPainter extends CustomPainter {
  final double spacing;
  final Color lineColor;
  final double strokeWidth;

  GridPainter({
    this.spacing = AppDimensions.gridSpacing,
    this.lineColor = AppColors.primary,
    this.strokeWidth = AppDimensions.gridLineWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor.withOpacity(0.03)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Lignes verticales
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Lignes horizontales
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
