import '../../domain/services/i_driving_license_service.dart';
import '../models/driver_license_model.dart';
import '../repositories/mock_data_repository.dart';
import 'audit_service.dart';

class DrivingLicenseService implements IDrivingLicenseService {
  DrivingLicenseService._internal();
  static final DrivingLicenseService _instance = DrivingLicenseService._internal();
  static DrivingLicenseService get instance => _instance;

  final AuditService _auditService = AuditService.instance;

  String _normalize(String input) {
    return input.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
  }

  @override
  Future<DriverLicenseModel?> searchByLicenseNumber(String dlNumber) async {
    final clean = _normalize(dlNumber);
    if (clean.isEmpty) return null;

    final match = MockDataRepository.mockLicenses.cast<DriverLicenseModel?>().firstWhere(
      (l) => l != null && _normalize(l.dlNumber) == clean,
      orElse: () => null,
    );

    await _auditService.logSearch(
      queryType: 'DRIVING_LICENSE',
      queryValue: dlNumber.trim().toUpperCase(),
      found: match != null,
      officerBadge: MockDataRepository.activeInspector.badgeNumber,
      officerName: MockDataRepository.activeInspector.name,
    );

    return match;
  }

  @override
  Future<List<DriverLicenseModel>> getAllLicenses() async {
    return List.unmodifiable(MockDataRepository.mockLicenses);
  }

  @override
  Future<bool> isLicenseValid(String dlNumber) async {
    final license = await searchByLicenseNumber(dlNumber);
    if (license == null) return false;
    return license.isValid && !license.isSuspended;
  }
}
