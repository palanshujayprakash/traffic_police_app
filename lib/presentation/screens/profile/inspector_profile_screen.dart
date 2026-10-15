import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/localization/app_localization.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/repositories/mock_data_repository.dart';
import '../../../data/services/audit_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/offline_sync_service.dart';
import '../admin/admin_command_dashboard_screen.dart';
import '../auth/inspector_login_screen.dart';

class InspectorProfileScreen extends StatefulWidget {
  const InspectorProfileScreen({super.key});

  @override
  State<InspectorProfileScreen> createState() => _InspectorProfileScreenState();
}

class _InspectorProfileScreenState extends State<InspectorProfileScreen> {
  bool _isOnDuty = true;
  final OfflineSyncService _syncService = OfflineSyncService.instance;
  final AppLocalizationService _localizationService = AppLocalizationService.instance;

  @override
  Widget build(BuildContext context) {
    final inspector = AuthService().currentInspector ?? MockDataRepository.activeInspector;

    return Scaffold(
      appBar: AppBar(
        title: const Text('OFFICER PROFILE & SETTINGS'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Officer Profile Card
            Container(
              padding: const EdgeInsets.all(20),
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
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          inspector.avatarInitials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: _isOnDuty ? AppColors.success : AppColors.textMuted,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    inspector.name,
                    style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    '${inspector.rank} • Badge #${inspector.badgeNumber}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // On-duty switch pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isOnDuty ? AppColors.successBg : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: _isOnDuty ? AppColors.successBorder : AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isOnDuty ? 'ACTIVE ON DUTY' : 'OFF DUTY',
                          style: AppTypography.labelSmall.copyWith(
                            color: _isOnDuty ? AppColors.successText : AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Switch(
                          value: _isOnDuty,
                          activeThumbColor: AppColors.success,
                          onChanged: (val) {
                            setState(() => _isOnDuty = val);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_isOnDuty ? 'Inspector status set to Active Duty' : 'Shift marked off-duty'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Jurisdiction & Shift Details
            const SectionHeader(title: 'Jurisdiction & Deployment', icon: Icons.local_police_rounded),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildProfileRow('Police Station', inspector.station),
                  const Divider(),
                  _buildProfileRow('Assigned Beat', inspector.beatLocation),
                  const Divider(),
                  _buildProfileRow('Current Shift', inspector.shift),
                  const Divider(),
                  _buildProfileRow('Official Contact', inspector.phone),
                  const Divider(),
                  _buildProfileRow('Govt Email', inspector.email),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Performance Metrics
            const SectionHeader(title: 'Today’s Performance', icon: Icons.insights_rounded),
            Row(
              children: [
                Expanded(
                  child: DutyCard(
                    title: 'Total Lookups',
                    value: '142',
                    icon: Icons.search_rounded,
                    iconColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DutyCard(
                    title: 'Citations Issued',
                    value: '${inspector.challansIssuedToday}',
                    icon: Icons.receipt_long_rounded,
                    iconColor: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Equipment & Hardware Settings
            const SectionHeader(title: 'Field Hardware & Sync', icon: Icons.settings_remote_rounded),
            Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.print_rounded, color: AppColors.primary),
                    title: const Text('Bluetooth Thermal Printer', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('BT-PRN-8429 • Connected (Battery 84%)'),
                    trailing: const StatusBadge(label: 'PAIRED', status: BadgeStatus.valid, isCompact: true),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.cloud_sync_rounded, color: AppColors.accent),
                    title: const Text('Offline Citation Sync Queue', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      _syncService.pendingCount == 0
                          ? 'Queue clear • All records synchronized'
                          : '${_syncService.pendingCount} pending offline citations ready for sync',
                    ),
                    trailing: _syncService.pendingCount > 0
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            ),
                            onPressed: () async {
                              final count = await _syncService.syncPendingQueue();
                              if (context.mounted) {
                                setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Successfully synced $count citations to central database!')),
                                );
                              }
                            },
                            child: const Text('SYNC', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          )
                        : Switch(
                            value: _syncService.isOfflineMode,
                            activeThumbColor: AppColors.warning,
                            onChanged: (val) {
                              setState(() => _syncService.setOfflineMode(val));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    val ? 'Offline enforcement simulation active' : 'Online grid connected',
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.sync_rounded, color: AppColors.accent),
                    title: const Text('VAHAN Offline Database Cache', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('5,420 cached vehicle hashes • Synced 4m ago'),
                    trailing: IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Offline vehicle database refreshed successfully!')),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.translate_rounded, color: AppColors.info),
                    title: const Text('App Language', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(_localizationService.isHindi ? 'हिन्दी (Hindi)' : 'English (India)'),
                    trailing: DropdownButton<String>(
                      value: _localizationService.isHindi ? 'Hindi' : 'English',
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'English', child: Text('English')),
                        DropdownMenuItem(value: 'Hindi', child: Text('हिन्दी')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          _localizationService.setLanguage(val == 'Hindi' ? AppLanguage.hindi : AppLanguage.english);
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Language switched to $val')),
                          );
                        }
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.history_edu_rounded, color: AppColors.primary),
                    title: const Text('Shift Audit & Query Log', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Immutable enforcement search & citation audit trail'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showAuditLogSheet(context),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Institutional Command HQ Dashboard
          const SectionHeader(title: 'Command HQ & Administration', icon: Icons.shield_rounded),
          Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141422),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF00E5FF)),
                ),
                title: Text(
                  'admin_command'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text('Fleet telemetry, whitelist access & POL-NET alerts'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminCommandDashboardScreen()),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

            // Log Out Button
            AppButton.secondary(
              text: 'Sign Out / Switch Officer',
              icon: Icons.logout_rounded,
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const InspectorLoginScreen()),
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
          Flexible(
            child: Text(
              value,
              style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  void _showAuditLogSheet(BuildContext context) {
    final dateFormat = DateFormat('HH:mm:ss • dd-MMM');
    final logs = AuditService.instance.currentLogs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ENFORCEMENT AUDIT LOG',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            'Shift Activity & Queries (${logs.length})',
                            style: AppTypography.headlineSmall.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: logs.isEmpty
                      ? const Center(child: Text('No audit entries recorded.'))
                      : ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: logs.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (_, index) {
                            final entry = logs[index];
                            final isAlert = entry.status == 'ALERT_FLAGGED';
                            final isViolation = entry.status == 'VIOLATION_RECORDED';

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isAlert
                                    ? AppColors.errorBg
                                    : isViolation
                                        ? AppColors.accentContainer
                                        : AppColors.canvas,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isAlert
                                      ? AppColors.errorBorder
                                      : isViolation
                                          ? AppColors.accent.withValues(alpha: 0.3)
                                          : AppColors.border,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          entry.actionType,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        dateFormat.format(entry.timestamp),
                                        style: AppTypography.bodySmall.copyWith(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Target: ${entry.targetIdentifier}',
                                    style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    entry.details,
                                    style: AppTypography.bodySmall.copyWith(fontSize: 11),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Officer: ${entry.officerName} (${entry.officerBadge})',
                                    style: AppTypography.bodySmall.copyWith(
                                      fontSize: 10,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
