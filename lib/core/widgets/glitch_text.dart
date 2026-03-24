import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class GlitchText extends StatefulWidget {
  final String text;
  final double fontSize;
  final Color? color;
  final FontWeight? fontWeight;
  final double? letterSpacing;
  final bool enableGlitch;

  const GlitchText({
    super.key,
    required this.text,
    this.fontSize = 16,
    this.color,
    this.fontWeight,
    this.letterSpacing,
    this.enableGlitch = true,
  });

  @override
  State<GlitchText> createState() => _GlitchTextState();
}

class _GlitchTextState extends State<GlitchText> {
  Timer? _glitchTimer;
  bool _glitchActive = false;
  double _offsetX = 0;

  @override
  void initState() {
    super.initState();
    if (widget.enableGlitch) {
      _startGlitchEffect();
    }
  }

  void _startGlitchEffect() {
    _glitchTimer = Timer.periodic(
      AppDimensions.durationGlitchInterval,
      (_) {
        if (mounted) {
          setState(() {
            _glitchActive = true;
            _offsetX = (DateTime.now().millisecondsSinceEpoch % 2 == 0) ? 2 : -2;
          });
          Timer(AppDimensions.durationGlitch, () {
            if (mounted) {
              setState(() {
                _glitchActive = false;
                _offsetX = 0;
              });
            }
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _glitchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Texte rouge (offset)
        if (_glitchActive)
          Transform.translate(
            offset: Offset(_offsetX, 0),
            child: Text(
              widget.text,
              style: GoogleFonts.shareTechMono(
                fontSize: widget.fontSize,
                color: AppColors.error.withOpacity(0.5),
                fontWeight: widget.fontWeight,
                letterSpacing: widget.letterSpacing,
              ),
            ),
          ),
        // Texte cyan (offset inverse)
        if (_glitchActive)
          Transform.translate(
            offset: Offset(-_offsetX, 0),
            child: Text(
              widget.text,
              style: GoogleFonts.shareTechMono(
                fontSize: widget.fontSize,
                color: AppColors.secondary.withOpacity(0.5),
                fontWeight: widget.fontWeight,
                letterSpacing: widget.letterSpacing,
              ),
            ),
          ),
        // Texte principal
        AnimatedOpacity(
          duration: const Duration(milliseconds: 50),
          opacity: _glitchActive ? 0.8 : 1.0,
          child: Text(
            widget.text,
            style: GoogleFonts.shareTechMono(
              fontSize: widget.fontSize,
              color: widget.color ?? AppColors.primary,
              fontWeight: widget.fontWeight,
              letterSpacing: widget.letterSpacing,
            ),
          ),
        ),
      ],
    );
  }
}

class TypewriterText extends StatefulWidget {
  final String text;
  final Duration duration;
  final TextStyle? style;
  final VoidCallback? onComplete;

  const TypewriterText({
    super.key,
    required this.text,
    this.duration = const Duration(milliseconds: 80),
    this.style,
    this.onComplete,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayedText = '';
  int _charIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    _timer = Timer.periodic(widget.duration, (timer) {
      if (_charIndex < widget.text.length) {
        setState(() {
          _displayedText += widget.text[_charIndex];
          _charIndex++;
        });
      } else {
        timer.cancel();
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: widget.style,
    );
  }
}
