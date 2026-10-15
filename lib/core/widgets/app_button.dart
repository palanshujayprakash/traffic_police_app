import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum ButtonVariant {
  primary,
  secondary,
  destructive,
  accent,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 52.0,
  });

  factory AppButton.primary({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isFullWidth = true,
    double height = 52.0,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.primary,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      height: height,
    );
  }

  factory AppButton.secondary({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isFullWidth = true,
    double height = 48.0,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.secondary,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      height: height,
    );
  }

  factory AppButton.destructive({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isFullWidth = true,
    double height = 52.0,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.destructive,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      height: height,
    );
  }

  factory AppButton.accent({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isFullWidth = true,
    double height = 52.0,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.accent,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      height: height,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide? border;

    switch (variant) {
      case ButtonVariant.primary:
        bg = AppColors.primary;
        fg = Colors.white;
        border = null;
        break;
      case ButtonVariant.secondary:
        bg = AppColors.surface;
        fg = AppColors.textPrimary;
        border = const BorderSide(color: AppColors.borderStrong, width: 1.5);
        break;
      case ButtonVariant.destructive:
        bg = AppColors.error;
        fg = Colors.white;
        border = null;
        break;
      case ButtonVariant.accent:
        bg = AppColors.accent;
        fg = Colors.white;
        border = null;
        break;
    }

    final isEnabled = onPressed != null && !isLoading;

    final content = isLoading
        ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    text,
                    style: AppTypography.labelLarge.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          );

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: fg,
      disabledBackgroundColor: bg.withValues(alpha: 0.5),
      disabledForegroundColor: fg.withValues(alpha: 0.7),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: border ?? BorderSide.none,
      ),
      padding: EdgeInsets.symmetric(horizontal: isFullWidth ? 16 : 8),
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: buttonStyle,
        child: content,
      ),
    );
  }
}
