import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../data/models/challan_model.dart';
import '../../../data/repositories/mock_data_repository.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/challan_service.dart';
import '../../../data/services/offline_sync_service.dart';
import '../../../data/services/vehicle_service.dart';
import '../receipt/challan_receipt_screen.dart';

class IssueChallanScreen extends StatefulWidget {
  final VehicleModel? preselectedVehicle;
  final String? preselectedDriverName;
  final String? preselectedDlNumber;

  const IssueChallanScreen({
    super.key,
    this.preselectedVehicle,
    this.preselectedDriverName,
    this.preselectedDlNumber,
  });

  @override
  State<IssueChallanScreen> createState() => _IssueChallanScreenState();
}

class _IssueChallanScreenState extends State<IssueChallanScreen> {
  final ChallanService _challanService = ChallanService.instance;
  final VehicleService _vehicleService = VehicleService.instance;

  late VehicleModel _selectedVehicle;
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _dlController = TextEditingController();
  final TextEditingController _locationController =
      TextEditingController(text: 'Sector 4, MG Road Junction, New Delhi');
  final Set<String> _selectedOffenseIds = {'OFF-2'}; // Default Signal Jump
  bool _hasPhotoEvidence = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedVehicle = widget.preselectedVehicle ?? MockDataRepository.mockVehicles.first;
    _driverNameController.text =
        widget.preselectedDriverName ?? _selectedVehicle.ownerName;
    _dlController.text = widget.preselectedDlNumber ?? 'DL-0420190012345';
  }

  @override
  void dispose() {
    _driverNameController.dispose();
    _dlController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  double get _totalFine {
    final selectedOffenses = _challanService
        .getStandardOffenses()
        .where((o) => _selectedOffenseIds.contains(o.id))
        .toList();
    return _challanService.calculateTotalFine(selectedOffenses);
  }

  Future<void> _submitChallan() async {
    if (_selectedOffenseIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one statutory offense violation.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final selectedOffenses = _challanService
        .getStandardOffenses()
        .where((o) => _selectedOffenseIds.contains(o.id))
        .toList();

    final newChallan = ChallanModel(
      challanNumber: 'DL-ECH-2024-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      vehicleNumber: _selectedVehicle.registrationNumber,
      vehicleModel: _selectedVehicle.makeModel,
      driverName: _driverNameController.text.trim().isNotEmpty ? _driverNameController.text.trim() : null,
      dlNumber: _dlController.text.trim().isNotEmpty ? _dlController.text.trim() : null,
      issuedAt: DateTime.now(),
      location: _locationController.text.trim(),
      offenses: selectedOffenses,
      totalFine: _totalFine,
      isPaid: false,
      officerName: AuthService().currentInspector?.name ?? 'Insp. Rajesh Kumar',
      officerBadge: AuthService().currentInspector?.badgeNumber ?? 'TP-8429',
      latitude: 28.6139,
      longitude: 77.2090,
    );

    // If offline mode is active, also queue locally in offline sync service
    if (OfflineSyncService.instance.isOfflineMode) {
      await OfflineSyncService.instance.queueOfflineChallan(newChallan);
    }

    // Issue through Challan Service (which writes to repo, updates vehicle, and audits!)
    final issued = await _challanService.issueChallan(newChallan);

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChallanReceiptScreen(challan: issued),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ISSUE STATUTORY E-CHALLAN'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Offline Field Mode Warning Banner if active
            if (OfflineSyncService.instance.isOfflineMode) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.warningBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.warningBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_off_rounded, color: AppColors.warningText, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'OFFLINE FIELD MODE • Citation will be queued locally and synced when connection restores.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.warningText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Top Civic Law Notice
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.gavel_rounded, color: AppColors.accent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MOTOR VEHICLES ACT 2019',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.accent,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          'Direct Prosecution Notice Form',
                          style: AppTypography.headlineSmall.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 1. Vehicle Target Selector
            const SectionHeader(title: 'Target Vehicle', icon: Icons.directions_car_rounded),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PlateDisplayCard(
                        plateNumber: _selectedVehicle.registrationNumber,
                        isCompact: true,
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                        label: const Text('Change'),
                        onPressed: () {
                          _showVehicleSelectorSheet(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${_selectedVehicle.makeModel} • ${_selectedVehicle.color}',
                      style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Violator & Driver Details
            const SectionHeader(title: 'Driver / License Info', icon: Icons.badge_rounded),
            CustomTextField(
              controller: _driverNameController,
              labelText: 'DRIVER NAME',
              hintText: 'Full name as per DL',
              prefixIcon: Icons.person_rounded,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _dlController,
              labelText: 'DRIVING LICENSE NUMBER',
              hintText: 'e.g. DL-0420190012345',
              forceUppercase: true,
              prefixIcon: Icons.credit_card_rounded,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _locationController,
              labelText: 'OFFENSE LOCATION / INTERSECTION',
              prefixIcon: Icons.pin_drop_rounded,
            ),
            const SizedBox(height: 16),

            // 3. Photographic Evidence Attachment
            const SectionHeader(title: 'Photographic Evidence (Required)', icon: Icons.camera_alt_rounded),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderStrong),
                    ),
                    child: _hasPhotoEvidence
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(Icons.image_rounded, size: 36, color: AppColors.primary),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const Icon(Icons.add_a_photo_rounded, size: 28, color: AppColors.textMuted),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _hasPhotoEvidence ? 'Evidence Photo Attached' : 'No Photo Captured',
                          style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'GPS: 28.6139° N, 77.2090° E • Auto-stamped with time and Inspector ID.',
                          style: AppTypography.bodySmall.copyWith(fontSize: 11),
                        ),
                        const SizedBox(height: 6),
                        OutlinedButton(
                          onPressed: () {
                            setState(() => _hasPhotoEvidence = !_hasPhotoEvidence);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            minimumSize: Size.zero,
                          ),
                          child: Text(_hasPhotoEvidence ? 'Retake Photo' : 'Capture Photo'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. Violation Selection Checklist
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.checklist_rounded, size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Select Offenses',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.errorBg,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.errorBorder),
                  ),
                  child: Text(
                    '${_selectedOffenseIds.length} SELECTED',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.errorText,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: MockDataRepository.standardOffenses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final offense = MockDataRepository.standardOffenses[index];
                final isSelected = _selectedOffenseIds.contains(offense.id);

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedOffenseIds.remove(offense.id);
                        } else {
                          _selectedOffenseIds.add(offense.id);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.canvas : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 1.8 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isSelected,
                            activeColor: AppColors.primary,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedOffenseIds.add(offense.id);
                                } else {
                                  _selectedOffenseIds.remove(offense.id);
                                }
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  offense.title,
                                  style: AppTypography.labelLarge.copyWith(
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  offense.section,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₹${offense.statutoryFine.toStringAsFixed(0)}',
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w800,
                              color: isSelected ? AppColors.primary : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      // Sticky Real-Time Fine Calculator Bottom Bar
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(top: BorderSide(color: AppColors.border, width: 1.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL STATUTORY FINE',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '₹${_totalFine.toStringAsFixed(0)}',
                      style: AppTypography.headlineMedium.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: AppButton.primary(
                  text: 'Generate E-Challan',
                  icon: Icons.check_circle_outline_rounded,
                  isLoading: _isSubmitting,
                  onPressed: _selectedOffenseIds.isNotEmpty && !_isSubmitting ? _submitChallan : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVehicleSelectorSheet(BuildContext context) async {
    final vehicles = await _vehicleService.getAllVehicles();
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Target Vehicle for Challan',
                  style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ...vehicles.map((v) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: PlateDisplayCard(
                      plateNumber: v.registrationNumber,
                      isCompact: true,
                    ),
                    title: Text(v.makeModel, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('Owner: ${v.ownerName}'),
                    onTap: () {
                      setState(() {
                        _selectedVehicle = v;
                        _driverNameController.text = v.ownerName;
                      });
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
