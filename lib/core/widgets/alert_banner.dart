import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum AlertType {
  critical, // Stolen, Impound, Suspended
  warning, // Pending challans, Expiring soon
  info,
}

class AlertBanner extends StatelessWidget {
  final String title;
  final String message;
  final AlertType type;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;

  const AlertBanner({
    super.key,
    required this.title,
    required this.message,
    this.type = AlertType.critical,
    this.icon,
    this.trailing,
    this.onTap,
  });

  factory AlertBanner.stolen({
    required String message,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return AlertBanner(
      title: 'STOLEN VEHICLE ALERT',
      message: message,
      type: AlertType.critical,
      icon: Icons.shield_moon_rounded,
      trailing: trailing,
      onTap: onTap,
    );
  }

  factory AlertBanner.blacklisted({
    required String message,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return AlertBanner(
      title: 'BLACKLISTED / IMPOUND NOTICE',
      message: message,
      type: AlertType.critical,
      icon: Icons.gavel_rounded,
      trailing: trailing,
      onTap: onTap,
    );
  }

  factory AlertBanner.pendingChallan({
    required int count,
    required double totalAmount,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return AlertBanner(
      title: '$count UNPAID CHALLANS (₹${totalAmount.toStringAsFixed(0)})',
      message: 'Vehicle has unresolved statutory fines pending settlement.',
      type: AlertType.warning,
      icon: Icons.warning_amber_rounded,
      trailing: trailing,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color text;
    Color iconColor;
    IconData defaultIcon;

    switch (type) {
      case AlertType.critical:
        bg = AppColors.errorBg;
        border = AppColors.errorBorder;
        text = AppColors.errorText;
        iconColor = AppColors.error;
        defaultIcon = Icons.error_outline_rounded;
        break;
      case AlertType.warning:
        bg = AppColors.warningBg;
        border = AppColors.warningBorder;
        text = AppColors.warningText;
        iconColor = AppColors.warning;
        defaultIcon = Icons.warning_amber_rounded;
        break;
      case AlertType.info:
        bg = AppColors.infoBg;
        border = AppColors.infoBorder;
        text = AppColors.infoText;
        iconColor = AppColors.info;
        defaultIcon = Icons.info_outline_rounded;
        break;
    }

    final displayIcon = icon ?? defaultIcon;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: 1.2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(displayIcon, size: 22, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleMedium.copyWith(
                        color: text,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      message,
                      style: AppTypography.bodySmall.copyWith(
                        color: text.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
