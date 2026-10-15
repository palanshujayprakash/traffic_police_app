import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class PlateDisplayCard extends StatelessWidget {
  final String plateNumber;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isCompact;

  const PlateDisplayCard({
    super.key,
    required this.plateNumber,
    this.subtitle,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final cleanPlate = plateNumber.toUpperCase().trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.hsrpPlateBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.hsrpPlateBorder,
              width: 2.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Left IND blue strip
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 6 : 8,
                    vertical: isCompact ? 6 : 8,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.hsrpBlueStrip,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(7.5),
                      bottomLeft: Radius.circular(7.5),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ashoka Chakra circle icon representation
                      Container(
                        width: isCompact ? 10 : 12,
                        height: isCompact ? 10 : 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.2),
                        ),
                        child: Center(
                          child: Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'IND',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isCompact ? 9 : 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                // Registration string
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 12 : 16,
                    vertical: isCompact ? 6 : 10,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cleanPlate,
                        style: (isCompact
                            ? AppTypography.headlineSmall
                            : AppTypography.plateDisplay).copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
