import '../../data/models/vehicle_model.dart';

abstract class IVehicleService {
  /// Search vehicle by Indian registration number (e.g. DL 01 CA 8821)
  Future<VehicleModel?> searchByRegistration(String regNo);

  /// Search vehicle by Chassis number / VIN
  Future<VehicleModel?> searchByChassis(String chassisNo);

  /// Search vehicle by Engine number
  Future<VehicleModel?> searchByEngine(String engineNo);

  /// General search matching registration, chassis, engine, or owner name
  Future<List<VehicleModel>> searchGeneral(String query, {VehicleType? typeFilter});

  /// Retrieve all registered vehicles
  Future<List<VehicleModel>> getAllVehicles();
}
