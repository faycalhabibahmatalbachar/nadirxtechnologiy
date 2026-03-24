import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class TerminalLoader extends StatefulWidget {
  final double progress;
  final String? message;
  final bool showPercentage;

  const TerminalLoader({
    super.key,
    this.progress = 0,
    this.message,
    this.showPercentage = true,
  });

  @override
  State<TerminalLoader> createState() => _TerminalLoaderState();
}

class _TerminalLoaderState extends State<TerminalLoader> {
  @override
  Widget build(BuildContext context) {
    final percentage = (widget.progress * 100).toInt();
    final filled = (percentage / 5).round();
    final empty = 20 - filled;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.message != null) ...[
          Text(
            widget.message!,
            style: GoogleFonts.sourceCodePro(
              color: AppColors.primary,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '█' * filled,
              style: GoogleFonts.sourceCodePro(
                color: AppColors.primary,
                fontSize: 14,
              ),
            ),
            Text(
              '░' * empty,
              style: GoogleFonts.sourceCodePro(
                color: AppColors.textTertiary,
                fontSize: 14,
              ),
            ),
            if (widget.showPercentage) ...[
              const SizedBox(width: 8),
              Text(
                '$percentage%',
                style: GoogleFonts.sourceCodePro(
                  color: AppColors.primary,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class TerminalProgressOverlay extends StatefulWidget {
  final bool isVisible;
  final List<String> messages;
  final VoidCallback? onComplete;

  const TerminalProgressOverlay({
    super.key,
    required this.isVisible,
    required this.messages,
    this.onComplete,
  });

  @override
  State<TerminalProgressOverlay> createState() => _TerminalProgressOverlayState();
}

class _TerminalProgressOverlayState extends State<TerminalProgressOverlay> {
  final List<String> _displayedMessages = [];
  int _currentMessageIndex = 0;
  Timer? _messageTimer;

  @override
  void initState() {
    super.initState();
    if (widget.isVisible) {
      _startMessages();
    }
  }

  @override
  void didUpdateWidget(TerminalProgressOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _startMessages();
    } else if (!widget.isVisible) {
      _stopMessages();
    }
  }

  void _startMessages() {
    _displayedMessages.clear();
    _currentMessageIndex = 0;
    _showNextMessage();
  }

  void _showNextMessage() {
    if (_currentMessageIndex < widget.messages.length) {
      setState(() {
        _displayedMessages.add(widget.messages[_currentMessageIndex]);
      });
      _currentMessageIndex++;
      _messageTimer = Timer(const Duration(milliseconds: 150), _showNextMessage);  // Accéléré: 500ms → 150ms ⚡
    } else {
      widget.onComplete?.call();
    }
  }

  void _stopMessages() {
    _messageTimer?.cancel();
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return Positioned.fill(
      child: Container(
        color: AppColors.background.withOpacity(0.9),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '> TRAITEMENT EN COURS',
                  style: GoogleFonts.shareTechMono(
                    color: AppColors.primary,
                    fontSize: 13,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 20),
                ...List.generate(_displayedMessages.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text(
                          '> ',
                          style: GoogleFonts.sourceCodePro(
                            color: AppColors.primary,
                            fontSize: 12,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _displayedMessages[index],
                            style: GoogleFonts.sourceCodePro(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (index == _displayedMessages.length - 1)
                          const _BlinkingCursor(),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _controller.value,
          child: Text(
            '█',
            style: GoogleFonts.sourceCodePro(
              color: AppColors.primary,
              fontSize: 12,
            ),
          ),
        );
      },
    );
  }
}
