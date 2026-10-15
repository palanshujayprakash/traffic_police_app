import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onCameraScan;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool readOnly;
  final bool autoFocus;
  final bool forceUppercase;
  final int maxLines;

  const CustomTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.onCameraScan,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.obscureText = false,
    this.readOnly = false,
    this.autoFocus = false,
    this.forceUppercase = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    Widget? trailingWidget = suffixIcon;

    if (onCameraScan != null) {
      trailingWidget = IconButton(
        icon: const Icon(
          Icons.camera_alt_rounded,
          color: AppColors.primary,
          size: 22,
        ),
        tooltip: 'Scan License Plate (OCR)',
        onPressed: onCameraScan,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          readOnly: readOnly,
          autofocus: autoFocus,
          maxLines: maxLines,
          inputFormatters: [
            if (forceUppercase)
              TextInputFormatter.withFunction(
                (oldValue, newValue) => newValue.copyWith(
                  text: newValue.text.toUpperCase(),
                ),
              ),
          ],
          style: (forceUppercase
                  ? AppTypography.bodyLarge.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w600)
                  : AppTypography.bodyLarge)
              .copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.textSecondary, size: 22)
                : null,
            suffixIcon: trailingWidget,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderStrong, width: 1.2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderStrong, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
