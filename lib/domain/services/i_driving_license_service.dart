import '../../data/models/driver_license_model.dart';

abstract class IDrivingLicenseService {
  /// Verify and lookup Driver's License details by DL number
  Future<DriverLicenseModel?> searchByLicenseNumber(String dlNumber);

  /// Retrieve all registered licenses in jurisdiction/cache
  Future<List<DriverLicenseModel>> getAllLicenses();

  /// Check whether license is currently valid, suspended, or expired
  Future<bool> isLicenseValid(String dlNumber);
}
