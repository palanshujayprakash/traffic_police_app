import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../data/repositories/mock_data_repository.dart';
import '../../../data/services/audit_service.dart';
import '../../../data/services/auth_service.dart';
import '../challan/issue_challan_screen.dart';

class VehicleDetailsScreen extends StatelessWidget {
  final VehicleModel vehicle;

  const VehicleDetailsScreen({
    super.key,
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd-MMM-yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('VEHICLE REGISTRY RECORD'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share Record',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Vehicle profile for ${vehicle.registrationNumber} copied')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Critical Stolen / Blacklisted Banner
            if (vehicle.isStolen) ...[
              AlertBanner.stolen(
                message: vehicle.stolenFirDetails ?? 'Reported stolen. Detain driver and impound vehicle immediately.',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppButton.destructive(
                      text: 'Dispatch 112',
                      icon: Icons.phone_in_talk_rounded,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Connecting to Police Control Room (112)...')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton.primary(
                      text: 'Initiate Impound',
                      icon: Icons.gavel_rounded,
                      onPressed: () => _showImpoundDialog(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ] else if (vehicle.isBlacklisted) ...[
              AlertBanner.blacklisted(
                message: vehicle.blacklistReason ?? 'Vehicle blacklisted by Regional Transport Authority.',
              ),
              const SizedBox(height: 16),
            ],

            // 2. High-Impact HSRP License Plate Presentation Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.canvas,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          vehicle.type.displayName.toUpperCase(),
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accentContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          vehicle.emissionNorms,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Centered HSRP Card
                  PlateDisplayCard(
                    plateNumber: vehicle.registrationNumber,
                    subtitle: 'LASER CODE: DL21HSRP-${vehicle.chassisNumber.substring(vehicle.chassisNumber.length - 6)}',
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: vehicle.registrationNumber));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${vehicle.registrationNumber} copied to clipboard')),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  Text(
                    vehicle.makeModel,
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Color: ${vehicle.color} • ${vehicle.fuelType}',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Technical & Registration Specifications
            const SectionHeader(title: 'Registration & Ownership', icon: Icons.person_rounded),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Owner Name', vehicle.ownerName),
                  const Divider(),
                  _buildDetailRow('Owner Contact', vehicle.ownerPhone),
                  const Divider(),
                  _buildDetailRow('Registering Authority', vehicle.registrationAuthority),
                  const Divider(),
                  _buildDetailRow('Registration Date', dateFormat.format(vehicle.registrationDate)),
                  const Divider(),
                  _buildDetailRow('Chassis Number', vehicle.chassisNumber, isMonospace: true),
                  const Divider(),
                  _buildDetailRow('Engine Number', vehicle.engineNumber, isMonospace: true),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. Statutory Document Validities
            const SectionHeader(title: 'Statutory Documents', icon: Icons.verified_user_rounded),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vehicle.documents.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final doc = vehicle.documents[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc.title,
                              style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Doc #${doc.documentNumber} • Valid till ${dateFormat.format(doc.validUpto)}',
                              style: AppTypography.bodySmall.copyWith(fontSize: 11),
                            ),
                            if (doc.notes.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                doc.notes,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: doc.isExpired ? AppColors.error : AppColors.warning,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      StatusBadge(
                        label: doc.status == BadgeStatus.valid
                            ? 'VALID'
                            : doc.status == BadgeStatus.warning
                                ? 'EXPIRING'
                                : 'EXPIRED',
                        status: doc.status,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // 5. Pending Challan Alert Card (if any)
            if (vehicle.hasPendingChallans) ...[
              AlertBanner.pendingChallan(
                count: vehicle.pendingChallanCount,
                totalAmount: vehicle.pendingChallanAmount,
                trailing: TextButton(
                  onPressed: () {},
                  child: const Text('DETAILS', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 6. Primary Action Buttons
            AppButton.primary(
              text: 'Issue E-Challan For This Vehicle',
              icon: Icons.receipt_rounded,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => IssueChallanScreen(preselectedVehicle: vehicle),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            if (!vehicle.isStolen)
              AppButton.destructive(
                text: 'Impound / Seize Vehicle',
                icon: Icons.gavel_rounded,
                onPressed: () => _showImpoundDialog(context),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isMonospace = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: isMonospace
                  ? AppTypography.labelMedium.copyWith(fontFamily: 'Courier', fontWeight: FontWeight.w700)
                  : AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _showImpoundDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Vehicle Seizure / Impound'),
          ],
        ),
        content: Text(
          'Confirm impound order for ${vehicle.registrationNumber}? An official e-Impound memo will be filed with Regional Transport Office.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              AuditService.instance.logImpound(
                vehicleNumber: vehicle.registrationNumber,
                reason: vehicle.isStolen
                    ? 'Stolen Vehicle Interception (FIR Match)'
                    : 'Statutory non-compliance / expired documentation',
                officerBadge: AuthService().currentInspector?.badgeNumber ?? MockDataRepository.activeInspector.badgeNumber,
                officerName: AuthService().currentInspector?.name ?? MockDataRepository.activeInspector.name,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.error,
                  content: Text('Impound memo filed for ${vehicle.registrationNumber}. Tow dispatch notified & audit logged.'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('CONFIRM IMPOUND', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
