import 'dart:async';
import '../../domain/services/i_challan_service.dart';
import '../models/challan_model.dart';
import '../repositories/mock_data_repository.dart';
import 'audit_service.dart';
import 'vehicle_service.dart';

class ChallanService implements IChallanService {
  ChallanService._internal();
  static final ChallanService _instance = ChallanService._internal();
  static ChallanService get instance => _instance;

  final AuditService _auditService = AuditService.instance;
  final VehicleService _vehicleService = VehicleService.instance;

  final StreamController<List<ChallanModel>> _challansStreamController =
      StreamController<List<ChallanModel>>.broadcast();

  Stream<List<ChallanModel>> get challansStream => _challansStreamController.stream;

  String _normalize(String input) {
    return input.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
  }

  @override
  Future<List<ChallanModel>> getChallansForVehicle(String vehicleNumber) async {
    final clean = _normalize(vehicleNumber);
    return MockDataRepository.mockChallanHistory
        .where((c) => _normalize(c.vehicleNumber) == clean)
        .toList();
  }

  @override
  Future<ChallanModel?> getChallanByNumber(String challanNumber) async {
    final clean = _normalize(challanNumber);
    return MockDataRepository.mockChallanHistory.cast<ChallanModel?>().firstWhere(
      (c) => c != null && _normalize(c.challanNumber) == clean,
      orElse: () => null,
    );
  }

  @override
  Future<List<ChallanModel>> getAllChallans({bool? isPaid, String? searchQuery}) async {
    var list = MockDataRepository.mockChallanHistory;

    if (isPaid != null) {
      list = list.where((c) => c.isPaid == isPaid).toList();
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final clean = _normalize(searchQuery);
      final raw = searchQuery.trim().toUpperCase();
      list = list.where((c) {
        final matchNum = _normalize(c.challanNumber).contains(clean);
        final matchPlate = _normalize(c.vehicleNumber).contains(clean);
        final matchDriver = c.driverName?.toUpperCase().contains(raw) ?? false;
        final matchOfficer = c.officerName.toUpperCase().contains(raw);
        return matchNum || matchPlate || matchDriver || matchOfficer;
      }).toList();
    }

    return List.unmodifiable(list);
  }

  @override
  Future<ChallanModel> issueChallan(ChallanModel challan) async {
    // 1. Insert into history
    MockDataRepository.mockChallanHistory.insert(0, challan);

    // 2. Update matching vehicle's pending fines in repository
    final vehicle = await _vehicleService.searchByRegistration(challan.vehicleNumber);
    if (vehicle != null) {
      final updatedVehicle = vehicle.copyWith(
        pendingChallanCount: vehicle.pendingChallanCount + 1,
        pendingChallanAmount: vehicle.pendingChallanAmount + challan.totalFine,
      );
      _vehicleService.updateVehicle(updatedVehicle);
    }

    // 3. Log enforcement action to immutable Audit Service
    await _auditService.logChallanIssued(
      challan: challan,
      officerBadge: challan.officerBadge,
      officerName: challan.officerName,
    );

    _challansStreamController.add(List.unmodifiable(MockDataRepository.mockChallanHistory));
    return challan;
  }

  @override
  Future<ChallanModel> markChallanPaid(
    String challanNumber, {
    required String paymentMode,
    required String transactionId,
  }) async {
    final clean = _normalize(challanNumber);
    final index = MockDataRepository.mockChallanHistory.indexWhere(
      (c) => _normalize(c.challanNumber) == clean,
    );

    if (index == -1) {
      throw ArgumentError('Challan $challanNumber not found');
    }

    final existing = MockDataRepository.mockChallanHistory[index];
    final updated = existing.copyWith(
      isPaid: true,
      paymentMode: paymentMode,
      transactionId: transactionId,
      paymentDate: DateTime.now(),
    );

    MockDataRepository.mockChallanHistory[index] = updated;

    // Adjust vehicle's pending fines
    final vehicle = await _vehicleService.searchByRegistration(updated.vehicleNumber);
    if (vehicle != null) {
      final newCount = vehicle.pendingChallanCount > 0 ? vehicle.pendingChallanCount - 1 : 0;
      final newAmount = vehicle.pendingChallanAmount >= updated.totalFine
          ? vehicle.pendingChallanAmount - updated.totalFine
          : 0.0;
      _vehicleService.updateVehicle(
        vehicle.copyWith(
          pendingChallanCount: newCount,
          pendingChallanAmount: newAmount,
        ),
      );
    }

    // Log settlement audit
    await _auditService.logPayment(
      challanNumber: challanNumber,
      amount: updated.totalFine,
      paymentMode: paymentMode,
      officerBadge: MockDataRepository.activeInspector.badgeNumber,
      officerName: MockDataRepository.activeInspector.name,
    );

    _challansStreamController.add(List.unmodifiable(MockDataRepository.mockChallanHistory));
    return updated;
  }

  @override
  double calculateTotalFine(List<ViolationOffense> offenses) {
    return offenses.fold<double>(0.0, (acc, item) => acc + item.statutoryFine);
  }

  @override
  List<ViolationOffense> getStandardOffenses() {
    return List.unmodifiable(MockDataRepository.standardOffenses);
  }

  /// Ingests an offline queued citation into the central record store
  void addOfflineChallanToCentral(ChallanModel challan) {
    if (!MockDataRepository.mockChallanHistory.any((c) => c.challanNumber == challan.challanNumber)) {
      MockDataRepository.mockChallanHistory.insert(0, challan);
      _challansStreamController.add(List.unmodifiable(MockDataRepository.mockChallanHistory));
    }
  }
}
