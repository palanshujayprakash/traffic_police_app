import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/offline_sync_service.dart';

/// Admin Command Dashboard matching Stitch `admin_command_dashboard` design.
/// Provides institutional fleet management, inspector whitelist controls, live telemetry,
/// weekly fine analytics, and offline grid synchronization.
class AdminCommandDashboardScreen extends StatefulWidget {
  const AdminCommandDashboardScreen({super.key});

  @override
  State<AdminCommandDashboardScreen> createState() => _AdminCommandDashboardScreenState();
}

class _AdminCommandDashboardScreenState extends State<AdminCommandDashboardScreen> {
  final OfflineSyncService _syncService = OfflineSyncService.instance;
  late List<OfficerWhitelistEntry> _whitelist;

  String _selectedChartTab = 'Weekly';

  @override
  void initState() {
    super.initState();
    _whitelist = List<OfficerWhitelistEntry>.from(AuthService.adminWhitelist);
  }

  void _refreshWhitelist() {
    setState(() {
      _whitelist = List<OfficerWhitelistEntry>.from(AuthService.adminWhitelist);
    });
  }

  void _showBroadcastAlertDialog() {
    final titleController = TextEditingController(text: 'TRAFFIC DIVERSION ALERT: RING ROAD');
    final descController = TextEditingController(
      text: 'Waterlogging reported near Moolchand underpass. Divert heavy commercial vehicles towards Outer Ring Road.',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141422),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.campaign, color: Color(0xFFFF2D78)),
              const SizedBox(width: 8),
              Text(
                'BROADCAST ALERT',
                style: AppTypography.heading3.copyWith(color: Colors.white),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Push emergency alert to all 142 on-duty handheld POS terminals and patrol units.',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'ALERT HEADLINE',
                  labelStyle: const TextStyle(color: Colors.white60, fontSize: 11),
                  filled: true,
                  fillColor: const Color(0xFF1E1E30),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'INSTRUCTIONS',
                  labelStyle: const TextStyle(color: Colors.white60, fontSize: 11),
                  filled: true,
                  fillColor: const Color(0xFF1E1E30),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF2D78),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Emergency Broadcast pushed to 142 active field units!'),
                    backgroundColor: Color(0xFFFF2D78),
                  ),
                );
              },
              child: const Text('TRANSMIT'),
            ),
          ],
        );
      },
    );
  }

  void _showAddInspectorDialog() {
    final nameController = TextEditingController();
    final badgeController = TextEditingController();
    final mobileController = TextEditingController();
    final emailController = TextEditingController();
    final pinController = TextEditingController(text: '8429');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF141422),
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
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.person_add_rounded, color: Color(0xFF00FFCC)),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Register Officer Whitelist',
                              style: AppTypography.heading3.copyWith(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white60),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Officer Full Name (e.g. Insp. Suresh Nair)',
                    labelStyle: TextStyle(color: Colors.white60),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: badgeController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Badge # (e.g. TP-9511)',
                          labelStyle: TextStyle(color: Colors.white60),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: pinController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Fast Pass PIN',
                          labelStyle: TextStyle(color: Colors.white60),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: '10-Digit Mobile Number',
                    labelStyle: TextStyle(color: Colors.white60),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Official Gov Email Address',
                    labelStyle: TextStyle(color: Colors.white60),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FFCC),
                      foregroundColor: const Color(0xFF001A1A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (nameController.text.trim().isNotEmpty &&
                          badgeController.text.trim().isNotEmpty &&
                          mobileController.text.trim().isNotEmpty) {
                        final newEntry = OfficerWhitelistEntry(
                          name: nameController.text.trim(),
                          badgeNumber: badgeController.text.trim().toUpperCase(),
                          mobile: mobileController.text.trim(),
                          email: emailController.text.trim().isNotEmpty
                              ? emailController.text.trim()
                              : '${badgeController.text.trim().toLowerCase()}@delhipolice.gov.in',
                          quickPin: pinController.text.trim().isNotEmpty ? pinController.text.trim() : '8429',
                        );
                        AuthService.addWhitelistEntry(newEntry);
                        _refreshWhitelist();
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Officer ${newEntry.name} whitelisted successfully!')),
                        );
                      }
                    },
                    child: const Text('AUTHORIZE & ENROLL IN WHITELIST', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleWhitelistAccess(OfficerWhitelistEntry entry) {
    if (AuthService.isWhitelistedBadge(entry.badgeNumber)) {
      AuthService.removeWhitelistEntry(entry.badgeNumber);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Access revoked for ${entry.name} (${entry.badgeNumber})')),
      );
    } else {
      AuthService.addWhitelistEntry(entry);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Access granted for ${entry.name} (${entry.badgeNumber})')),
      );
    }
    _refreshWhitelist();
  }

  Future<void> _handleGridSync() async {
    final count = await _syncService.syncPendingQueue();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(count > 0
            ? 'Successfully synced $count offline records to Central VAHAN grid!'
            : 'Grid is fully synchronized. 0 pending offline citations.'),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A12),
      appBar: _buildHeader(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Protocol Bar
            _buildProtocolBar(),
            const SizedBox(height: 16),

            // 5 Bento KPI Metric Cards
            _buildKpiMetricsGrid(),
            const SizedBox(height: 20),

            // Weekly Inflow Bar Chart & Analytics
            _buildWeeklyAnalyticsSection(),
            const SizedBox(height: 20),

            // Offline Enforcement & Sync Queue Panel
            _buildOfflineQueueCard(),
            const SizedBox(height: 20),

            // Inspector Fleet & Whitelist Management
            _buildInspectorWhitelistSection(),
            const SizedBox(height: 20),

            // Critical Hotspot Incidents
            _buildHotspotIncidentsFeed(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildHeader() {
    return AppBar(
      backgroundColor: const Color(0xFF111118),
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.shield, color: Color(0xFF00FFCC), size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'COMMAND HQ',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'DELHI ENFORCEMENT GRID',
                style: TextStyle(
                  color: Color(0xFF00FFCC),
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF2D78),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: _showBroadcastAlertDialog,
          icon: const Icon(Icons.campaign, size: 16),
          label: const Text('ALERT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildProtocolBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF141422),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF302840)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF00FFCC),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'GRID ENFORCEMENT HUD',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E1E30),
              foregroundColor: const Color(0xFF00FFCC),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _handleGridSync,
            icon: const Icon(Icons.refresh, size: 14),
            label: const Text('SYNC GRID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiMetricsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildBentoCard(
                title: 'Total Challans Today',
                value: '2,845',
                badge: '+14.2%',
                subtitle: '1,920 ANPR • 925 Field Handheld',
                badgeColor: const Color(0xFF00FFCC),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildBentoCard(
                title: 'Fines Assessed',
                value: '₹48.2L',
                badge: 'INR VAL',
                subtitle: '₹29.4L Spot UPI • ₹18.8L V-Court',
                badgeColor: const Color(0xFFFFE04A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildBentoCard(
                title: 'Field Inspectors',
                value: '142',
                badge: '88.7% DEPLOY',
                subtitle: '/ 160 On-Duty • 6 Circles',
                badgeColor: const Color(0xFF00FFCC),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildBentoCard(
                title: 'Critical Hotspots',
                value: '7',
                badge: 'CRITICAL',
                subtitle: '4 Red-Light • 3 Speed Traps',
                badgeColor: const Color(0xFFFF4444),
                isCritical: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildBentoCard(
          title: 'Real-time ANPR OCR Accuracy',
          value: '98.6%',
          badge: '412 CAMS ACTIVE',
          subtitle: 'Optical Confidence across Mobile Units & Highway Scanners',
          badgeColor: const Color(0xFF00FFCC),
        ),
      ],
    );
  }

  Widget _buildBentoCard({
    required String title,
    required String value,
    required String badge,
    required String subtitle,
    required Color badgeColor,
    bool isCritical = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141422),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isCritical ? const Color(0xFFFF4444).withValues(alpha: 0.4) : const Color(0xFF302840)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: isCritical ? const Color(0xFFFF4444) : Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyAnalyticsSection() {
    final days = [
      {'day': 'MON', 'val': 0.72, 'amount': '₹35.8L'},
      {'day': 'TUE', 'val': 0.81, 'amount': '₹41.0L'},
      {'day': 'WED', 'val': 0.88, 'amount': '₹45.3L'},
      {'day': 'THU', 'val': 0.79, 'amount': '₹39.5L'},
      {'day': 'FRI', 'val': 0.94, 'amount': '₹48.2L'},
      {'day': 'SAT', 'val': 0.65, 'amount': '₹31.4L'},
      {'day': 'SUN', 'val': 0.58, 'amount': '₹28.0L'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141422),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF302840)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(width: 4, height: 16, color: const Color(0xFFFF2D78)),
                        const SizedBox(width: 8),
                        const Flexible(
                          child: Text(
                            'Weekly Inflow & Spot Recovery',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Aggregated violation processing via PoS terminals & ANPR arrays',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: ['Daily', 'Weekly', 'Monthly'].map((tab) {
                  final isSel = _selectedChartTab == tab;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedChartTab = tab),
                    child: Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSel ? const Color(0xFF1E1E30) : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tab,
                        style: TextStyle(
                          color: isSel ? const Color(0xFF00FFCC) : Colors.white60,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stacked Bars
          SizedBox(
            height: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: days.map((d) {
                final heightFactor = d['val'] as double;
                final isHighlight = d['day'] == 'FRI';

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      d['amount'] as String,
                      style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 28,
                      height: 110 * heightFactor,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: isHighlight
                              ? [const Color(0xFF00FFCC), const Color(0xFFFF2D78)]
                              : [const Color(0xFF1E1E30), const Color(0xFF00FFCC).withValues(alpha: 0.7)],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      d['day'] as String,
                      style: TextStyle(
                        color: isHighlight ? const Color(0xFF00FFCC) : Colors.white60,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineQueueCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141422),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF302840)),
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
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.sync_problem_rounded, color: Color(0xFFFFE04A), size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Offline Enforcement Queue',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${_syncService.pendingCount} citations waiting to sync',
                            style: const TextStyle(color: Colors.white60, fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FFCC),
                  foregroundColor: const Color(0xFF001A1A),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _handleGridSync,
                icon: const Icon(Icons.cloud_upload_rounded, size: 16),
                label: const Text('SYNC NOW', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Switch(
                      value: _syncService.isOfflineMode,
                      activeThumbColor: const Color(0xFFFFE04A),
                      onChanged: (val) {
                        setState(() {
                          _syncService.setOfflineMode(val);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(val
                                ? 'Offline mode enabled! Citations will be held in local device queue.'
                                : 'Online mode restored! Ready to connect to Central VAHAN server.'),
                          ),
                        );
                      },
                    ),
                    const Flexible(
                      child: Text(
                        'Simulate Zero-Signal Offline',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '5,420 HASHES CACHED',
                style: TextStyle(color: Color(0xFF00FFCC), fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInspectorWhitelistSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141422),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF302840)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(width: 4, height: 16, color: const Color(0xFF00FFCC)),
                        const SizedBox(width: 8),
                        const Flexible(
                          child: Text(
                            'Inspector Fleet & Whitelist Management',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Only admin-approved credentials can sign in and issue citations',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E1E30),
                  foregroundColor: const Color(0xFF00FFCC),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _showAddInspectorDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('ENROLL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Whitelist Table List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _whitelist.length,
            separatorBuilder: (_, _) => const Divider(color: Color(0xFF1E1E30)),
            itemBuilder: (context, idx) {
              final officer = _whitelist[idx];
              final isWhitelisted = AuthService.isWhitelistedBadge(officer.badgeNumber);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFF1E1E30),
                      child: Text(
                        officer.badgeNumber.split('-').last,
                        style: const TextStyle(color: Color(0xFF00FFCC), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  officer.name,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isWhitelisted
                                      ? const Color(0xFF00FFCC).withValues(alpha: 0.15)
                                      : Colors.red.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isWhitelisted ? 'WHITELISTED' : 'REVOKED',
                                  style: TextStyle(
                                    color: isWhitelisted ? const Color(0xFF00FFCC) : Colors.red,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Badge: ${officer.badgeNumber} • +91 ${officer.mobile} • ${officer.email}',
                            style: const TextStyle(color: Colors.white54, fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isWhitelisted ? Icons.block_rounded : Icons.check_circle_rounded,
                        color: isWhitelisted ? Colors.redAccent : const Color(0xFF00FFCC),
                        size: 20,
                      ),
                      tooltip: isWhitelisted ? 'Revoke Access' : 'Grant Whitelist Access',
                      onPressed: () => _toggleWhitelistAccess(officer),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHotspotIncidentsFeed() {
    final alerts = [
      {
        'title': 'AIIMS Flyover Junction • South Delhi',
        'desc': '4 signal jumps recorded in 10 minutes. ANPR Cam #12 activated speed trap.',
        'severity': 'HIGH',
      },
      {
        'title': 'Barapullah Elevated Corridor • East Delhi',
        'desc': 'Extreme speeding cluster: 3 commercial vehicles exceeding 95 km/h.',
        'severity': 'CRITICAL',
      },
      {
        'title': 'Mall Road RTO Checkpoint • North Delhi',
        'desc': 'Flagged stolen Tata Prima truck spotted heading north. Interception unit dispatched.',
        'severity': 'STOLEN ALERT',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141422),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF302840)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 4, height: 16, color: const Color(0xFFFF4444)),
              const SizedBox(width: 8),
              const Text(
                'Active Hotspot Incident Alerts',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: alerts.map((a) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF4444), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a['title']!,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            a['desc']!,
                            style: const TextStyle(color: Colors.white60, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        a['severity']!,
                        style: const TextStyle(color: Color(0xFFFF4444), fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
