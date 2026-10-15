import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import 'dart:async';
import '../../../data/models/challan_model.dart';
import '../../../data/services/challan_service.dart';
import '../receipt/challan_receipt_screen.dart';

class ChallanHistoryScreen extends StatefulWidget {
  const ChallanHistoryScreen({super.key});

  @override
  State<ChallanHistoryScreen> createState() => _ChallanHistoryScreenState();
}

class _ChallanHistoryScreenState extends State<ChallanHistoryScreen> {
  final ChallanService _challanService = ChallanService.instance;
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription? _subscription;
  int _selectedFilterIndex = 0; // 0: All, 1: Unpaid, 2: Paid
  List<ChallanModel> _allChallans = [];

  @override
  void initState() {
    super.initState();
    _loadChallans();
    _subscription = _challanService.challansStream.listen((list) {
      if (mounted) {
        setState(() => _allChallans = list);
      }
    });
  }

  Future<void> _loadChallans() async {
    final list = await _challanService.getAllChallans();
    if (mounted) {
      setState(() => _allChallans = list);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  List<ChallanModel> get _filteredChallans {
    final query = _searchController.text.trim().toUpperCase();
    return _allChallans.where((c) {
      final matchesQuery = query.isEmpty ||
          c.challanNumber.contains(query) ||
          c.vehicleNumber.replaceAll(' ', '').contains(query.replaceAll(' ', '')) ||
          (c.driverName?.toUpperCase().contains(query) ?? false);

      if (!matchesQuery) return false;

      if (_selectedFilterIndex == 1) return !c.isPaid;
      if (_selectedFilterIndex == 2) return c.isPaid;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd-MMM-yyyy • hh:mm a');

    final totalChallans = _allChallans.length;
    final paidChallans = _allChallans.where((c) => c.isPaid).length;
    final totalRevenue = _allChallans
        .where((c) => c.isPaid)
        .fold<double>(0.0, (acc, c) => acc + c.totalFine);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CHALLAN DISPATCH & AUDIT LOG'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Performance Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL CITATIONS',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.accent,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        '$totalChallans Records',
                        style: AppTypography.headlineSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 36,
                    width: 1,
                    color: Colors.white24,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SETTLED REVENUE',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.accent,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        '₹${totalRevenue.toStringAsFixed(0)}',
                        style: AppTypography.headlineSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 36,
                    width: 1,
                    color: Colors.white24,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PAID RATE',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.accent,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        totalChallans > 0 ? '${((paidChallans / totalChallans) * 100).toStringAsFixed(0)}%' : '0%',
                        style: AppTypography.headlineSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Search Filter Bar
            CustomTextField(
              controller: _searchController,
              hintText: 'Search by Challan No or Plate...',
              prefixIcon: Icons.search_rounded,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // Filter Tabs
            Row(
              children: [
                _buildFilterChip('All Citations', 0),
                const SizedBox(width: 8),
                _buildFilterChip('Unpaid (Pending)', 1),
                const SizedBox(width: 8),
                _buildFilterChip('Settled (Paid)', 2),
              ],
            ),
            const SizedBox(height: 16),

            // Challans List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Citations Log (${_filteredChallans.length})',
                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  'NIC Sync: Real-Time',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.successText, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (_filteredChallans.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.textMuted),
                    SizedBox(height: 12),
                    Text('No citations found for selected filter', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ] else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredChallans.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final challan = _filteredChallans[index];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChallanReceiptScreen(challan: challan),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                PlateDisplayCard(
                                  plateNumber: challan.vehicleNumber,
                                  isCompact: true,
                                ),
                                StatusBadge(
                                  label: challan.isPaid ? 'PAID' : 'PENDING',
                                  status: challan.isPaid ? BadgeStatus.valid : BadgeStatus.expired,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              challan.offenses.map((o) => o.title).join(' • '),
                              style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${challan.challanNumber} • ${dateFormat.format(challan.issuedAt)}',
                              style: AppTypography.bodySmall.copyWith(fontSize: 11),
                            ),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Officer: ${challan.officerName}',
                                  style: AppTypography.bodySmall.copyWith(fontSize: 11),
                                ),
                                Text(
                                  '₹${challan.totalFine.toStringAsFixed(0)}',
                                  style: AppTypography.headlineSmall.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: challan.isPaid ? AppColors.successText : AppColors.error,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilterIndex == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() => _selectedFilterIndex = index);
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 12,
      ),
    );
  }
}
