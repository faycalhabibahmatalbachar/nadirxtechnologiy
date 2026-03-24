import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class CyberCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool withGlow;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;

  const CyberCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.withGlow = false,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = AppDimensions.radiusLg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 20),
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: withGlow
            ? [
                BoxShadow(
                  color: AppColors.primaryGlow,
                  blurRadius: AppDimensions.glowBlur,
                  spreadRadius: AppDimensions.glowSpread,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

class CyberInfoRow extends StatelessWidget {
  final PhosphorIconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const CyberInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor ?? AppColors.secondary,
            size: AppDimensions.iconMd,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
