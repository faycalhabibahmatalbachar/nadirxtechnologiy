import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class CyberTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final PhosphorIconData? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final bool readOnly;
  final String? initialValue;
  final String? errorText;

  const CyberTextField({
    super.key,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.readOnly = false,
    this.initialValue,
    this.errorText,
  });

  @override
  State<CyberTextField> createState() => _CyberTextFieldState();
}

class _CyberTextFieldState extends State<CyberTextField> {
  late TextEditingController _controller;
  bool _hasFocus = false;
  FocusNode? _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _internalFocusNode = widget.focusNode ?? FocusNode();
    _internalFocusNode!.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant CyberTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller && widget.controller != null) {
      if (oldWidget.controller == null) {
        _controller.dispose();
      }
      _controller = widget.controller!;
    }

    if (oldWidget.focusNode != widget.focusNode && widget.focusNode != null) {
      if (oldWidget.focusNode == null) {
        _internalFocusNode?.removeListener(_onFocusChange);
        _internalFocusNode?.dispose();
      }
      _internalFocusNode = widget.focusNode;
      _internalFocusNode?.addListener(_onFocusChange);
    }
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _internalFocusNode!.hasFocus;
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _internalFocusNode!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            boxShadow: _hasFocus
                ? [
                    BoxShadow(
                      color: AppColors.primaryGlow,
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: _controller,
            focusNode: _internalFocusNode,
            validator: widget.validator,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            inputFormatters: widget.inputFormatters,
            obscureText: widget.obscureText,
            enabled: widget.enabled,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            readOnly: widget.readOnly,
            onTap: widget.onTap,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            initialValue: widget.controller == null ? widget.initialValue : null,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 12, right: 8),
                      child: Icon(
                        widget.prefixIcon,
                        color: _hasFocus
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: AppDimensions.iconMd,
                      ),
                    )
                  : null,
              suffixIcon: widget.suffixIcon,
              errorText: widget.errorText,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CyberDropdown<T> extends StatelessWidget {
  final String? label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final PhosphorIconData? prefixIcon;
  final String? hint;
  final bool enabled;

  const CyberDropdown({
    super.key,
    this.label,
    required this.value,
    required this.items,
    this.onChanged,
    this.prefixIcon,
    this.hint,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Row(
            children: [
              if (prefixIcon != null) ...[
                Icon(
                  prefixIcon,
                  color: AppColors.textSecondary,
                  size: AppDimensions.iconMd,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<T>(
                    value: value,
                    items: items,
                    onChanged: enabled ? onChanged : null,
                    hint: hint != null
                        ? Text(
                            hint!,
                            style: GoogleFonts.inter(
                              color: AppColors.textTertiary,
                              fontSize: 14,
                            ),
                          )
                        : null,
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceVariant,
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                    ),
                    icon: Icon(
                      PhosphorIcons.caretDown(),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CyberDatePicker extends StatelessWidget {
  final String? label;
  final DateTime? value;
  final void Function(DateTime)? onChanged;
  final PhosphorIconData? prefixIcon;
  final String? hint;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const CyberDatePicker({
    super.key,
    this.label,
    this.value,
    this.onChanged,
    this.prefixIcon,
    this.hint,
    this.firstDate,
    this.lastDate,
  });

  String _formatDate(DateTime date) {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return CyberTextField(
      label: label,
      hint: hint ?? 'Sélectionnez une date',
      prefixIcon: prefixIcon ?? PhosphorIcons.calendarBlank(),
      readOnly: true,
      onTap: () async {
        final effectiveFirstDate = firstDate ?? DateTime(1950);
        final effectiveLastDate = lastDate ?? DateTime.now();

        final fallbackInitial = value ?? effectiveLastDate;
        final effectiveInitialDate = fallbackInitial.isAfter(effectiveLastDate)
            ? effectiveLastDate
            : (fallbackInitial.isBefore(effectiveFirstDate)
                ? effectiveFirstDate
                : fallbackInitial);

        final picked = await showDatePicker(
          context: context,
          initialDate: effectiveInitialDate,
          firstDate: effectiveFirstDate,
          lastDate: effectiveLastDate,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: AppColors.primary,
                  surface: AppColors.surface,
                  onSurface: AppColors.textPrimary,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null && onChanged != null) {
          onChanged!(picked);
        }
      },
      controller: TextEditingController(
        text: value != null ? _formatDate(value!) : '',
      ),
    );
  }
}
