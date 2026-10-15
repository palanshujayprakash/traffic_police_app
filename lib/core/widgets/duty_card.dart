import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class DutyCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Color? iconBgColor;
  final VoidCallback? onTap;

  const DutyCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.iconColor = AppColors.primary,
    this.iconBgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = iconBgColor ?? iconColor.withValues(alpha: 0.1);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 18, color: iconColor),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(width: 4),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          subtitle!,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: AppTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    fontSize: 20,
                  ),
                  maxLines: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
