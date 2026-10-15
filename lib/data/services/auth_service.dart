import 'dart:async';
import '../../core/config/app_config.dart';
import '../models/inspector_model.dart';
import '../repositories/mock_data_repository.dart';

class AuthResult {
  final bool isSuccess;
  final String? message;
  final bool isLockedOut;
  final int remainingAttempts;
  final Duration? lockoutRemaining;
  final String? otpCode;

  const AuthResult({
    required this.isSuccess,
    this.message,
    this.isLockedOut = false,
    this.remainingAttempts = 3,
    this.lockoutRemaining,
    this.otpCode,
  });

  factory AuthResult.success([String? message, String? otpCode]) => AuthResult(
        isSuccess: true,
        message: message,
        otpCode: otpCode,
        remainingAttempts: AppConfig.maxOtpAttempts,
      );

  factory AuthResult.failure(String message, {int remaining = 3}) => AuthResult(
        isSuccess: false,
        message: message,
        remainingAttempts: remaining,
      );

  factory AuthResult.lockedOut(Duration remaining) => AuthResult(
        isSuccess: false,
        isLockedOut: true,
        message: 'Account locked due to 3 failed attempts. Try again in ${remaining.inMinutes + 1} minutes.',
        remainingAttempts: 0,
        lockoutRemaining: remaining,
      );
}

class OfficerWhitelistEntry {
  final String mobile;
  final String email;
  final String badgeNumber;
  final String name;
  final String quickPin;

  const OfficerWhitelistEntry({
    required this.mobile,
    required this.email,
    required this.badgeNumber,
    required this.name,
    required this.quickPin,
  });
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Registered inspector whitelist (only admin-approved traffic officers can access)
  static final List<OfficerWhitelistEntry> adminWhitelist = [
    const OfficerWhitelistEntry(
      mobile: '9335787433',
      email: 'palanshu768@gmail.com',
      badgeNumber: 'TP-7433',
      name: 'Admin Palanshu (HQ)',
      quickPin: '7433',
    ),
    const OfficerWhitelistEntry(
      mobile: '9876543210',
      email: 'rajesh.kumar@delhipolice.gov.in',
      badgeNumber: 'TP-8429',
      name: 'Insp. Rajesh Kumar',
      quickPin: '8429',
    ),
    const OfficerWhitelistEntry(
      mobile: '9876543210',
      email: 'inspector.kiran@trafficpolice.gov.in',
      badgeNumber: 'TP-8429',
      name: 'Insp. Rajesh Kumar',
      quickPin: '8429',
    ),
    const OfficerWhitelistEntry(
      mobile: '9811234567',
      email: 'amit.verma@delhipolice.gov.in',
      badgeNumber: 'TP-9102',
      name: 'Sub-Insp. Amit Verma',
      quickPin: '9102',
    ),
  ];

  static void addWhitelistEntry(OfficerWhitelistEntry entry) {
    adminWhitelist.removeWhere((e) => e.badgeNumber == entry.badgeNumber);
    adminWhitelist.add(entry);
  }

  static void removeWhitelistEntry(String badgeNumber) {
    adminWhitelist.removeWhere((e) => e.badgeNumber == badgeNumber);
  }

  static bool isWhitelistedBadge(String badgeNumber) {
    return adminWhitelist.any((e) => e.badgeNumber == badgeNumber);
  }

  // State
  String? _pendingMobile;
  String? _pendingEmail;
  String? _generatedOtp;
  DateTime? _otpGeneratedAt;
  int _failedAttempts = 0;
  DateTime? _lockoutUntil;
  bool _isAuthenticated = false;
  InspectorModel? _currentInspector;

  bool get isAuthenticated => _isAuthenticated;
  InspectorModel? get currentInspector => _currentInspector;
  String? get pendingMobile => _pendingMobile;
  String? get pendingEmail => _pendingEmail;
  String? get generatedOtp => _generatedOtp;
  int get remainingAttempts => (AppConfig.maxOtpAttempts - _failedAttempts).clamp(0, AppConfig.maxOtpAttempts);

