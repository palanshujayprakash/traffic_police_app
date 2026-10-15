import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum DevicePreset {
  pixel8('Google Pixel 8', 412, 892, 38),
  iphone15Pro('iPhone 15 Pro', 393, 852, 44),
  ruggedPos('Rugged Field POS', 380, 800, 24);

  final String label;
  final double width;
  final double height;
  final double cornerRadius;

  const DevicePreset(this.label, this.width, this.height, this.cornerRadius);
}

/// A luxury mobile device mockup frame that houses the application on desktop/web viewports.
/// Automatically renders child directly on actual mobile screens or in headless test environments.
class MobileDeviceFrame extends StatefulWidget {
  final Widget child;
  final bool enableFrame;

  const MobileDeviceFrame({
    super.key,
    required this.child,
    this.enableFrame = kIsWeb,
  });

  @override
  State<MobileDeviceFrame> createState() => _MobileDeviceFrameState();
}

class _MobileDeviceFrameState extends State<MobileDeviceFrame> {
  bool _isFrameEnabled = true;
  DevicePreset _selectedPreset = DevicePreset.pixel8;

  @override
  void initState() {
    super.initState();
    _isFrameEnabled = widget.enableFrame;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isFrameEnabled) {
      return widget.child;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // If screen is already mobile-sized, render directly
        if (constraints.maxWidth <= 500) {
          return widget.child;
        }

        final currentTime = DateFormat('hh:mm a').format(DateTime.now());
        final targetWidth = _selectedPreset.width;
        final targetHeight = _selectedPreset.height;

        return Scaffold(
          backgroundColor: const Color(0xFF070B14),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.3),
                radius: 1.2,
                colors: [
                  Color(0xFF0F1B33),
                  Color(0xFF070B14),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Top HUD Command Bar for Browser Viewers
                  _buildBrowserControlBar(),

                  // Phone Frame in Center with auto-scaling to fit screen height
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          child: _buildPhoneChassis(
                            targetWidth: targetWidth,
                            targetHeight: targetHeight,
                            currentTime: currentTime,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBrowserControlBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo & Subtitle
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FFCC).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield_rounded, color: Color(0xFF00FFCC), size: 18),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'DELHI TRAFFIC POLICE • FIELD TERMINAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Handheld Mobile Enforcement Viewport',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 20),

            // Device Preset Switcher & Fullscreen Toggle
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButton<DevicePreset>(
                    value: _selectedPreset,
                    dropdownColor: const Color(0xFF1E293B),
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00FFCC), size: 20),
                    items: DevicePreset.values.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Text(
                          p.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (p) {
                      if (p != null) setState(() => _selectedPreset = p);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.fullscreen_rounded, size: 16),
                  label: const Text('Fullscreen', style: TextStyle(fontSize: 11)),
                  onPressed: () => setState(() => _isFrameEnabled = false),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneChassis({
    required double targetWidth,
    required double targetHeight,
    required String currentTime,
  }) {
    final radius = _selectedPreset.cornerRadius;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Left Side Hardware Buttons (Volume Up/Down)
        Positioned(
          left: -4,
          top: 140,
          child: Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2C3242),
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(2)),
            ),
          ),
        ),
        Positioned(
          left: -4,
          top: 200,
          child: Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2C3242),
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(2)),
            ),
          ),
        ),

        // Right Side Hardware Button (Power / Lock)
        Positioned(
          right: -4,
          top: 160,
          child: Container(
            width: 4,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF2C3242),
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(2)),
            ),
          ),
        ),

        // Outer Metallic Bezel & Phone Body
        Container(
          width: targetWidth + 24,
          height: targetHeight + 24,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F2C),
            borderRadius: BorderRadius.circular(radius + 8),
            border: Border.all(
              color: const Color(0xFF333D52),
              width: 3.5,
            ),
            boxShadow: [
              // Deep Ambient Drop Shadow
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 40,
                spreadRadius: 8,
                offset: const Offset(0, 16),
              ),
              // Subtle Outer Cyan Glow
              BoxShadow(
                color: const Color(0xFF00FFCC).withValues(alpha: 0.08),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(radius),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Stack(
                children: [
                  // The Actual Flutter Application
                  Positioned.fill(
                    child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        size: Size(targetWidth, targetHeight),
                        padding: const EdgeInsets.only(top: 40, bottom: 20),
                        viewPadding: const EdgeInsets.only(top: 40, bottom: 20),
                      ),
                      child: widget.child,
                    ),
                  ),

                  // Phone Status Bar Overlay
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 38,
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Time & Carrier
                            Text(
                              currentTime,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),

                            // Dynamic Island / Camera Notch
                            Container(
                              width: 104,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white12, width: 0.5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF152238),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFF3B82F6), width: 1.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Connectivity & Battery Icons
                            Row(
                              children: const [
                                Icon(Icons.signal_cellular_4_bar_rounded, size: 14, color: Colors.black87),
                                SizedBox(width: 4),
                                Icon(Icons.wifi_rounded, size: 14, color: Colors.black87),
                                SizedBox(width: 4),
                                Icon(Icons.battery_5_bar_rounded, size: 16, color: Colors.black87),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom Gesture Navigation Bar
                  Positioned(
                    bottom: 6,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: Center(
                        child: Container(
                          width: 110,
                          height: 4.5,
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
