import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_police_app/main.dart';
import 'package:traffic_police_app/core/theme/app_theme.dart';
import 'package:traffic_police_app/core/widgets/widgets.dart';
import 'package:traffic_police_app/data/repositories/mock_data_repository.dart';
import 'package:traffic_police_app/data/services/auth_service.dart';
import 'package:traffic_police_app/presentation/screens/auth/inspector_login_screen.dart';
import 'package:traffic_police_app/presentation/screens/home/home_screen.dart';
import 'package:traffic_police_app/presentation/screens/search/vehicle_search_screen.dart';
import 'package:traffic_police_app/presentation/screens/challan/issue_challan_screen.dart';
import 'package:traffic_police_app/presentation/screens/history/challan_history_screen.dart';
import 'package:traffic_police_app/presentation/screens/profile/inspector_profile_screen.dart';
import 'package:traffic_police_app/presentation/screens/vehicle/vehicle_details_screen.dart';
import 'package:traffic_police_app/presentation/screens/receipt/challan_receipt_screen.dart';
import 'package:traffic_police_app/presentation/screens/main_navigation_screen.dart';

void main() {
  setUp(() {
    AuthService().logout();
  });

  testWidgets('Phase 3 Inspector Login Screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TrafficPoliceApp());
    await tester.pumpAndSettle();

    // 1. Verify Inspector Login screen renders
    expect(find.byType(InspectorLoginScreen), findsOneWidget);
    expect(find.text('Inspector Portal'), findsOneWidget);
    expect(find.text('Officer Whitelist Sign-In'), findsOneWidget);
    expect(find.text('Request 6-Digit OTP'), findsOneWidget);
    expect(find.text('Biometrics'), findsOneWidget);

    // 2. Request OTP
    await tester.ensureVisible(find.text('Request 6-Digit OTP'));
    await tester.tap(find.text('Request 6-Digit OTP'));
    await tester.pumpAndSettle();

    // 3. Verify Step 2 OTP Screen rendered
    expect(find.text('Verify Security Code'), findsOneWidget);
    expect(find.text('Verify & Launch Duty Guard'), findsOneWidget);

    // 4. Tap Verify to log in
    await tester.tap(find.text('Verify & Launch Duty Guard'));
    await tester.pumpAndSettle();

    // 5. Verify transition to MainNavigationScreen & HomeScreen
    expect(find.byType(MainNavigationScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('TRAFFIC POLICE'), findsOneWidget);
    expect(find.text('Admin Palanshu'), findsOneWidget);
  });

  testWidgets('Phase 2 Navigation & Screen Shells smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const MainNavigationScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Home screen renders
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('TRAFFIC POLICE'), findsOneWidget);
    expect(find.text('Insp. Rajesh Kumar'), findsOneWidget);
    expect(find.byType(PlateDisplayCard), findsWidgets);

    // 2. Switch to Search tab via Bottom Navigation
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    expect(find.byType(VehicleSearchScreen), findsOneWidget);
    expect(find.text('VAHAN VEHICLE & DL SEARCH'), findsOneWidget);
    expect(find.text('DL 01 CA 8821 (Car (Creta))'), findsOneWidget);

    // 3. Switch to Challan tab via Bottom Navigation
    await tester.tap(find.text('Challan'));
    await tester.pumpAndSettle();
    expect(find.byType(IssueChallanScreen), findsOneWidget);
    expect(find.text('ISSUE STATUTORY E-CHALLAN'), findsOneWidget);
    expect(find.text('TOTAL STATUTORY FINE'), findsOneWidget);

    // 4. Switch to History tab via Bottom Navigation
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.byType(ChallanHistoryScreen), findsOneWidget);
    expect(find.text('CHALLAN DISPATCH & AUDIT LOG'), findsOneWidget);
    expect(find.text('All Citations'), findsOneWidget);

    // 5. Switch to Profile tab via Bottom Navigation
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.byType(InspectorProfileScreen), findsOneWidget);
    expect(find.text('OFFICER PROFILE & SETTINGS'), findsOneWidget);
    expect(find.text('ACTIVE ON DUTY'), findsOneWidget);
  });

  testWidgets('Phase 2 Vehicle Details & Stolen Alert screen test', (WidgetTester tester) async {
    final stolenVehicle = MockDataRepository.mockVehicles.firstWhere((v) => v.isStolen);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: VehicleDetailsScreen(vehicle: stolenVehicle),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('VEHICLE REGISTRY RECORD'), findsOneWidget);
    expect(find.text('STOLEN VEHICLE ALERT'), findsOneWidget);
    expect(find.text('Dispatch 112'), findsOneWidget);
    expect(find.text('Initiate Impound'), findsOneWidget);
    expect(find.text('HR 55 TR 9012'), findsOneWidget);
  });

  testWidgets('Phase 2 Challan Receipt & UPI QR test', (WidgetTester tester) async {
    final challan = MockDataRepository.mockChallanHistory.first;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: ChallanReceiptScreen(challan: challan),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('E-CHALLAN RECEIPT SLIP'), findsOneWidget);
    expect(find.text(challan.challanNumber), findsOneWidget);
    expect(find.text('SCAN TO PAY VIA UPI'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.text('Print Slip'), findsOneWidget);
  });
}
