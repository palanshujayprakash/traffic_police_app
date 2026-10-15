import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_police_app/core/theme/app_theme.dart';
import 'package:traffic_police_app/data/services/offline_sync_service.dart';
import 'package:traffic_police_app/presentation/screens/admin/admin_command_dashboard_screen.dart';
import 'package:traffic_police_app/presentation/screens/profile/inspector_profile_screen.dart';

void main() {
  void setPhoneSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('Phase 6: AdminCommandDashboardScreen Widget Tests', () {
    testWidgets('Renders Grid HUD, Bento KPI cards, bar chart, and incident feed', (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AdminCommandDashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Top Header & Protocol Bar
      expect(find.text('COMMAND HQ'), findsOneWidget);
      expect(find.text('DELHI ENFORCEMENT GRID'), findsOneWidget);
      expect(find.text('GRID ENFORCEMENT HUD'), findsOneWidget);
      expect(find.text('SYNC GRID'), findsOneWidget);

      // 5 Bento KPI cards
      expect(find.text('2,845'), findsOneWidget);
      expect(find.text('₹48.2L'), findsWidgets);
      expect(find.text('142'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('98.6%'), findsOneWidget);

      // Offline enforcement queue panel
      expect(find.text('Offline Enforcement Queue'), findsOneWidget);
      expect(find.text('SYNC NOW'), findsOneWidget);
      expect(find.text('5,420 HASHES CACHED'), findsOneWidget);

      // Scroll down to Hotspots & Inspector Whitelist
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -1200));
      await tester.pumpAndSettle();

      expect(find.textContaining('AIIMS Flyover'), findsOneWidget);
      expect(find.textContaining('Barapullah'), findsOneWidget);
      expect(find.textContaining('Mall Road'), findsOneWidget);

      // Inspector Whitelist
      expect(find.text('Inspector Fleet & Whitelist Management'), findsOneWidget);
      expect(find.text('Insp. Rajesh Kumar'), findsWidgets);
      expect(find.text('ENROLL'), findsOneWidget);
    });

    testWidgets('Tapping ALERT header button opens emergency broadcast dialog and dismisses', (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AdminCommandDashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap ALERT button in AppBar actions
      final alertBtn = find.text('ALERT');
      expect(alertBtn, findsOneWidget);
      await tester.tap(alertBtn);
      await tester.pumpAndSettle();

      // Verify emergency broadcast modal dialog opened
      expect(find.text('BROADCAST ALERT'), findsOneWidget);
      expect(find.text('ALERT HEADLINE'), findsOneWidget);
      expect(find.text('INSTRUCTIONS'), findsOneWidget);
      expect(find.text('TRANSMIT'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('ALERT HEADLINE'), findsNothing);
    });

    testWidgets('Tapping ENROLL opens Inspector Enrollment dialog and allows cancellation', (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AdminCommandDashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to ENROLL button if needed
      final enrollBtn = find.text('ENROLL');
      await tester.scrollUntilVisible(
        enrollBtn,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(enrollBtn, findsOneWidget);
      await tester.tap(enrollBtn);
      await tester.pumpAndSettle();

      expect(find.text('Register Officer Whitelist'), findsOneWidget);
      expect(find.text('Officer Full Name (e.g. Insp. Suresh Nair)'), findsOneWidget);
      expect(find.text('Badge # (e.g. TP-9511)'), findsOneWidget);
      expect(find.text('Fast Pass PIN'), findsOneWidget);

      // Cancel by tapping close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('Register Officer Whitelist'), findsNothing);
    });

    testWidgets('Toggling offline mode switch updates OfflineSyncService status', (WidgetTester tester) async {
      setPhoneSize(tester);
      OfflineSyncService.instance.setOfflineMode(false);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AdminCommandDashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch).first;
      expect(switchFinder, findsOneWidget);

      // Toggle switch to true
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      expect(OfflineSyncService.instance.isOfflineMode, true);

      // Toggle switch back to false
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      expect(OfflineSyncService.instance.isOfflineMode, false);
    });

    testWidgets('InspectorProfileScreen has Command HQ navigation tile and navigates to dashboard', (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const InspectorProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Command HQ tile is present and scroll until visible
      final commandHqTile = find.text('Command HQ Admin Panel');
      await tester.scrollUntilVisible(
        commandHqTile,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(commandHqTile, findsOneWidget);
      expect(find.text('Offline Citation Sync Queue'), findsOneWidget);
      expect(find.text('App Language'), findsOneWidget);

      // Tap Command HQ tile and verify it navigates to AdminCommandDashboardScreen
      await tester.tap(commandHqTile);
      await tester.pumpAndSettle();

      expect(find.text('COMMAND HQ'), findsOneWidget);
      expect(find.text('GRID ENFORCEMENT HUD'), findsOneWidget);
    });
  });
}
