import '../../domain/services/i_vehicle_service.dart';
import '../models/vehicle_model.dart';
import '../repositories/mock_data_repository.dart';
import 'audit_service.dart';

class VehicleService implements IVehicleService {
  VehicleService._internal();
  static final VehicleService _instance = VehicleService._internal();
  static VehicleService get instance => _instance;

  final AuditService _auditService = AuditService.instance;

  /// Helper to sanitize search strings (removes spaces, hyphens, and standardizes uppercase)
  String _normalize(String input) {
    return input.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
  }

  /// Synchronous in-memory lookup for fast OCR plate resolution
  VehicleModel? searchByPlate(String regNo) {
    final clean = _normalize(regNo);
    if (clean.isEmpty) return null;
    return MockDataRepository.mockVehicles.cast<VehicleModel?>().firstWhere(
      (v) => v != null && _normalize(v.registrationNumber) == clean,
      orElse: () => null,
    );
  }

  @override
  Future<VehicleModel?> searchByRegistration(String regNo) async {
    final clean = _normalize(regNo);
    if (clean.isEmpty) return null;

    final match = MockDataRepository.mockVehicles.cast<VehicleModel?>().firstWhere(
      (v) => v != null && _normalize(v.registrationNumber) == clean,
      orElse: () => null,
    );

    await _auditService.logSearch(
      queryType: 'REGISTRATION',
      queryValue: regNo.trim().toUpperCase(),
      found: match != null,
      officerBadge: MockDataRepository.activeInspector.badgeNumber,
      officerName: MockDataRepository.activeInspector.name,
    );

    return match;
  }

  @override
  Future<VehicleModel?> searchByChassis(String chassisNo) async {
    final clean = _normalize(chassisNo);
    if (clean.isEmpty) return null;

    final match = MockDataRepository.mockVehicles.cast<VehicleModel?>().firstWhere(
      (v) => v != null && _normalize(v.chassisNumber).contains(clean),
      orElse: () => null,
    );

    await _auditService.logSearch(
      queryType: 'CHASSIS',
      queryValue: chassisNo.trim().toUpperCase(),
      found: match != null,
      officerBadge: MockDataRepository.activeInspector.badgeNumber,
      officerName: MockDataRepository.activeInspector.name,
    );

    return match;
  }

  @override
  Future<VehicleModel?> searchByEngine(String engineNo) async {
    final clean = _normalize(engineNo);
    if (clean.isEmpty) return null;

    final match = MockDataRepository.mockVehicles.cast<VehicleModel?>().firstWhere(
      (v) => v != null && _normalize(v.engineNumber).contains(clean),
      orElse: () => null,
    );

    await _auditService.logSearch(
      queryType: 'ENGINE',
      queryValue: engineNo.trim().toUpperCase(),
      found: match != null,
      officerBadge: MockDataRepository.activeInspector.badgeNumber,
      officerName: MockDataRepository.activeInspector.name,
    );

    return match;
  }

  @override
  Future<List<VehicleModel>> searchGeneral(String query, {VehicleType? typeFilter}) async {
    final clean = _normalize(query);
    final rawUpper = query.trim().toUpperCase();

    var results = MockDataRepository.mockVehicles;

    if (clean.isNotEmpty) {
      results = results.where((v) {
        final matchReg = _normalize(v.registrationNumber).contains(clean);
        final matchChassis = _normalize(v.chassisNumber).contains(clean);
        final matchEngine = _normalize(v.engineNumber).contains(clean);
        final matchOwner = v.ownerName.toUpperCase().contains(rawUpper);
        final matchModel = v.makeModel.toUpperCase().contains(rawUpper);
        return matchReg || matchChassis || matchEngine || matchOwner || matchModel;
      }).toList();
    }

    if (typeFilter != null) {
      results = results.where((v) => v.type == typeFilter).toList();
    }

    if (query.trim().isNotEmpty) {
      await _auditService.logSearch(
        queryType: 'GENERAL_VEHICLE',
        queryValue: query.trim(),
        found: results.isNotEmpty,
        officerBadge: MockDataRepository.activeInspector.badgeNumber,
        officerName: MockDataRepository.activeInspector.name,
      );
    }

    return results;
  }

  @override
  Future<List<VehicleModel>> getAllVehicles() async {
    return List.unmodifiable(MockDataRepository.mockVehicles);
  }

  /// Update vehicle record in repository (e.g., after challan or impound)
  void updateVehicle(VehicleModel updatedVehicle) {
    final clean = _normalize(updatedVehicle.registrationNumber);
    final index = MockDataRepository.mockVehicles.indexWhere(
      (v) => _normalize(v.registrationNumber) == clean,
    );
    if (index != -1) {
      MockDataRepository.mockVehicles[index] = updatedVehicle;
    }
  }
}
