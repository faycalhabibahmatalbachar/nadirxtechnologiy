import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class CyberButton extends StatelessWidget {
  final String label;
  final PhosphorIconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isEnabled;
  final double? width;
  final double height;

  const CyberButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isEnabled = true,
    this.width,
    this.height = AppDimensions.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isEnabled && !isLoading ? onPressed : null;

    if (isOutlined) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.primaryGlow,
                    blurRadius: AppDimensions.glowBlurButton,
                    spreadRadius: AppDimensions.glowSpreadButton,
                  ),
                ]
              : null,
        ),
        child: OutlinedButton.icon(
          onPressed: effectiveOnPressed,
          icon: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : icon != null
                  ? Icon(icon, size: AppDimensions.iconMd)
                  : const SizedBox.shrink(),
          label: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(
              color: isEnabled ? AppColors.primary : AppColors.border,
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
          ),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: isEnabled && !isLoading
            ? [
                BoxShadow(
                  color: AppColors.primaryGlow,
                  blurRadius: AppDimensions.glowBlurButton,
                  spreadRadius: AppDimensions.glowSpreadButton,
                ),
              ]
            : null,
      ),
      child: ElevatedButton.icon(
        onPressed: effectiveOnPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.background,
                ),
              )
            : icon != null
                ? Icon(icon, size: AppDimensions.iconMd)
                : const SizedBox.shrink(),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? AppColors.primary : AppColors.border,
          foregroundColor: AppColors.background,
          disabledBackgroundColor: AppColors.border,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
      ),
    );
  }
}

class CyberChip extends StatelessWidget {
  final String label;
  final PhosphorIconData? icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? selectedColor;
  final Color? unselectedColor;

  const CyberChip({
    super.key,
    required this.label,
    this.icon,
    this.isSelected = false,
    this.onTap,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (selectedColor ?? AppColors.primary.withAlpha(38))
              : (unselectedColor ?? AppColors.surfaceVariant),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: isSelected
                ? (selectedColor ?? AppColors.primary)
                : AppColors.border,
            width: isSelected ? 1.5 : 0.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryGlow,
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: AppDimensions.iconLg,
              ),
              const SizedBox(height: 6),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
