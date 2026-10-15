import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/repositories/mock_data_repository.dart';
import '../../../data/services/auth_service.dart';
import '../scanner/anpr_scanner_screen.dart';
import '../vehicle/vehicle_details_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigateTab;
  final Function(String plate) onSearchPlate;

  const HomeScreen({
    super.key,
    required this.onNavigateTab,
    required this.onSearchPlate,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _plateController = TextEditingController();
  bool _isBoloDismissed = false;

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  void _triggerSearch(String rawPlate) {
    final query = rawPlate.trim();
    if (query.isNotEmpty) {
      widget.onSearchPlate(query);
      widget.onNavigateTab(1);
    }
  }

  void _showSosEmergencyDialog(BuildContext context, String officerName, String badgeNumber) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.errorBorder),
              ),
              child: const Icon(Icons.sos_rounded, color: AppColors.error, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SOS EMERGENCY ALERT',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    'Central Dispatch Broadcast',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              'Broadcasting urgent officer safety distress call to Delhi Police Central Control Room (112) with live GPS telematics.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSosMetaRow(Icons.person_pin_rounded, 'Officer', '$officerName (Badge #$badgeNumber)'),
                  const SizedBox(height: 6),
                  _buildSosMetaRow(Icons.pin_drop_rounded, 'Location', 'Sector 4 — MG Road Jnc (28.5355° N, 77.2090° E)'),
                  const SizedBox(height: 6),
                  _buildSosMetaRow(Icons.cell_tower_rounded, 'Channel', 'PCR Tactical TG-4 • 5G Encrypted'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.error,
                  duration: Duration(seconds: 4),
                  content: Text('🚨 SOS DISPATCH CONFIRMED: PCR Patrol Delta-4 Dispatched to your GPS coordinates!'),
                ),
              );
            },
            icon: const Icon(Icons.emergency_rounded, size: 18),
            label: const Text('DISPATCH 112 NOW'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSosMetaRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final inspector = AuthService().currentInspector ?? MockDataRepository.activeInspector;
    final stolenVehicle = MockDataRepository.mockVehicles.firstWhere((v) => v.isStolen);

    // List of recent inspections matching Stitch design
    final recentVehicles = MockDataRepository.mockVehicles.take(4).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.local_police_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TRAFFIC POLICE',
                  style: AppTypography.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'DELHI POLICE ENFORCEMENT',
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white70,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Badge(
              backgroundColor: AppColors.error,
              child: Icon(Icons.notifications_outlined),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('High Priority BOLO: Stolen Truck HR 55 TR 9012 active.')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Urgent Broadcast / BOLO Alert Banner (Reverse Engineered from Stitch)
            if (!_isBoloDismissed) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.error.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'HIGH PRIORITY BOLO',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '14m ago',
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${stolenVehicle.makeModel} (${stolenVehicle.registrationNumber}) reported near Ring Road',
                            style: AppTypography.labelMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VehicleDetailsScreen(vehicle: stolenVehicle),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.error,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('INTERCEPT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => setState(() => _isBoloDismissed = true),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 2. Officer Duty Greeting Header Card (Stitch Duty Guard)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppColors.primary,
                                  child: Text(
                                    inspector.avatarInitials,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: AppColors.success,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'NAMASTE • DUTY ACTIVE',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                  Text(
                                    inspector.name,
                                    style: AppTypography.headlineSmall.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${inspector.rank} • Badge #${inspector.badgeNumber}',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Quick SOS Button
                      ElevatedButton.icon(
                        onPressed: () => _showSosEmergencyDialog(context, inspector.name, inspector.badgeNumber),
                        icon: const Icon(Icons.sos_rounded, size: 18),
                        label: const Text('SOS'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.errorBg,
                          foregroundColor: AppColors.error,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: Size.zero,
                          side: const BorderSide(color: AppColors.errorBorder),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Active Beat & Live Pulse Status banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.pin_drop_rounded, size: 18, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      inspector.beatLocation,
                                      style: AppTypography.labelMedium.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      inspector.shift,
                                      style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.successBg,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppColors.successBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'LIVE',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.successText,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Instant VAHAN Lookup Trigger Bar (Reverse Engineered from Stitch)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'INSTANT VAHAN LOOKUP',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.bolt_rounded, size: 14, color: AppColors.accent),
                          const SizedBox(width: 2),
                          Text(
                            'Fast OCR Ready',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: AppColors.canvas,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'IND',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _plateController,
                                  textCapitalization: TextCapitalization.characters,
                                  style: AppTypography.headlineSmall.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                    fontSize: 15,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'e.g. DL 01 CA 8821',
                                    hintStyle: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.textMuted,
                                      letterSpacing: 0.2,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onSubmitted: _triggerSearch,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.photo_camera_rounded, color: AppColors.primary, size: 22),
                                tooltip: 'Open ANPR Scanner',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const AnprScannerScreen()),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => _triggerSearch(_plateController.text),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. Today's Stats Summary Row (3 Metrics Cards)
            Row(
              children: [
                Expanded(
                  child: DutyCard(
                    title: 'Checked',
                    value: '${inspector.vehiclesCheckedToday}',
                    subtitle: '+12% shift',
                    icon: Icons.directions_car_rounded,
                    iconColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DutyCard(
                    title: 'Challans',
                    value: '${inspector.challansIssuedToday}',
                    subtitle: '₹18,500',
                    icon: Icons.receipt_long_rounded,
                    iconColor: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DutyCard(
                    title: 'BOLO',
                    value: '3',
                    subtitle: '2 Stolen',
                    icon: Icons.security_rounded,
                    iconColor: AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 5. Field Actions Grid (2x2 Cards with Stitch Icons and Subtitles)
            const SectionHeader(title: 'Field Operations', icon: Icons.grid_view_rounded),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.38,
              children: [
                _buildActionTile(
                  title: 'Scan Plate',
                  subtitle: 'Live ANPR OCR Viewfinder',
                  badgeText: 'Fast OCR',
                  icon: Icons.document_scanner_rounded,
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AnprScannerScreen()),
                    );
                  },
                ),
                _buildActionTile(
                  title: 'Search Vehicle',
                  subtitle: 'Eng. No. altered plate verify',
                  badgeText: 'VAHAN',
                  icon: Icons.fingerprint_rounded,
                  color: AppColors.info,
                  onTap: () => widget.onNavigateTab(1),
                ),
                _buildActionTile(
                  title: 'Issue Challan',
                  subtitle: 'Offense & penalty calc',
                  badgeText: 'MVA 2019',
                  icon: Icons.assignment_turned_in_rounded,
                  color: AppColors.accent,
                  onTap: () => widget.onNavigateTab(2),
                ),
                _buildActionTile(
                  title: 'Driver License',
                  subtitle: 'Verify DL validity & points',
                  badgeText: 'SARATHI',
                  icon: Icons.badge_rounded,
                  color: AppColors.success,
                  onTap: () => widget.onNavigateTab(1),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 6. Recent Inspections Stream (Audit Feed from Stitch)
            SectionHeader(
              title: 'Recent Inspections',
              icon: Icons.timeline_rounded,
              actionText: 'View Audit Log',
              onActionTap: () => widget.onNavigateTab(3),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentVehicles.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final vehicle = recentVehicles[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VehicleDetailsScreen(vehicle: vehicle),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        PlateDisplayCard(
                          plateNumber: vehicle.registrationNumber,
                          isCompact: true,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vehicle.makeModel,
                                style: AppTypography.labelMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${vehicle.color} • ${vehicle.ownerName}',
                                style: AppTypography.bodySmall.copyWith(fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        StatusBadge(
                          label: vehicle.isStolen
                              ? 'BOLO'
                              : vehicle.pendingChallanCount > 0
                                  ? '${vehicle.pendingChallanCount} Challan'
                                  : 'VALID',
                          status: vehicle.isStolen
                              ? BadgeStatus.expired
                              : vehicle.pendingChallanCount > 0
                                  ? BadgeStatus.warning
                                  : BadgeStatus.valid,
                          isCompact: true,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // 7. Operational Footer Utilities (Stitch synchronizer banner)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.cloud_sync_rounded, size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'NIC / VAHAN Server: Synchronized',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'v3.4.2-IND',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required String badgeText,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 18, color: color),
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  fontSize: 10,
                  color: AppColors.textSecondary,
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
