import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_police_app/data/services/auth_service.dart';

void main() {
  late AuthService authService;

  setUp(() {
    authService = AuthService();
    authService.logout();
  });

  group('Phase 3: Inspector Authentication & Whitelist Tests', () {
    test('Rejects non-whitelisted mobile and email', () async {
      final res = await authService.requestOtp(
        mobile: '9999999999',
        email: 'unauthorized@civilian.com',
      );

      expect(res.isSuccess, isFalse);
      expect(res.message, contains('Access Denied'));
      expect(authService.isAuthenticated, isFalse);
    });

    test('Accepts admin-whitelisted inspector credentials', () async {
      final res = await authService.requestOtp(
        mobile: '9876543210',
        email: 'rajesh.kumar@delhipolice.gov.in',
      );

      expect(res.isSuccess, isTrue);
      expect(res.message, contains('dispatched to +91 9876543210'));
    });

    test('Validates correct 6-digit OTP and authenticates officer', () async {
      await authService.requestOtp(
        mobile: '9876543210',
        email: 'rajesh.kumar@delhipolice.gov.in',
      );

      final verifyRes = await authService.verifyOtp(otp: '123456');

      expect(verifyRes.isSuccess, isTrue);
      expect(authService.isAuthenticated, isTrue);
      expect(authService.currentInspector?.badgeNumber, 'TP-8429');
    });

    test('Locks out after 3 wrong OTP attempts', () async {
      await authService.requestOtp(
        mobile: '9876543210',
        email: 'rajesh.kumar@delhipolice.gov.in',
      );

      // Attempt 1
      var res = await authService.verifyOtp(otp: '000000');
      expect(res.isSuccess, isFalse);
      expect(res.remainingAttempts, 2);
      expect(authService.isLockedOut, isFalse);

      // Attempt 2
      res = await authService.verifyOtp(otp: '000000');
      expect(res.isSuccess, isFalse);
      expect(res.remainingAttempts, 1);
      expect(authService.isLockedOut, isFalse);

      // Attempt 3 -> Should trigger security lockout
      res = await authService.verifyOtp(otp: '000000');
      expect(res.isSuccess, isFalse);
      expect(res.isLockedOut, isTrue);
      expect(authService.isLockedOut, isTrue);
      expect(res.message, contains('locked'));
    });

    test('Verifies Quick 4-digit PIN authentication', () async {
      final pinRes = await authService.verifyQuickPin(pin: '8429');
      expect(pinRes.isSuccess, isTrue);
      expect(authService.isAuthenticated, isTrue);
    });

    test('Verifies Admin Palanshu credentials and PIN 7433 authentication', () async {
      // 1. Whitelist verification
      expect(authService.isWhitelisted('9335787433', 'palanshu768@gmail.com'), isTrue);

      // 2. OTP flow with Admin credentials
      final reqRes = await authService.requestOtp(
        mobile: '9335787433',
        email: 'palanshu768@gmail.com',
      );
      expect(reqRes.isSuccess, isTrue);
      expect(reqRes.message, contains('dispatched to +91 9335787433'));

      final verifyRes = await authService.verifyOtp(otp: '123456');
      expect(verifyRes.isSuccess, isTrue);
      expect(authService.isAuthenticated, isTrue);
      expect(authService.currentInspector?.name, 'Admin Palanshu');
      expect(authService.currentInspector?.phone, '+91 93357 87433');
      expect(authService.currentInspector?.email, 'palanshu768@gmail.com');
      expect(authService.currentInspector?.badgeNumber, 'TP-7433');

      // 3. Quick PIN 7433
      authService.logout();
      final pinRes = await authService.verifyQuickPin(pin: '7433');
      expect(pinRes.isSuccess, isTrue);
      expect(authService.isAuthenticated, isTrue);
      expect(authService.currentInspector?.name, 'Admin Palanshu');
    });

    test('Verifies fast Biometric authentication', () async {
      final bioRes = await authService.authenticateWithBiometrics();
      expect(bioRes.isSuccess, isTrue);
      expect(authService.isAuthenticated, isTrue);
    });
  });
}
