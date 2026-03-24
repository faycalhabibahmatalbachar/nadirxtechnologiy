import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class MatrixRainPainter extends StatefulWidget {
  final double opacity;

  const MatrixRainPainter({
    super.key,
    this.opacity = 0.04,
  });

  @override
  State<MatrixRainPainter> createState() => _MatrixRainPainterState();
}

class _MatrixRainPainterState extends State<MatrixRainPainter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  final List<_MatrixColumn> _columns = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Initialiser les colonnes après le premier frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeColumns();
    });

    // Mettre à jour périodiquement
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) {
        for (final column in _columns) {
          column.update();
        }
        setState(() {});
      }
    });
  }

  void _initializeColumns() {
    final size = MediaQuery.of(context).size;
    final columnCount = (size.width / 20).floor();
    _columns.clear();
    for (int i = 0; i < columnCount; i++) {
      _columns.add(_MatrixColumn(
        x: i * 20.0,
        screenHeight: size.height,
        random: _random,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _MatrixPainterWidget(
            columns: _columns,
            opacity: widget.opacity,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _MatrixColumn {
  final double x;
  final double screenHeight;
  final Random random;

  double y;
  double speed;
  int length;
  List<String> chars = [];

  _MatrixColumn({
    required this.x,
    required this.screenHeight,
    required this.random,
  })  : y = random.nextDouble() * screenHeight,
        speed = 1 + random.nextDouble() * 2,
        length = 5 + random.nextInt(15) {
    _generateChars();
  }

  void _generateChars() {
    chars = List.generate(length, (_) => random.nextBool() ? '0' : '1');
  }

  void update() {
    y += speed;
    if (y > screenHeight + length * 20) {
      y = -length * 20;
      speed = 1 + random.nextDouble() * 2;
      length = 5 + random.nextInt(15);
      _generateChars();
    }
  }
}

class _MatrixPainterWidget extends CustomPainter {
  final List<_MatrixColumn> columns;
  final double opacity;

  _MatrixPainterWidget({
    required this.columns,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      color: AppColors.primary.withOpacity(opacity),
      fontSize: 14,
      fontFamily: 'Courier',
    );

    for (final column in columns) {
      for (int i = 0; i < column.chars.length; i++) {
        final charY = column.y + i * 18;
        if (charY > 0 && charY < size.height) {
          final textSpan = TextSpan(
            text: column.chars[i],
            style: textStyle,
          );
          final textPainter = TextPainter(
            text: textSpan,
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(canvas, Offset(column.x, charY));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
