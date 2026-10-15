import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/challan_model.dart';
import '../../../data/services/challan_service.dart';

class ChallanReceiptScreen extends StatefulWidget {
  final ChallanModel challan;

  const ChallanReceiptScreen({super.key, required this.challan});

  @override
  State<ChallanReceiptScreen> createState() => _ChallanReceiptScreenState();
}

class _ChallanReceiptScreenState extends State<ChallanReceiptScreen> {
  final ChallanService _challanService = ChallanService.instance;
  late bool _isPaid;
  String? _transactionId;

  @override
  void initState() {
    super.initState();
    _isPaid = widget.challan.isPaid;
    _transactionId = widget.challan.transactionId;
  }

  Future<void> _markAsPaid() async {
    final txn = 'CASH-REC-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    try {
      await _challanService.markChallanPaid(
        widget.challan.challanNumber,
        paymentMode: 'Cash / Handheld POS Terminal',
        transactionId: txn,
      );
      if (mounted) {
        setState(() {
          _isPaid = true;
          _transactionId = txn;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text('Payment marked successfully! Statutory receipt and audit log updated.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Error settling payment: $e'),
          ),
        );
      }
    }
  }

  void _shareViaWhatsApp() {
    final text = '''
*DELHI TRAFFIC POLICE — E-CHALLAN NOTICE*
Challan No: ${widget.challan.challanNumber}
Vehicle No: ${widget.challan.vehicleNumber}
Total Fine: ₹${widget.challan.totalFine.toStringAsFixed(0)}
Status: ${_isPaid ? 'PAID' : 'UNPAID'}
Pay Online: https://echallan.parivahan.gov.in/
Virtual Court Notice: Pay within 15 days to avoid summons.
''';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('WhatsApp receipt summary copied to clipboard!')),
    );
  }

  void _simulatePrint() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.primary,
        content: Text('Sending 58mm thermal print command to paired Bluetooth printer...'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd-MMM-yyyy • hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-CHALLAN RECEIPT SLIP'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_rounded),
            tooltip: 'Print Thermal Receipt',
            onPressed: _simulatePrint,
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share',
            onPressed: _shareViaWhatsApp,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Thermal Receipt Container with official decorative styling
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Official Government Header Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.local_police_rounded, color: AppColors.accent, size: 36),
                        const SizedBox(height: 6),
                        Text(
                          'GOVERNMENT OF NCT OF DELHI',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white70,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          'DELHI TRAFFIC POLICE',
                          style: AppTypography.headlineMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'E-Challan Official Summary Slip (MVA 2019)',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Challan Number & Copy button
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.canvas,
                            borderRadius: BorderRadius.circular(8),
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
                                      'CHALLAN REFERENCE NUMBER',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 10,
                                      ),
                                    ),
                                    Text(
                                      widget.challan.challanNumber,
                                      style: AppTypography.labelLarge.copyWith(
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy_rounded, size: 18),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: widget.challan.challanNumber));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Challan number copied!')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Payment Status Pill
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _isPaid ? AppColors.successBg : AppColors.errorBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _isPaid ? AppColors.successBorder : AppColors.errorBorder,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isPaid ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                                color: _isPaid ? AppColors.success : AppColors.error,
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isPaid ? 'PAYMENT STATUS: SETTLED (PAID)' : 'PAYMENT STATUS: UNPAID (PENDING)',
                                      style: AppTypography.labelMedium.copyWith(
                                        color: _isPaid ? AppColors.successText : AppColors.errorText,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      _isPaid
                                          ? 'Txn: ${_transactionId ?? 'Verified via Gateway'}'
                                          : 'Statutory deadline: 15 days • Virtual Court forwarding thereafter',
                                      style: AppTypography.bodySmall.copyWith(
                                        fontSize: 11,
                                        color: _isPaid ? AppColors.successText : AppColors.errorText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Target Vehicle HSRP Plate
                        PlateDisplayCard(
                          plateNumber: widget.challan.vehicleNumber,
                          subtitle: widget.challan.vehicleModel,
                        ),
                        const SizedBox(height: 16),

                        // Details Breakdown
                        _buildReceiptRow('Date & Time', dateFormat.format(widget.challan.issuedAt)),
                        _buildReceiptRow('Location', widget.challan.location),
                        if (widget.challan.driverName != null)
                          _buildReceiptRow('Violator / Driver', widget.challan.driverName!),
                        if (widget.challan.dlNumber != null)
                          _buildReceiptRow('Driver License', widget.challan.dlNumber!),
                        _buildReceiptRow('Issuing Officer', '${widget.challan.officerName} (${widget.challan.officerBadge})'),
                        const Divider(height: 24),

                        // Violation List
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'STATUTORY OFFENSES (MVA 2019)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...widget.challan.offenses.map((offense) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        offense.title,
                                        style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        offense.section,
                                        style: AppTypography.bodySmall.copyWith(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '₹${offense.statutoryFine.toStringAsFixed(0)}',
                                  style: AppTypography.labelMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const Divider(height: 24),

                        // Total Fine
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TOTAL FINE PAYABLE',
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              '₹${widget.challan.totalFine.toStringAsFixed(0)}',
                              style: AppTypography.headlineMedium.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Live UPI Payment QR Code Section (if unpaid)
                        if (!_isPaid) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.canvas,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.qr_code_scanner_rounded, size: 20, color: AppColors.accent),
                                        const SizedBox(width: 6),
                                        Text(
                                          'SCAN TO PAY VIA UPI',
                                          style: AppTypography.labelSmall.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentContainer,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: const Text(
                                        'Bharat QR',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.warningText,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Driver can scan with any UPI App to clear challan immediately. Digital NOC issued automatically.',
                                  style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                // QR View
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.04),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: QrImageView(
                                    data: widget.challan.upiPaymentUrl,
                                    version: QrVersions.auto,
                                    size: 160.0,
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'VPA: echallan.delhitp@sbi',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Courier',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Supported UPI Apps Badges Row
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  alignment: WrapAlignment.center,
                                  children: ['GPay', 'PhonePe', 'Paytm', 'BHIM UPI', 'NetBanking'].map((app) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: AppColors.border),
                                      ),
                                      child: Text(
                                        app,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Thermal Printer Connected Status Bar (Stitch)
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
                      Icon(Icons.bluetooth_connected_rounded, size: 20, color: AppColors.success),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NGX BlueStallion 58mm',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          Text(
                            'Connected • Battery 82%',
                            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.successBg,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.successBorder),
                    ),
                    child: const Text(
                      'READY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.successText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            if (!_isPaid)
              AppButton.accent(
                text: 'Mark Paid In Cash / POS Terminal',
                icon: Icons.payments_rounded,
                onPressed: _markAsPaid,
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: AppButton.secondary(
                    text: 'WhatsApp',
                    icon: Icons.chat_rounded,
                    onPressed: _shareViaWhatsApp,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton.primary(
                    text: 'Print Slip',
                    icon: Icons.print_rounded,
                    onPressed: _simulatePrint,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
