import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class NadirxLogo extends StatefulWidget {
  final bool compact;
  final bool animate;
  final bool showSubtitle;

  const NadirxLogo({
    super.key,
    this.compact = false,
    this.animate = true,
    this.showSubtitle = false,
  });

  @override
  State<NadirxLogo> createState() => _NadirxLogoState();
}

class _NadirxLogoState extends State<NadirxLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  int _displayedChars = 0;
  bool _showSubtitle = false;
  Timer? _typewriterTimer;
  Timer? _glitchTimer;
  bool _glitchActive = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: AppDimensions.durationPulse,
    )..repeat(reverse: true);

    if (widget.animate && !widget.compact) {
      _startTypewriter();
      _startGlitchEffect();
    } else {
      _displayedChars = 'NADIRX TECHNOLOGY'.length;
      _showSubtitle = true;
    }
  }

  void _startTypewriter() {
    _typewriterTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) {
        if (_displayedChars < 'NADIRX TECHNOLOGY'.length) {
          setState(() {
            _displayedChars++;
          });
        } else {
          timer.cancel();
          setState(() {
            _showSubtitle = true;
          });
        }
      },
    );
  }

  void _startGlitchEffect() {
    _glitchTimer = Timer.periodic(AppDimensions.durationGlitchInterval, (_) {
      if (mounted) {
        setState(() {
          _glitchActive = true;
        });
        Timer(AppDimensions.durationGlitch, () {
          if (mounted) {
            setState(() {
              _glitchActive = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _typewriterTimer?.cancel();
    _glitchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoText = 'NADIRX TECHNOLOGY';
    final safeCount = _displayedChars.clamp(0, logoText.length);
    final displayedText = logoText.substring(0, safeCount);

    if (widget.compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildShield(size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'NADIRX TECHNOLOGY',
                style: GoogleFonts.shareTechMono(
                  fontSize: 16,
                  color: AppColors.primary,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Shield animé
            if (widget.animate)
              _buildShield(size: AppDimensions.logoShieldSize)
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 500.ms,
                    curve: Curves.easeOutBack,
                  )
            else
              _buildShield(size: AppDimensions.logoShieldSize),
            const SizedBox(width: 12),
            // Texte NADIRX avec effet glitch
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        _glitchActive ? (_glitchTimer != null ? 1 : -1) : 0,
                        0,
                      ),
                      child: Opacity(
                        opacity: _glitchActive ? 0.8 : 1.0,
                        child: Text(
                          displayedText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.shareTechMono(
                            fontSize: AppDimensions.logoFontSize,
                            color: AppColors.primary,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        if (widget.showSubtitle) ...[
          const SizedBox(height: 4),
          AnimatedOpacity(
            opacity: _showSubtitle ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Text(
              'TECHNOLOGY',
              style: GoogleFonts.inter(
                fontSize: AppDimensions.logoSubtitleFontSize,
                color: AppColors.textSecondary,
                letterSpacing: 4,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildShield({required double size}) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulseOpacity = 0.6 + (_pulseController.value * 0.4);
        return CustomPaint(
          size: Size(size, size),
          painter: _ShieldPainter(
            color: AppColors.primary,
            opacity: pulseOpacity,
          ),
        );
      },
    );
  }
}

class _ShieldPainter extends CustomPainter {
  final Color color;
  final double opacity;

  _ShieldPainter({
    required this.color,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withAlpha((opacity * 255).round().clamp(0, 255))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final fillPaint = Paint()
      ..color = color.withAlpha(26)
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // Forme du shield
    path.moveTo(w * 0.5, 0);
    path.lineTo(w * 0.9, h * 0.15);
    path.quadraticBezierTo(w, h * 0.5, w * 0.85, h * 0.85);
    path.quadraticBezierTo(w * 0.5, h, w * 0.15, h * 0.85);
    path.quadraticBezierTo(0, h * 0.5, w * 0.1, h * 0.15);
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);

    // Lettre N stylisée
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'N',
        style: TextStyle(
          color: color.withAlpha((opacity * 255).round().clamp(0, 255)),
          fontSize: size.width * 0.4,
          fontFamily: 'ShareTechMono',
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _ShieldPainter oldDelegate) =>
      opacity != oldDelegate.opacity;
}
