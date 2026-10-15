import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/plate_scan_result.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../data/services/ocr_service.dart';
import '../vehicle/vehicle_details_screen.dart';

/// Screen representing the on-field ANPR (Automatic Number Plate Recognition) Camera Scanner.
/// Features live viewfinder targeting, optical laser animation, HSRP parsing, OCR correction,
/// and instant VAHAN vehicle lookup.
class AnprScannerScreen extends StatefulWidget {
  final String? initialPlate;
  final bool enableAnimation;

  const AnprScannerScreen({
    super.key,
    this.initialPlate,
    this.enableAnimation = true,
  });

  @override
  State<AnprScannerScreen> createState() => _AnprScannerScreenState();
}

class _AnprScannerScreenState extends State<AnprScannerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _laserController;
  late Animation<double> _laserAnimation;

  final ImagePicker _picker = ImagePicker();

  bool _isTorchOn = false;
  String _selectedZoom = '1x';
  String _scannerMode = 'plate'; // 'plate' or 'chassis'
  bool _autoSearchOnHighConfidence = true;

  PlateScanResult? _scanResult;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    // Laser scanning bar animation
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    if (widget.enableAnimation) {
      _laserController.repeat(reverse: true);
    }

    _laserAnimation = Tween<double>(begin: 0.1, end: 0.9).animate(
      CurvedAnimation(parent: _laserController, curve: Curves.easeInOut),
    );

    // Initial plate processing
    final initial = widget.initialPlate ?? 'DL 01 CA 8821';
    _processText(initial);
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  void _processText(String rawText) {
    setState(() => _isProcessing = true);
    final result = OcrService.instance.parseRawOcrText(rawText);
    setState(() {
      _scanResult = result;
      _isProcessing = false;
    });
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _isProcessing = true);
        final result = await OcrService.instance.processImage(image.path);
        setState(() {
          _scanResult = result;
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gallery pick: $e')),
      );
    }
  }

  void _showManualEditDialog() {
    final currentPlate = _scanResult?.detectedPlate ?? 'DL 01 CA 8821';
    final controller = TextEditingController(text: currentPlate);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.edit_note, color: AppColors.navyPrimary, size: 28),
                        const SizedBox(width: 8),
                        Text('Manual Plate Entry', style: AppTypography.heading2),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Correct misread alphanumeric characters according to the vehicle\'s physical embossed registration plate.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.slateNeutral),
                ),
                const SizedBox(height: 16),
                Text(
                  'REGISTRATION NUMBER',
                  style: AppTypography.label.copyWith(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.characters,
                  style: AppTypography.licensePlate.copyWith(fontSize: 22, color: AppColors.navyPrimary),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.backspace_outlined, size: 20),
                      onPressed: () => controller.clear(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navyPrimary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          final text = controller.text.trim();
                          if (text.isNotEmpty) {
                            _processText(text);
                          }
                          Navigator.pop(ctx);
                        },
                        child: const Text('Apply & Verify'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPlateGuide() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.navyPrimary),
                  const SizedBox(width: 8),
                  Text('Indian HSRP Standards', style: AppTypography.heading2),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'High Security Registration Plates (HSRP) feature:\n'
                '• Blue "IND" badge on the left edge with Chromium Ashoka Chakra.\n'
                '• 2-letter state code (e.g. DL, HR, MH, KA, UP).\n'
                '• 2-digit district RTO code (e.g. 01, 26, 55).\n'
                '• 1-3 letter series code followed by unique 4-digit sequence.\n'
                '• Laser hot-stamped 10-digit PIN beneath the IND monogram.',
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navyPrimary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Understood'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToVehicleDetails() {
    final vehicle = _scanResult?.matchedVehicle;
    if (vehicle != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VehicleDetailsScreen(vehicle: vehicle),
        ),
      );
    } else {
      // Create ad-hoc vehicle if not found in mock database
      final plate = _scanResult?.detectedPlate ?? 'DL 01 CA 8821';
      final fallbackVehicle = VehicleModel(
        registrationNumber: plate,
        chassisNumber: 'MA1TA2D00M678821',
        engineNumber: 'G4LAJ128821',
        type: VehicleType.car,
        makeModel: 'Hyundai Creta 1.5 SX',
        ownerName: 'Vikas Sharma',
        ownerPhone: '+91 98110 55219',
        color: 'Polar White',
        fuelType: 'Petrol',
        emissionNorms: 'BS-VI',
        registrationAuthority: 'DL-01 (Delhi North RTO, Mall Road)',
        registrationDate: DateTime(2021, 3, 12),
        documents: const [],
        pendingChallanCount: 0,
        pendingChallanAmount: 0.0,
        isStolen: false,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VehicleDetailsScreen(vehicle: fallbackVehicle),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _scanResult;
    final plateNumber = result?.detectedPlate ?? 'DL 01 CA 8821';
    final stateName = result?.stateName ?? 'Delhi State';
    final matchedVehicle = result?.matchedVehicle;
    final isStolen = result?.isStolenAlert ?? false;

    return Scaffold(
      backgroundColor: AppColors.navyPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar matching Stitch design
            _buildTopAppBar(),

            // Main Viewport & Bottom Sheet
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Viewfinder Hero Section
                    _buildViewfinderHero(),

                    // Quick Sample Plate Switcher (for immediate field testing)
                    _buildSamplePlatesBar(),

                    // Bottom Recognition Sheet
                    _buildRecognitionSheet(
                      plateNumber: plateNumber,
                      stateName: stateName,
                      matchedVehicle: matchedVehicle,
                      isStolen: isStolen,
                      confidence: result?.confidence ?? 0.984,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.navyPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.local_police, color: AppColors.navyPrimary, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TRAFFIC DEPT',
                  style: AppTypography.label.copyWith(
                    color: AppColors.saffronCaution,
                    letterSpacing: 1.2,
                    fontSize: 10,
                  ),
                ),
                Text(
                  'ANPR Scanner',
                  style: AppTypography.heading3.copyWith(fontSize: 17),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Torch toggle
          IconButton(
            icon: Icon(
              _isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: _isTorchOn ? AppColors.saffronCaution : AppColors.slateNeutral,
            ),
            onPressed: () {
              setState(() => _isTorchOn = !_isTorchOn);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(milliseconds: 900),
                  content: Text(_isTorchOn ? 'Camera Torch Activated' : 'Camera Torch Deactivated'),
                ),
              );
            },
          ),
          // Guide / Settings
          IconButton(
            icon: const Icon(Icons.tune, color: AppColors.navyPrimary),
            onPressed: _showPlateGuide,
          ),
        ],
      ),
    );
  }

  Widget _buildViewfinderHero() {
    return Container(
      height: 380,
      width: double.infinity,
      color: const Color(0xFF071836),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background camera viewport grid simulation
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.1,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ),

          // Live Telemetry / FPS Watermark
          Positioned(
            top: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.validEmerald,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '30 FPS • 4K OCR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Mode Switcher Pills (Top Floating)
          Positioned(
            top: 14,
            left: 14,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _scannerMode = 'plate'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _scannerMode == 'plate' ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.pin,
                            size: 14,
                            color: _scannerMode == 'plate' ? AppColors.navyPrimary : Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ANPR Plate',
                            style: TextStyle(
                              color: _scannerMode == 'plate' ? AppColors.navyPrimary : Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _scannerMode = 'chassis'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _scannerMode == 'chassis' ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            size: 14,
                            color: _scannerMode == 'chassis' ? AppColors.navyPrimary : Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Chassis / QR',
                            style: TextStyle(
                              color: _scannerMode == 'chassis' ? AppColors.navyPrimary : Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Central Alignment Target Box
          _buildCenterReticleBox(),

          // Quick Camera Vertical Controls (Right spine)
          Positioned(
            right: 14,
            bottom: 16,
            child: Column(
              children: [
                _buildCircleActionButton(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: _pickImageFromGallery,
                ),
                const SizedBox(height: 10),
                _buildCircleActionButton(
                  icon: Icons.refresh,
                  label: 'Rescan',
                  onTap: () => _processText('DL 01 CA 8821'),
                ),
              ],
            ),
          ),

          // Zoom Switcher (Left bottom dock)
          Positioned(
            left: 14,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: ['1x', '2x', '3x'].map((zoom) {
                  final isSelected = _selectedZoom == zoom;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedZoom = zoom),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        zoom,
                        style: TextStyle(
                          color: isSelected ? AppColors.navyPrimary : Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white30),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildCenterReticleBox() {
    return SizedBox(
      width: 290,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 4 Glowing Corner Brackets
          _buildCorner(top: 0, left: 0, isTop: true, isLeft: true),
          _buildCorner(top: 0, right: 0, isTop: true, isLeft: false),
          _buildCorner(bottom: 0, left: 0, isTop: false, isLeft: true),
          _buildCorner(bottom: 0, right: 0, isTop: false, isLeft: false),

          // Animated Laser Scan Bar
          AnimatedBuilder(
            animation: _laserAnimation,
            builder: (context, child) {
              return Positioned(
                top: 120 * _laserAnimation.value,
                left: 10,
                right: 10,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.saffronCaution,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.saffronCaution.withValues(alpha: 0.9),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Crosshair Center
          SizedBox(
            width: 16,
            height: 16,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(width: 16, height: 1, color: Colors.white38),
                Container(width: 1, height: 16, color: Colors.white38),
              ],
            ),
          ),

          // Top Alignment Guidance
          Positioned(
            top: -30,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.navyPrimary.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.center_focus_strong, color: AppColors.saffronCaution, size: 14),
                  const SizedBox(width: 5),
                  const Text(
                    'Align HSRP plate within frame',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Optical Confidence Metric
          Positioned(
            bottom: -28,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF003320),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.validEmerald),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified, color: AppColors.validEmerald, size: 14),
                  const SizedBox(width: 5),
                  Text(
                    '${((_scanResult?.confidence ?? 0.984) * 100).toStringAsFixed(1)}% Optical Confidence',
                    style: const TextStyle(
                      color: AppColors.validEmerald,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required bool isTop,
    required bool isLeft,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: SizedBox(
        width: 24,
        height: 24,
        child: Stack(
          children: [
            Positioned(
              top: isTop ? 0 : null,
              bottom: isTop ? null : 0,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.saffronCaution,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.saffronCaution.withValues(alpha: 0.6),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: isLeft ? 0 : null,
              right: isLeft ? null : 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  color: AppColors.saffronCaution,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.saffronCaution.withValues(alpha: 0.6),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSamplePlatesBar() {
    final samples = [
      {'name': 'Creta', 'plate': 'DL 01 CA 8821'},
      {'name': 'Bullet', 'plate': 'HR 26 DQ 5541'},
      {'name': 'Stolen Truck (Alert!)', 'plate': 'HR 55 TR 9012'},
      {'name': 'Bus', 'plate': 'MH 12 DE 1433'},
      {'name': 'Tractor', 'plate': 'PB 08 BG 3322'},
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TEST SAMPLES (ONE-TAP FIELD VERIFICATION)',
                style: AppTypography.label.copyWith(fontSize: 10, color: AppColors.slateNeutral),
              ),
              if (_isProcessing)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: samples.map((sample) {
                final isCurrent = _scanResult?.detectedPlate == sample['plate'];
                final isStolenSample = sample['plate'] == 'HR 55 TR 9012';

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(sample['name']!),
                    selected: isCurrent,
                    selectedColor: isStolenSample
                        ? AppColors.crimsonAlert.withValues(alpha: 0.15)
                        : AppColors.navyPrimary.withValues(alpha: 0.1),
                    backgroundColor: AppColors.surfaceLight,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isStolenSample
                          ? AppColors.crimsonAlert
                          : (isCurrent ? AppColors.navyPrimary : AppColors.slateNeutral),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        _processText(sample['plate']!);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecognitionSheet({
    required String plateNumber,
    required String stateName,
    required VehicleModel? matchedVehicle,
    required bool isStolen,
    required double confidence,
  }) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tactile Handle Bar
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Status & VAHAN Ready Micro-bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD1FAE5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 16, color: AppColors.validEmerald),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Plate Recognized',
                        style: AppTypography.heading3.copyWith(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.validEmerald,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'VAHAN Match Ready',
                      style: AppTypography.label.copyWith(
                        fontSize: 11,
                        color: AppColors.navyPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // High-Security Registration Plate (HSRP) Visual Card
          _buildHsrpPlateCard(plateNumber, stateName),
          const SizedBox(height: 12),

          // Stolen vehicle BOLO alert banner if flagged
          if (isStolen)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.crimsonAlert.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.crimsonAlert),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: AppColors.crimsonAlert, size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STOLEN VEHICLE / BOLO ALERT!',
                          style: AppTypography.heading3.copyWith(
                            color: AppColors.crimsonAlert,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          matchedVehicle?.stolenFirDetails ?? 'FIR #441/24 • Hauz Khas PS • Reported: 12-May-2024. Detain driver and impound vehicle immediately.',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.crimsonAlert),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Quick Vehicle Hint Snippet
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    matchedVehicle?.vehicleClass == 'Two-Wheeler'
                        ? Icons.two_wheeler
                        : (matchedVehicle?.vehicleClass.contains('Truck') == true
                            ? Icons.local_shipping
                            : Icons.directions_car),
                    color: AppColors.navyPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        matchedVehicle?.makeModel ?? 'Hyundai Creta 1.5 SX',
                        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${matchedVehicle?.color ?? "Polar White"} • ${matchedVehicle?.vehicleClass ?? "Private LMV"} • ${matchedVehicle?.rtoOffice ?? "Delhi RTO"}',
                        style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.slateNeutral),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isStolen ? AppColors.crimsonAlert : AppColors.validEmerald,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isStolen ? 'ALERT' : 'ACTIVE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Action Controls: Edit & Search VAHAN
          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceLight,
                  foregroundColor: AppColors.navyPrimary,
                  elevation: 0,
                  minimumSize: const Size(96, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _showManualEditDialog,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navyPrimary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _navigateToVehicleDetails,
                  icon: const Icon(Icons.search, size: 20),
                  label: const Text(
                    'Search VAHAN',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Auto-search toggle & Plate guide
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Switch(
                      value: _autoSearchOnHighConfidence,
                      activeThumbColor: AppColors.navyPrimary,
                      onChanged: (val) => setState(() => _autoSearchOnHighConfidence = val),
                    ),
                    Flexible(
                      child: Text(
                        'Auto-search on > 95%',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.slateNeutral),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: _showPlateGuide,
                icon: const Icon(Icons.help_outline, size: 16, color: AppColors.saffronCaution),
                label: const Text(
                  'Plate Guide',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.saffronCaution,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHsrpPlateCard(String plateNumber, String stateName) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // Blue IND strip on left
            Container(
              width: 44,
              height: 72,
              color: const Color(0xFF002B7F),
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Ashoka Chakra symbol simulation
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.saffronCaution, width: 1.5),
                    ),
                    child: Center(
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppColors.saffronCaution,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'IND',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Number plate embossed text & State
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'HSRP 09',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        Text(
                          '${stateName.replaceAll(RegExp(r'\s+State$', caseSensitive: false), '')} State'.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plateNumber,
                      style: AppTypography.licensePlate.copyWith(
                        fontSize: 24,
                        color: Colors.black,
                        letterSpacing: 2.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Speaker Button simulation
            IconButton(
              icon: const Icon(Icons.volume_up, color: AppColors.navyPrimary, size: 22),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(milliseconds: 1200),
                    content: Text('Audio verification: "$plateNumber"'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
