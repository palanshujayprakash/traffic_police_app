import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_police_app/data/models/vehicle_model.dart';
import 'package:traffic_police_app/data/models/challan_model.dart';
import 'package:traffic_police_app/data/repositories/mock_data_repository.dart';
import 'package:traffic_police_app/data/services/vehicle_service.dart';
import 'package:traffic_police_app/data/services/driving_license_service.dart';
import 'package:traffic_police_app/data/services/challan_service.dart';
import 'package:traffic_police_app/data/services/audit_service.dart';

void main() {
  final vehicleService = VehicleService.instance;
  final dlService = DrivingLicenseService.instance;
  final challanService = ChallanService.instance;
  final auditService = AuditService.instance;

  group('Phase 4: VehicleService Tests', () {
    test('Look up vehicle by registration number with loose formatting', () async {
      // Standard spaced query
      final v1 = await vehicleService.searchByRegistration('DL 01 CA 8821');
      expect(v1, isNotNull);
      expect(v1!.ownerName, 'Vikramaditya Malhotra');
      expect(v1.type, VehicleType.car);

      // Compact unspaced lowercase query
      final v2 = await vehicleService.searchByRegistration('dl01ca8821');
      expect(v2, isNotNull);
      expect(v2!.registrationNumber, 'DL 01 CA 8821');

      // Non-existent plate
      final v3 = await vehicleService.searchByRegistration('XX 99 ZZ 9999');
      expect(v3, isNull);
    });

    test('Look up vehicle by Chassis and Engine number', () async {
      // By Chassis VIN
      final vChassis = await vehicleService.searchByChassis('MALC181CLPM109283');
      expect(vChassis, isNotNull);
      expect(vChassis!.makeModel, contains('Hyundai Creta'));

      // By Engine Number
      final vEngine = await vehicleService.searchByEngine('U3S5D098231');
      expect(vEngine, isNotNull);
      expect(vEngine!.makeModel, contains('Royal Enfield'));
    });

    test('Critical stolen vehicle identification', () async {
      final truck = await vehicleService.searchByRegistration('HR 55 TR 9012');
      expect(truck, isNotNull);
      expect(truck!.isStolen, isTrue);
      expect(truck.stolenFirDetails, contains('FIR #441/24'));
    });

    test('General search and vehicle type filtering', () async {
      final bikes = await vehicleService.searchGeneral('', typeFilter: VehicleType.bike);
      expect(bikes.every((v) => v.type == VehicleType.bike), isTrue);

      final queryMatches = await vehicleService.searchGeneral('Mahindra');
      expect(queryMatches.any((v) => v.makeModel.contains('Mahindra')), isTrue);
    });
  });

  group('Phase 4: DrivingLicenseService Tests', () {
    test('Valid driver license lookup and validity checking', () async {
      final dl = await dlService.searchByLicenseNumber('DL-0420190012345');
      expect(dl, isNotNull);
      expect(dl!.holderName, 'Vikramaditya Malhotra');
      expect(dl.isValid, isTrue);
      expect(dl.isSuspended, isFalse);
      expect(dl.authorizedClasses, contains('LMV'));
      expect(dl.activePenaltyPoints, 2);

      final isValid = await dlService.isLicenseValid('DL-0420190012345');
      expect(isValid, isTrue);
    });

    test('Suspended driver license detection', () async {
      final dl = await dlService.searchByLicenseNumber('HR-5520140023411');
      expect(dl, isNotNull);
      expect(dl!.holderName, 'Balwinder Singh');
      expect(dl.isSuspended, isTrue);
      expect(dl.suspensionReason, contains('Exceeded 12 statutory penalty points'));
      expect(dl.activePenaltyPoints, 14);

      final isValid = await dlService.isLicenseValid('HR-5520140023411');
      expect(isValid, isFalse);
    });
  });

  group('Phase 4: ChallanService & Fine Settlement Tests', () {
    test('Compute total fine accurately for selected offenses', () {
      final offenses = [
        MockDataRepository.standardOffenses[0], // Without Helmet: ₹1000
        MockDataRepository.standardOffenses[1], // Signal Jump: ₹1000
        MockDataRepository.standardOffenses[2], // Overspeeding: ₹2000
      ];
      final total = challanService.calculateTotalFine(offenses);
      expect(total, 4000.0);
    });

    test('Issue statutory e-Challan and update vehicle pending citations', () async {
      final targetVehicle = await vehicleService.searchByRegistration('DL 01 CA 8821');
      expect(targetVehicle, isNotNull);
      final initialCount = targetVehicle!.pendingChallanCount;
      final initialFine = targetVehicle.pendingChallanAmount;

      final offenses = [MockDataRepository.standardOffenses[1]]; // Signal Jump (₹1000)
      final newChallan = ChallanModel(
        challanNumber: 'DL-ECH-2024-TEST-001',
        vehicleNumber: 'DL 01 CA 8821',
        vehicleModel: 'Hyundai Creta SX (O)',
        driverName: 'Vikramaditya Malhotra',
        dlNumber: 'DL-0420190012345',
        issuedAt: DateTime.now(),
        location: 'MG Road Junction',
        offenses: offenses,
        totalFine: 1000.0,
        isPaid: false,
        officerName: 'Insp. Rajesh Kumar',
        officerBadge: 'TP-8429',
      );

      final issued = await challanService.issueChallan(newChallan);
      expect(issued.challanNumber, 'DL-ECH-2024-TEST-001');

      // Verify citation appears in history
      final fetched = await challanService.getChallanByNumber('DL-ECH-2024-TEST-001');
      expect(fetched, isNotNull);
      expect(fetched!.isPaid, isFalse);

      // Verify vehicle record updated
      final updatedVehicle = await vehicleService.searchByRegistration('DL 01 CA 8821');
      expect(updatedVehicle!.pendingChallanCount, initialCount + 1);
      expect(updatedVehicle.pendingChallanAmount, initialFine + 1000.0);
    });

    test('Settle citation and record payment in cash/POS', () async {
      final updatedChallan = await challanService.markChallanPaid(
        'DL-ECH-2024-TEST-001',
        paymentMode: 'Cash / Handheld POS Terminal',
        transactionId: 'CASH-REC-TEST-999',
      );

      expect(updatedChallan.isPaid, isTrue);
      expect(updatedChallan.paymentMode, 'Cash / Handheld POS Terminal');
      expect(updatedChallan.transactionId, 'CASH-REC-TEST-999');

      // Verify in history
      final inHistory = await challanService.getChallanByNumber('DL-ECH-2024-TEST-001');
      expect(inHistory!.isPaid, isTrue);
    });
  });

  group('Phase 4: AuditService Logging Tests', () {
    test('Audit log records vehicle searches, DL searches, challans and impounds', () async {
      final initialLogsCount = auditService.currentLogs.length;

      // 1. Log a search
      await auditService.logSearch(
        queryType: 'REGISTRATION',
        queryValue: 'DL 01 CA 8821',
        found: true,
        officerBadge: 'TP-8429',
        officerName: 'Insp. Rajesh Kumar',
      );

      // 2. Log an impound
      await auditService.logImpound(
        vehicleNumber: 'HR 55 TR 9012',
        reason: 'Flagged Stolen in Vahan',
        officerBadge: 'TP-8429',
        officerName: 'Insp. Rajesh Kumar',
      );

      final logs = await auditService.getAuditLogs();
      expect(logs.length, initialLogsCount + 2);

      // Latest log is the impound
      final latest = logs.first;
      expect(latest.actionType, 'VEHICLE_IMPOUND');
      expect(latest.targetIdentifier, 'HR 55 TR 9012');
      expect(latest.status, 'ALERT_FLAGGED');
      expect(latest.officerBadge, 'TP-8429');
    });
  });
}
