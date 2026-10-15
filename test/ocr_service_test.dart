import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_police_app/data/services/ocr_service.dart';
import 'package:traffic_police_app/data/services/audit_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late OcrService ocrService;

  setUp(() {
    ocrService = OcrService.instance;
  });

  group('Phase 5: IOcrService & OcrService Unit Tests', () {
    test('Normalizes license plates cleanly', () {
      expect(ocrService.normalizePlate('dl-01-ca-8821'), equals('DL01CA8821'));
      expect(ocrService.normalizePlate('  HR  55  TR  9012  '), equals('HR55TR9012'));
      expect(ocrService.normalizePlate('MH.12/DE-1433'), equals('MH12DE1433'));
    });

    test('Formats normalized plates into standard Indian HSRP spacing', () {
      expect(ocrService.formatPlate('DL01CA8821'), equals('DL 01 CA 8821'));
      expect(ocrService.formatPlate('HR55TR9012'), equals('HR 55 TR 9012'));
      expect(ocrService.formatPlate('22BH1234AA'), equals('22 BH 1234 AA'));
    });

    test('Validates official Indian RTO state prefixes', () {
      expect(ocrService.isValidIndianPlate('DL 01 CA 8821'), isTrue);
      expect(ocrService.isValidIndianPlate('HR 55 TR 9012'), isTrue);
      expect(ocrService.isValidIndianPlate('MH 12 DE 1433'), isTrue);
      expect(ocrService.isValidIndianPlate('KA 04 MH 7711'), isTrue);
      expect(ocrService.isValidIndianPlate('22 BH 1234 AA'), isTrue);

      // Invalid state prefixes
      expect(ocrService.isValidIndianPlate('XX 01 CA 8821'), isFalse);
      expect(ocrService.isValidIndianPlate('ZZ 99 ZZ 9999'), isFalse);
      expect(ocrService.isValidIndianPlate('INVALID'), isFalse);
    });

    test('Resolves state code to full State / UT name', () {
      expect(ocrService.getStateNameFromCode('DL'), equals('Delhi'));
      expect(ocrService.getStateNameFromCode('HR'), equals('Haryana'));
      expect(ocrService.getStateNameFromCode('MH'), equals('Maharashtra'));
      expect(ocrService.getStateNameFromCode('KA'), equals('Karnataka'));
      expect(ocrService.getStateNameFromCode('PB'), equals('Punjab'));
      expect(ocrService.getStateNameFromCode('UP'), equals('Uttar Pradesh'));
      expect(ocrService.getStateNameFromCode('ZZ'), isNull);
    });

    test('Parses raw OCR text containing noisy HSRP artifacts and extracts plate', () {
      const noisyOcr = '''
        IND
        HSRP 09
        DL 01 CA 8821
        INDIA
      ''';

      final result = ocrService.parseRawOcrText(noisyOcr);

      expect(result.hasValidPlate, isTrue);
      expect(result.detectedPlate, equals('DL 01 CA 8821'));
      expect(result.normalizedPlate, equals('DL01CA8821'));
      expect(result.stateCode, equals('DL'));
      expect(result.stateName, equals('Delhi'));
      expect(result.isHsrp, isTrue);
      expect(result.confidence, greaterThanOrEqualTo(0.95));
      expect(result.isHighConfidence, isTrue);
      expect(result.matchedVehicle, isNotNull);
      expect(result.matchedVehicle?.makeModel, contains('Creta'));
    });

    test('Parses Bharat Series (BH) registration plates', () {
      const bhOcr = '22 BH 1234 AA';
      final result = ocrService.parseRawOcrText(bhOcr);

      expect(result.hasValidPlate, isTrue);
      expect(result.detectedPlate, equals('22 BH 1234 AA'));
      expect(result.isHsrp, isTrue);
    });

    test('Identifies stolen vehicle BOLO alert from scanned plate', () {
      final result = ocrService.parseRawOcrText('HR 55 TR 9012');

      expect(result.hasValidPlate, isTrue);
      expect(result.detectedPlate, equals('HR 55 TR 9012'));
      expect(result.isStolenAlert, isTrue);
      expect(result.matchedVehicle, isNotNull);
      expect(result.matchedVehicle?.isStolen, isTrue);
    });

    test('Applies optical character repair heuristics for embossed plates', () {
      // 0L instead of DL, or O instead of 0 in number sequence
      const misreadPlate = '0L 01 CA 882O';
      final result = ocrService.parseRawOcrText(misreadPlate);

      expect(result.hasValidPlate, isTrue);
      expect(result.normalizedPlate, equals('DL01CA8820'));
    });

    test('Logs immutable audit trail for every ANPR OCR scan', () {
      final initialLogsCount = AuditService.instance.recentLogs.length;

      ocrService.parseRawOcrText('KA 04 MH 7711');

      final newLogs = AuditService.instance.recentLogs;
      expect(newLogs.length, greaterThan(initialLogsCount));

      final latestLog = newLogs.first;
      expect(latestLog.actionType, contains('SEARCH'));
      expect(latestLog.targetIdentifier, contains('KA 04 MH 7711'));
    });
  });
}
