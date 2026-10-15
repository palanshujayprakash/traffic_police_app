import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_police_app/core/theme/app_theme.dart';
import 'package:traffic_police_app/presentation/screens/scanner/anpr_scanner_screen.dart';
import 'package:traffic_police_app/presentation/screens/vehicle/vehicle_details_screen.dart';

void main() {
  Widget createTestWidget({String? initialPlate}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: AnprScannerScreen(
        initialPlate: initialPlate,
        enableAnimation: false,
      ),
    );
  }

  group('Phase 5: AnprScannerScreen Widget Tests', () {
    testWidgets('Renders viewfinder HUD, telemetry watermark, and initial plate card', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(initialPlate: 'DL 01 CA 8821'));
      await tester.pumpAndSettle();

      // Top app bar
      expect(find.text('ANPR Scanner'), findsOneWidget);
      expect(find.text('TRAFFIC DEPT'), findsOneWidget);

      // HUD & telemetry
      expect(find.text('30 FPS • 4K OCR'), findsOneWidget);
      expect(find.text('Align HSRP plate within frame'), findsOneWidget);
      expect(find.textContaining('Optical Confidence'), findsOneWidget);

      // Mode Switcher
      expect(find.text('ANPR Plate'), findsOneWidget);
      expect(find.text('Chassis / QR'), findsOneWidget);

      // Bottom Recognition Card
      expect(find.text('Plate Recognized'), findsOneWidget);
      expect(find.text('VAHAN Match Ready'), findsOneWidget);
      expect(find.text('DL 01 CA 8821'), findsOneWidget);
      expect(find.text('DELHI STATE'), findsOneWidget);
      expect(find.text('IND'), findsOneWidget);

      // Vehicle hint
      expect(find.textContaining('Hyundai Creta'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);

      // Action buttons
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Search VAHAN'), findsOneWidget);
    });

    testWidgets('Toggles scanner mode and zoom levels', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap Chassis / QR mode
      await tester.tap(find.text('Chassis / QR'));
      await tester.pumpAndSettle();

      // Tap 2x zoom
      await tester.tap(find.text('2x'));
      await tester.pumpAndSettle();

      // Tap torch toggle
      final torchBtn = find.byIcon(Icons.flash_off);
      expect(torchBtn, findsOneWidget);
      await tester.tap(torchBtn);
      await tester.pump();
      expect(find.text('Camera Torch Activated'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('Selecting sample plate updates recognition sheet and triggers stolen vehicle alert', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(initialPlate: 'DL 01 CA 8821'));
      await tester.pumpAndSettle();

      // Select Stolen Truck sample
      final stolenChip = find.text('Stolen Truck (Alert!)');
      expect(stolenChip, findsOneWidget);
      await tester.tap(stolenChip);
      await tester.pumpAndSettle();

      // Verify BOLO alert banner appears
      expect(find.text('STOLEN VEHICLE / BOLO ALERT!'), findsOneWidget);
      expect(find.textContaining('FIR #441/24'), findsOneWidget);
      expect(find.text('ALERT'), findsOneWidget);
      expect(find.text('HR 55 TR 9012'), findsOneWidget);
      expect(find.text('HARYANA STATE'), findsOneWidget);
    });

    testWidgets('Manual Edit modal allows adjusting plate and updates recognition sheet', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(initialPlate: 'DL 01 CA 8821'));
      await tester.pumpAndSettle();

      // Tap Edit button
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Verify modal content
      expect(find.text('Manual Plate Entry'), findsOneWidget);
      expect(find.text('REGISTRATION NUMBER'), findsOneWidget);

      // Enter a new plate
      final inputField = find.byType(TextField);
      expect(inputField, findsOneWidget);
      await tester.enterText(inputField, 'KA 03 BS 4321');
      await tester.pumpAndSettle();

      // Tap Apply & Verify
      await tester.tap(find.text('Apply & Verify'));
      await tester.pumpAndSettle();

      // Verify sheet updated with new plate
      expect(find.text('KA 03 BS 4321'), findsOneWidget);
      expect(find.text('KARNATAKA STATE'), findsOneWidget);
      expect(find.text('Ashok Leyland Viking Commercial Bus'), findsOneWidget);
    });

    testWidgets('Tapping Search VAHAN navigates to VehicleDetailsScreen', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(initialPlate: 'DL 01 CA 8821'));
      await tester.pumpAndSettle();

      // Tap Search VAHAN
      await tester.tap(find.text('Search VAHAN'));
      await tester.pumpAndSettle();

      // Verify VehicleDetailsScreen is pushed
      expect(find.byType(VehicleDetailsScreen), findsOneWidget);
      expect(find.text('VEHICLE REGISTRY RECORD'), findsOneWidget);
    });
  });
}