  /// Check if officer account is currently locked out
  bool get isLockedOut {
    if (_lockoutUntil == null) return false;
    if (DateTime.now().isBefore(_lockoutUntil!)) {
      return true;
    }
    // Lockout expired, reset
    _lockoutUntil = null;
    _failedAttempts = 0;
    return false;
  }

  Duration get remainingLockoutTime {
    if (_lockoutUntil == null) return Duration.zero;
    final diff = _lockoutUntil!.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Check if the credentials belong to an admin-registered inspector
  bool isWhitelisted(String mobile, String email) {
    final cleanMobile = mobile.replaceAll(RegExp(r'\D'), '');
    final cleanEmail = email.trim().toLowerCase();

    return adminWhitelist.any((officer) {
      final officerMobile = officer.mobile.replaceAll(RegExp(r'\D'), '');
      final officerEmail = officer.email.toLowerCase();
      return officerMobile == cleanMobile || officerEmail == cleanEmail;
    });
  }

  /// Step 1: Request 6-Digit OTP
  Future<AuthResult> requestOtp({required String mobile, required String email}) async {
    if (isLockedOut) {
      return AuthResult.lockedOut(remainingLockoutTime);
    }

    final cleanMobile = mobile.replaceAll(RegExp(r'\D'), '');
    final cleanEmail = email.trim().toLowerCase();

    if (cleanMobile.length < 10) {
      return AuthResult.failure('Please enter a valid 10-digit mobile number.');
    }

    if (!cleanEmail.contains('@')) {
      return AuthResult.failure('Please enter a valid police email address.');
    }

    // Check Whitelist
    if (!isWhitelisted(cleanMobile, cleanEmail)) {
      return AuthResult.failure(
        'Access Denied: Officer not registered in Police Department Whitelist. Contact Traffic Admin.',
      );
    }

    _pendingMobile = cleanMobile;
    _pendingEmail = cleanEmail;

    // Generate dynamic 6-digit OTP
    final randomCode = (100000 + (DateTime.now().microsecondsSinceEpoch % 900000)).toString();
    _generatedOtp = randomCode;
    _otpGeneratedAt = DateTime.now();

    return AuthResult.success('6-digit OTP dispatched to +91 $cleanMobile.', _generatedOtp);
  }

  /// Step 2: Verify OTP with 5-minute expiry and 3-attempt lockout
  Future<AuthResult> verifyOtp({required String otp}) async {
    if (isLockedOut) {
      return AuthResult.lockedOut(remainingLockoutTime);
    }

    if (_generatedOtp == null || _otpGeneratedAt == null) {
      return AuthResult.failure('No active OTP request found. Please request a new OTP.');
    }

    // 1. Check 5-minute expiry
    final elapsed = DateTime.now().difference(_otpGeneratedAt!);
    if (elapsed > AppConfig.otpExpiryDuration) {
      _generatedOtp = null;
      return AuthResult.failure('OTP expired (exceeded 5 minutes validity). Please request a new code.');
    }

    // 2. Validate OTP code (accept dynamically generated code or universal test fallback 123456)
    if (otp.trim() == _generatedOtp || otp.trim() == '123456') {
      // Success! Reset security counters
      _failedAttempts = 0;
      _lockoutUntil = null;
      _isAuthenticated = true;
      if (_pendingMobile == '9335787433' || _pendingEmail == 'palanshu768@gmail.com') {
        _currentInspector = MockDataRepository.adminInspector;
      } else {
        final matchedOfficer = adminWhitelist.firstWhere(
          (o) =>
              o.mobile.replaceAll(RegExp(r'\D'), '') == _pendingMobile ||
              o.email.toLowerCase() == _pendingEmail,
          orElse: () => adminWhitelist.first,
        );
        _currentInspector = InspectorModel(
          id: 'INSP-DEL-${matchedOfficer.badgeNumber.replaceAll('TP-', '')}',
          name: matchedOfficer.name,
          rank: 'Traffic Inspector',
          badgeNumber: matchedOfficer.badgeNumber,
          station: 'Barakhamba Road Traffic Division',
          beatLocation: 'Sector 4 — MG Road Junction',
          shift: 'Shift A • 08:00 — 16:00 IST',
          phone: '+91 ${_pendingMobile ?? matchedOfficer.mobile}',
          email: _pendingEmail ?? matchedOfficer.email,
          avatarInitials: matchedOfficer.name.length >= 2
              ? matchedOfficer.name.substring(0, 2).toUpperCase()
              : 'TP',
          vehiclesCheckedToday: 42,
          challansIssuedToday: 12,
          finesCollectedToday: 18500.0,
          isOnDuty: true,
        );
      }
      return AuthResult.success('Officer identity verified. Welcome to Duty Guard.');
    }

    // 3. Handle Wrong OTP Attempt
    _failedAttempts++;
    if (_failedAttempts >= AppConfig.maxOtpAttempts) {
      _lockoutUntil = DateTime.now().add(AppConfig.lockoutDuration);
      return AuthResult.lockedOut(AppConfig.lockoutDuration);
    }

    final remaining = AppConfig.maxOtpAttempts - _failedAttempts;
    return AuthResult.failure(
      'Invalid verification code. $remaining attempt${remaining == 1 ? '' : 's'} remaining before lockout.',
      remaining: remaining,
    );
  }

  /// Quick Re-Authentication via 4-Digit Security PIN
  Future<AuthResult> verifyQuickPin({required String pin}) async {
    if (isLockedOut) {
      return AuthResult.lockedOut(remainingLockoutTime);
    }

    // Admin PIN is 7433 (Admin Palanshu)
    if (pin.trim() == '7433') {
      _failedAttempts = 0;
      _isAuthenticated = true;
      _currentInspector = MockDataRepository.adminInspector;
      return AuthResult.success('Admin Palanshu authenticated.');
    }

    // Default inspector PIN is 8429 (Insp. Rajesh Kumar)
    if (pin.trim() == '8429') {
      _failedAttempts = 0;
      _isAuthenticated = true;
      _currentInspector = MockDataRepository.activeInspector;
      return AuthResult.success('Quick PIN verified.');
    }

    _failedAttempts++;
    if (_failedAttempts >= AppConfig.maxOtpAttempts) {
      _lockoutUntil = DateTime.now().add(AppConfig.lockoutDuration);
      return AuthResult.lockedOut(AppConfig.lockoutDuration);
    }

    final remaining = AppConfig.maxOtpAttempts - _failedAttempts;
    return AuthResult.failure('Incorrect 4-digit PIN. $remaining attempts remaining.', remaining: remaining);
  }

  /// Fast Pass: Biometric / FaceID Authentication
  Future<AuthResult> authenticateWithBiometrics() async {
    if (isLockedOut) {
      return AuthResult.lockedOut(remainingLockoutTime);
    }

    // Simulate successful on-device biometric match
    _failedAttempts = 0;
    _isAuthenticated = true;
    if (_pendingMobile == '9876543210' || _pendingEmail?.contains('rajesh') == true) {
      _currentInspector = MockDataRepository.activeInspector;
    } else {
      _currentInspector = MockDataRepository.adminInspector;
    }
    return AuthResult.success('Biometric authentication confirmed for ${_currentInspector?.name}.');
  }

  /// Sign out officer and revoke session
  void logout() {
    _isAuthenticated = false;
    _currentInspector = null;
    _pendingMobile = null;
    _pendingEmail = null;
    _generatedOtp = null;
    _otpGeneratedAt = null;
    _failedAttempts = 0;
    _lockoutUntil = null;
  }
}
