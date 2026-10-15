import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../data/models/driver_license_model.dart';
import '../../../data/services/vehicle_service.dart';
import '../../../data/services/driving_license_service.dart';
import '../vehicle/vehicle_details_screen.dart';
import '../challan/issue_challan_screen.dart';
import '../scanner/anpr_scanner_screen.dart';

class VehicleSearchScreen extends StatefulWidget {
  final String? initialQuery;

  const VehicleSearchScreen({super.key, this.initialQuery});

  @override
  State<VehicleSearchScreen> createState() => _VehicleSearchScreenState();
}

class _VehicleSearchScreenState extends State<VehicleSearchScreen> with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final TabController _tabController;

  final VehicleService _vehicleService = VehicleService.instance;
  final DrivingLicenseService _dlService = DrivingLicenseService.instance;

  List<VehicleModel> _filteredVehicles = [];
  List<DriverLicenseModel> _filteredLicenses = [];
  VehicleType? _selectedTypeFilter;
  bool _hasSearched = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);

    _loadInitialData();

    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _performSearch(widget.initialQuery!);
    }
  }

  void _loadInitialData() async {
    final vehicles = await _vehicleService.getAllVehicles();
    final licenses = await _dlService.getAllLicenses();
    if (mounted) {
      setState(() {
        _filteredVehicles = vehicles;
        _filteredLicenses = licenses;
      });
    }
  }

  void _handleTabChange() {
    setState(() {});
    if (!_tabController.indexIsChanging) {
      _performSearch(_controller.text);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  bool get _isLicenseTab => _tabController.index == 3;

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _hasSearched = query.trim().isNotEmpty;
    });

    final q = query.trim();

    if (_isLicenseTab) {
      if (q.isEmpty) {
        final all = await _dlService.getAllLicenses();
        if (mounted) {
          setState(() {
            _filteredLicenses = all;
            _isLoading = false;
          });
        }
      } else {
        final match = await _dlService.searchByLicenseNumber(q);
        List<DriverLicenseModel> results;
        if (match != null) {
          results = [match];
        } else {
          // Loose name search fallback across mock licenses
          final rawUpper = q.toUpperCase();
          final all = await _dlService.getAllLicenses();
          results = all
              .where((l) =>
                  l.holderName.toUpperCase().contains(rawUpper) ||
                  l.dlNumber
                      .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
                      .contains(
                        q.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase(),
                      ))
              .toList();
        }
        if (mounted) {
          setState(() {
            _filteredLicenses = results;
            _isLoading = false;
          });
        }
      }
    } else {
      // Vehicle searches (Reg, Chassis, Engine)
      if (q.isEmpty) {
        var vehicles = await _vehicleService.getAllVehicles();
        if (_selectedTypeFilter != null) {
          vehicles = vehicles.where((v) => v.type == _selectedTypeFilter).toList();
        }
        if (mounted) {
          setState(() {
            _filteredVehicles = vehicles;
            _isLoading = false;
          });
        }
      } else {
        List<VehicleModel> results = [];
        switch (_tabController.index) {
          case 0: // Reg No
            final match = await _vehicleService.searchByRegistration(q);
            if (match != null) {
              results = [match];
            } else {
              results = await _vehicleService.searchGeneral(q, typeFilter: _selectedTypeFilter);
            }
            break;
          case 1: // Chassis
            final match = await _vehicleService.searchByChassis(q);
            if (match != null) {
              results = [match];
            } else {
              results = await _vehicleService.searchGeneral(q, typeFilter: _selectedTypeFilter);
            }
            break;
          case 2: // Engine
            final match = await _vehicleService.searchByEngine(q);
            if (match != null) {
              results = [match];
            } else {
              results = await _vehicleService.searchGeneral(q, typeFilter: _selectedTypeFilter);
            }
            break;
        }

        if (_selectedTypeFilter != null) {
          results = results.where((v) => v.type == _selectedTypeFilter).toList();
        }

        if (mounted) {
          setState(() {
            _filteredVehicles = results;
            _isLoading = false;
          });
        }
      }
    }
  }

  void _selectQuickChip(String value) {
    _controller.text = value;
    _performSearch(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VAHAN VEHICLE & DL SEARCH'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => _performSearch(_controller.text),
          indicatorColor: AppColors.accent,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: AppTypography.labelMedium,
          tabs: const [
            Tab(text: 'Reg. No'),
            Tab(text: 'Chassis'),
            Tab(text: 'Engine'),
            Tab(text: 'License'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input with OCR camera button
            CustomTextField(
              controller: _controller,
              hintText: _getHintText(),
              forceUppercase: true,
              prefixIcon: Icons.search_rounded,
              onChanged: _performSearch,
              onSubmitted: _performSearch,
              onCameraScan: () {
                if (_isLicenseTab) {
                  _selectQuickChip('DL-0420190012345');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Scanned DL-0420190012345 from license barcode!')),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AnprScannerScreen()),
                  );
                }
              },
            ),
            const SizedBox(height: 12),

            // Quick Samples Chips
            Row(
              children: [
                const Icon(Icons.flash_on_rounded, size: 16, color: AppColors.accent),
                const SizedBox(width: 4),
                Text(
                  _isLicenseTab ? 'Quick DL Samples (Mock RTO):' : 'Quick Samples (Mock Database):',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _isLicenseTab
                    ? [
                        _buildQuickChip('DL-0420190012345', 'Valid', Colors.green),
                        _buildQuickChip('MH-1220180099412', 'Valid', Colors.blue),
                        _buildQuickChip('HR-5520140023411', 'Suspended', Colors.red),
                        _buildQuickChip('KA-0320150045678', 'Commercial', Colors.teal),
                      ]
                    : [
                        _buildQuickChip('DL 01 CA 8821', 'Car (Creta)', Colors.blue),
                        _buildQuickChip('MH 12 CD 5678', 'Bike (Bullet)', Colors.orange),
                        _buildQuickChip('HR 55 TR 9012', 'Truck (Stolen Alert)', Colors.red),
                        _buildQuickChip('KA 03 BS 4321', 'Bus (Commercial)', Colors.green),
                        _buildQuickChip('UP 32 TC 7890', 'Tractor (Agri)', Colors.purple),
                      ],
              ),
            ),
            const SizedBox(height: 16),

            // Vehicle Category Filter Chips (Only on Vehicle Tabs)
            if (!_isLicenseTab) ...[
              Row(
                children: [
                  Text(
                    'Filter Class:',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('All'),
                            selected: _selectedTypeFilter == null,
                            onSelected: (_) {
                              setState(() {
                                _selectedTypeFilter = null;
                                _performSearch(_controller.text);
                              });
                            },
                          ),
                          const SizedBox(width: 6),
                          ...VehicleType.values.map((type) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: FilterChip(
                                label: Text(type.name.toUpperCase()),
                                selected: _selectedTypeFilter == type,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedTypeFilter = selected ? type : null;
                                    _performSearch(_controller.text);
                                  });
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // Search Results Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isLicenseTab
                      ? 'DL Records (${_filteredLicenses.length})'
                      : 'Results (${_filteredVehicles.length})',
                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                ),
                if (_hasSearched)
                  TextButton(
                    onPressed: () {
                      _controller.clear();
                      _performSearch('');
                    },
                    child: const Text('Reset'),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_isLicenseTab)
              _buildLicenseList()
            else
              _buildVehicleList(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleList() {
    if (_filteredVehicles.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              'No matching vehicle found',
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Check registration number spelling or try searching via Chassis / Engine number.',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredVehicles.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final vehicle = _filteredVehicles[index];
        return _buildVehicleResultCard(vehicle);
      },
    );
  }

  Widget _buildLicenseList() {
    if (_filteredLicenses.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Icon(Icons.badge_outlined, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              'No driver license record found',
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Check DL number format (e.g. DL-0420190012345) or scan card barcode.',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredLicenses.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final license = _filteredLicenses[index];
        return _buildLicenseResultCard(license);
      },
    );
  }

  Widget _buildLicenseResultCard(DriverLicenseModel license) {
    final dateFormat = DateFormat('dd-MMM-yyyy');
    final isSuspended = license.isSuspended;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSuspended ? AppColors.error : AppColors.border,
          width: isSuspended ? 1.5 : 1,
        ),
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
        children: [
          if (isSuspended) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.errorBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.errorBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.block_rounded, color: AppColors.error, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      license.suspensionReason ?? 'LICENSE SUSPENDED BY TRANSPORT AUTHORITY',
                      style: const TextStyle(
                        color: AppColors.errorText,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.borderStrong),
                ),
                child: Text(
                  license.dlNumber,
                  style: AppTypography.labelLarge.copyWith(
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.primary,
                  ),
                ),
              ),
              StatusBadge(
                label: isSuspended ? 'SUSPENDED' : 'VALID DL',
                status: isSuspended ? BadgeStatus.expired : BadgeStatus.valid,
                isCompact: true,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            license.holderName,
            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            'S/D/W of: ${license.fatherName} • Blood Group: ${license.bloodGroup}',
            style: AppTypography.bodySmall,
          ),
          Text(
            'Valid till: ${dateFormat.format(license.validUpto)} • Address: ${license.address}',
            style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),

          // Authorized Classes & Penalty Points
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    Text(
                      'Class:',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                    ),
                    ...license.authorizedClasses.map((cls) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.canvas,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          cls,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: license.activePenaltyPoints >= 10
                      ? AppColors.errorBg
                      : AppColors.accentContainer,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: license.activePenaltyPoints >= 10
                        ? AppColors.errorBorder
                        : AppColors.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '${license.activePenaltyPoints} Penalty Points',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: license.activePenaltyPoints >= 10
                        ? AppColors.errorText
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Action Button
          AppButton.primary(
            text: 'Issue Challan for Driver',
            icon: Icons.receipt_rounded,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => IssueChallanScreen(
                    preselectedDriverName: license.holderName,
                    preselectedDlNumber: license.dlNumber,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getHintText() {
    switch (_tabController.index) {
      case 0:
        return 'e.g. DL 01 CA 8821 or MH 12 CD 5678';
      case 1:
        return 'e.g. MALC181CLPM109283';
      case 2:
        return 'e.g. D4FA109283';
      case 3:
        return 'e.g. DL-0420190012345 or balwinder';
      default:
        return 'Enter search query';
    }
  }

  Widget _buildQuickChip(String plate, String label, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
        ),
        label: Text('$plate ($label)'),
        labelStyle: AppTypography.labelSmall.copyWith(fontSize: 11),
        onPressed: () => _selectQuickChip(plate),
      ),
    );
  }

  Widget _buildVehicleResultCard(VehicleModel vehicle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: vehicle.isStolen ? AppColors.error : AppColors.border,
          width: vehicle.isStolen ? 1.5 : 1,
        ),
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
        children: [
          if (vehicle.isStolen) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.errorBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.errorBorder),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_rounded, color: AppColors.error, size: 16),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'STOLEN VEHICLE ALERT • DETENTION REQUIRED',
                      style: TextStyle(
                        color: AppColors.errorText,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PlateDisplayCard(
                plateNumber: vehicle.registrationNumber,
                isCompact: true,
              ),
              StatusBadge(
                label: vehicle.type.displayName.split(' ').first,
                status: BadgeStatus.neutral,
                isCompact: true,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            vehicle.makeModel,
            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            'Owner: ${vehicle.ownerName} • ${vehicle.registrationAuthority}',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: vehicle.documents.map((doc) {
              return StatusBadge(
                label: '${doc.title.split(' ').first}: ${doc.status.name.toUpperCase()}',
                status: doc.status,
                isCompact: true,
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AppButton.secondary(
                  text: 'View Details',
                  icon: Icons.info_outline_rounded,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VehicleDetailsScreen(vehicle: vehicle),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton.primary(
                  text: 'Issue Challan',
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}
