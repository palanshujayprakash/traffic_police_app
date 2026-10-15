import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_police_app/core/theme/app_theme.dart';
import 'package:traffic_police_app/data/repositories/mock_data_repository.dart';
import 'package:traffic_police_app/data/services/challan_service.dart';
import 'package:traffic_police_app/presentation/screens/search/vehicle_search_screen.dart';
import 'package:traffic_police_app/presentation/screens/challan/issue_challan_screen.dart';
import 'package:traffic_police_app/presentation/screens/receipt/challan_receipt_screen.dart';
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

  testWidgets('Phase 4: VehicleSearchScreen Driver License tab and card test', (WidgetTester tester) async {
    setPhoneSize(tester);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const VehicleSearchScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Vehicle tab loaded with vehicles
    expect(find.text('VAHAN VEHICLE & DL SEARCH'), findsOneWidget);
    expect(find.text('Hyundai Creta SX (O) 1.5 CRDi'), findsOneWidget);

    // Switch to 'License' tab
    await tester.tap(find.text('License'));
    await tester.pumpAndSettle();

    // Verify driver licenses are displayed
    expect(find.text('Vikramaditya Malhotra'), findsOneWidget);
    expect(find.text('Balwinder Singh'), findsOneWidget);
    expect(find.textContaining('Suspended by RTO'), findsOneWidget);
    expect(find.text('14 Penalty Points'), findsOneWidget);
    expect(find.text('Issue Challan for Driver'), findsWidgets);
  });

  testWidgets('Phase 4: IssueChallanScreen interactive fine calculation and submission', (WidgetTester tester) async {
    setPhoneSize(tester);

    final vehicle = MockDataRepository.mockVehicles.first;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: IssueChallanScreen(preselectedVehicle: vehicle),
      ),
    );
    await tester.pumpAndSettle();

    // Initial state has default OFF-2 (Signal Jump: ₹1000)
    expect(find.text('ISSUE STATUTORY E-CHALLAN'), findsOneWidget);
    expect(find.text('₹1000'), findsWidgets);

    // Select second offense: "Riding Without Helmet" (₹1000)
    await tester.tap(find.text('Riding Without Helmet'));
    await tester.pumpAndSettle();

    // Fine should now be ₹2000
    expect(find.text('₹2000'), findsWidgets);

    // Tap "Generate E-Challan" button
    await tester.tap(find.text('Generate E-Challan'));
    await tester.pumpAndSettle();

    // Verify receipt screen was rendered
    expect(find.byType(ChallanReceiptScreen), findsOneWidget);
    expect(find.text('E-CHALLAN RECEIPT SLIP'), findsOneWidget);
    expect(find.text('PAYMENT STATUS: UNPAID (PENDING)'), findsOneWidget);
  });

  testWidgets('Phase 4: ChallanReceiptScreen settlement interaction', (WidgetTester tester) async {
    setPhoneSize(tester);

    final challans = await ChallanService.instance.getAllChallans();
    final unpaidChallan = challans.firstWhere((c) => !c.isPaid);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: ChallanReceiptScreen(challan: unpaidChallan),
      ),
    );
    await tester.pumpAndSettle();

    final settleBtnFinder = find.text('Mark Paid In Cash / POS Terminal');
    await tester.ensureVisible(settleBtnFinder);
    expect(settleBtnFinder, findsOneWidget);
    expect(find.text('PAYMENT STATUS: UNPAID (PENDING)'), findsOneWidget);

    // Tap settle button
    await tester.tap(settleBtnFinder);
    await tester.pumpAndSettle();

    // Status updates to SETTLED (PAID)
    expect(find.text('PAYMENT STATUS: SETTLED (PAID)'), findsOneWidget);
    expect(find.text('Mark Paid In Cash / POS Terminal'), findsNothing);
  });

  testWidgets('Phase 4: InspectorProfileScreen audit log sheet test', (WidgetTester tester) async {
    setPhoneSize(tester);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const InspectorProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify profile rendered
    expect(find.text('OFFICER PROFILE & SETTINGS'), findsOneWidget);
    final auditTileFinder = find.text('Shift Audit & Query Log');
    await tester.ensureVisible(auditTileFinder);
    expect(auditTileFinder, findsOneWidget);

    // Tap Shift Audit Log tile
    await tester.tap(auditTileFinder);
    await tester.pumpAndSettle();

    // Verify modal sheet opened
    expect(find.text('ENFORCEMENT AUDIT LOG'), findsOneWidget);
  });
}
