import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_police_app/core/localization/app_localization.dart';
import 'package:traffic_police_app/data/models/challan_model.dart';
import 'package:traffic_police_app/data/services/auth_service.dart';
import 'package:traffic_police_app/data/services/challan_service.dart';
import 'package:traffic_police_app/data/services/offline_sync_service.dart';

void main() {
  group('Phase 6: OfflineSyncService Unit Tests', () {
    late OfflineSyncService syncService;

    setUp(() {
      syncService = OfflineSyncService.instance;
      syncService.clearQueue();
      syncService.setOfflineMode(false);
    });

    tearDown(() {
      syncService.clearQueue();
      syncService.setOfflineMode(false);
    });

    test('Initial state has 0 pending items and offline mode is false', () {
      expect(syncService.pendingCount, 0);
      expect(syncService.isOfflineMode, false);
      expect(syncService.pendingChallans, isEmpty);
    });

    test('Toggling simulated offline mode updates isOfflineMode', () {
      syncService.setOfflineMode(true);
      expect(syncService.isOfflineMode, true);

      syncService.setOfflineMode(false);
      expect(syncService.isOfflineMode, false);
    });

    test('Queueing offline challan adds to pending list and emits on queueStream', () async {
      final sampleChallan = ChallanModel(
        challanNumber: 'TEST-OFFLINE-001',
        vehicleNumber: 'DL01AB1234',
        vehicleModel: 'Hyundai Creta',
        issuedAt: DateTime.now(),
        location: 'Kashmere Gate ISBT',
        offenses: const [
          ViolationOffense(
            id: 'OFF-1',
            section: '129',
            title: 'No Helmet',
            description: 'Riding two-wheeler without helmet',
            statutoryFine: 1000,
          ),
        ],
        totalFine: 1000,
        officerName: 'Insp. Vikram Rathore',
        officerBadge: 'DL-TP-8429',
      );

      final streamFuture = expectLater(
        syncService.queueStream,
        emits(hasLength(1)),
      );

      await syncService.queueOfflineChallan(sampleChallan);

      expect(syncService.pendingCount, 1);
      expect(syncService.pendingChallans.first.challanNumber, 'TEST-OFFLINE-001');
      await streamFuture;
    });

    test('syncPendingQueue transfers all queued citations to central ChallanService', () async {
      final sampleChallan1 = ChallanModel(
        challanNumber: 'TEST-OFFLINE-101',
        vehicleNumber: 'DL01AB1001',
        vehicleModel: 'Maruti Brezza',
        issuedAt: DateTime.now(),
        location: 'AIIMS Flyover',
        offenses: const [],
        totalFine: 500,
        officerName: 'Insp. Vikram Rathore',
        officerBadge: 'DL-TP-8429',
      );

      final sampleChallan2 = ChallanModel(
        challanNumber: 'TEST-OFFLINE-102',
        vehicleNumber: 'DL02CD2002',
        vehicleModel: 'Tata Nexon',
        issuedAt: DateTime.now(),
        location: 'Dhaula Kuan',
        offenses: const [],
        totalFine: 1500,
        officerName: 'Insp. Vikram Rathore',
        officerBadge: 'DL-TP-8429',
      );

      await syncService.queueOfflineChallan(sampleChallan1);
      await syncService.queueOfflineChallan(sampleChallan2);
      expect(syncService.pendingCount, 2);

      final syncedCount = await syncService.syncPendingQueue();
      expect(syncedCount, 2);
      expect(syncService.pendingCount, 0);

      // Verify central ChallanService now contains these challans
      final fetched1 = await ChallanService.instance.getChallanByNumber('TEST-OFFLINE-101');
      final fetched2 = await ChallanService.instance.getChallanByNumber('TEST-OFFLINE-102');
      expect(fetched1, isNotNull);
      expect(fetched2, isNotNull);
      expect(fetched1?.vehicleNumber, 'DL01AB1001');
      expect(fetched2?.vehicleNumber, 'DL02CD2002');
    });

    test('Syncing an empty queue returns 0 without error', () async {
      final synced = await syncService.syncPendingQueue();
      expect(synced, 0);
    });
  });

  group('Phase 6: AppLocalizationService Unit Tests', () {
    late AppLocalizationService loc;

    setUp(() {
      loc = AppLocalizationService.instance;
      loc.setLanguage(AppLanguage.english);
    });

    tearDown(() {
      loc.setLanguage(AppLanguage.english);
    });

    test('Default language is English with correct translations', () {
      expect(loc.currentLanguage, AppLanguage.english);
      expect(loc.isHindi, false);
      expect(loc.languageCode, 'en');

      expect(loc.tr('app_title'), 'Traffic Police Assistant');
      expect(loc.tr('home'), 'Home');
      expect(loc.tr('challan'), 'Issue Challan');
      expect(loc.tr('vahan_lookup'), 'Instant VAHAN Lookup');
      expect('admin_command'.tr(), 'Command HQ Admin Panel');
    });

    test('Switching to Hindi yields accurate Hindi translations', () {
      loc.setLanguage(AppLanguage.hindi);
      expect(loc.currentLanguage, AppLanguage.hindi);
      expect(loc.isHindi, true);
      expect(loc.languageCode, 'hi');

      expect(loc.tr('app_title'), 'ट्रैफिक पुलिस सहायक');
      expect(loc.tr('home'), 'होम');
      expect(loc.tr('challan'), 'चालान जारी करें');
      expect('vahan_lookup'.tr(), 'तुरंत वाहन खोज');
      expect('admin_command'.tr(), 'मुख्यालय कमांड एडमिन पैनल');
    });

    test('Fallback returned when key is not registered', () {
      expect(loc.tr('unknown_custom_key', fallback: 'Default Text'), 'Default Text');
      expect(loc.tr('unknown_custom_key_without_fallback'), 'unknown_custom_key_without_fallback');
    });

    test('toggleLanguage alternates between English and Hindi', () {
      loc.toggleLanguage();
      expect(loc.isHindi, true);

      loc.toggleLanguage();
      expect(loc.isHindi, false);
    });
  });

  group('Phase 6: Admin Whitelist Management Tests', () {
    test('Default officers are whitelisted', () {
      expect(AuthService.isWhitelistedBadge('TP-8429'), true);
      expect(AuthService.isWhitelistedBadge('TP-9102'), true);
      expect(AuthService.isWhitelistedBadge('NON-EXISTENT-BADGE'), false);
    });

    test('addWhitelistEntry and removeWhitelistEntry operate correctly', () {
      const testBadge = 'TP-9999';
      expect(AuthService.isWhitelistedBadge(testBadge), false);

      const entry = OfficerWhitelistEntry(
        mobile: '9899001122',
        email: 'test.officer@delhipolice.gov.in',
        badgeNumber: testBadge,
        name: 'Sub-Insp. Test Kumar',
        quickPin: '9999',
      );

      AuthService.addWhitelistEntry(entry);
      expect(AuthService.isWhitelistedBadge(testBadge), true);

      AuthService.removeWhitelistEntry(testBadge);
      expect(AuthService.isWhitelistedBadge(testBadge), false);
    });
  });
}
