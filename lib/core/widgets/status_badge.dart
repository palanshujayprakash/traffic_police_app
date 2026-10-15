import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum BadgeStatus {
  valid,
  warning,
  expired,
  info,
  neutral,
}

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeStatus status;
  final IconData? icon;
  final bool isCompact;

  const StatusBadge({
    super.key,
    required this.label,
    required this.status,
    this.icon,
    this.isCompact = false,
  });

  factory StatusBadge.valid({required String label, IconData? icon}) {
    return StatusBadge(
      label: label,
      status: BadgeStatus.valid,
      icon: icon ?? Icons.check_circle_rounded,
    );
  }

  factory StatusBadge.warning({required String label, IconData? icon}) {
    return StatusBadge(
      label: label,
      status: BadgeStatus.warning,
      icon: icon ?? Icons.access_time_rounded,
    );
  }

  factory StatusBadge.expired({required String label, IconData? icon}) {
    return StatusBadge(
      label: label,
      status: BadgeStatus.expired,
      icon: icon ?? Icons.error_rounded,
    );
  }

  factory StatusBadge.info({required String label, IconData? icon}) {
    return StatusBadge(
      label: label,
      status: BadgeStatus.info,
      icon: icon ?? Icons.info_outline_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color text;
    IconData defaultIcon;

    switch (status) {
      case BadgeStatus.valid:
        bg = AppColors.successBg;
        border = AppColors.successBorder;
        text = AppColors.successText;
        defaultIcon = Icons.check_circle_rounded;
        break;
      case BadgeStatus.warning:
        bg = AppColors.warningBg;
        border = AppColors.warningBorder;
        text = AppColors.warningText;
        defaultIcon = Icons.access_time_filled_rounded;
        break;
      case BadgeStatus.expired:
        bg = AppColors.errorBg;
        border = AppColors.errorBorder;
        text = AppColors.errorText;
        defaultIcon = Icons.warning_rounded;
        break;
      case BadgeStatus.info:
        bg = AppColors.infoBg;
        border = AppColors.infoBorder;
        text = AppColors.infoText;
        defaultIcon = Icons.info_rounded;
        break;
      case BadgeStatus.neutral:
        bg = AppColors.surfaceVariant;
        border = AppColors.border;
        text = AppColors.textSecondary;
        defaultIcon = Icons.circle;
        break;
    }

    final displayIcon = icon ?? defaultIcon;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(displayIcon, size: isCompact ? 12 : 14, color: text),
          const SizedBox(width: 5),
          Text(
            label.toUpperCase(),
            style: (isCompact ? AppTypography.labelSmall : AppTypography.labelSmall).copyWith(
              color: text,
              fontWeight: FontWeight.w700,
              fontSize: isCompact ? 10 : 11,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
