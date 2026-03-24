import 'package:flutter/material.dart';
import '../painters/grid_painter.dart';
import '../painters/scanline_painter.dart';

class CyberBackground extends StatelessWidget {
  final Widget child;
  final bool showGrid;
  final bool showScanlines;
  final double gridOpacity;
  final double scanlineOpacity;

  const CyberBackground({
    super.key,
    required this.child,
    this.showGrid = true,
    this.showScanlines = true,
    this.gridOpacity = 0.03,
    this.scanlineOpacity = 0.02,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fond de base
        const SizedBox.expand(
          child: ColoredBox(color: Color(0xFF050508)),
        ),
        // Grille
        if (showGrid)
          Positioned.fill(
            child: CustomPaint(
              painter: GridPainter(
                lineColor: const Color(0xFF00FF88).withOpacity(gridOpacity),
              ),
            ),
          ),
        // Scanlines
        if (showScanlines)
          Positioned.fill(
            child: CustomPaint(
              painter: ScanlinePainter(
                lineColor: const Color(0xFF00FF88).withOpacity(scanlineOpacity),
              ),
            ),
          ),
        // Contenu
        child,
      ],
    );
  }
}
