import 'dart:async';
import '../../domain/services/i_audit_service.dart';
import '../models/audit_log_model.dart';
import '../models/challan_model.dart';

class AuditService implements IAuditService {
  AuditService._internal();
  static final AuditService _instance = AuditService._internal();
  static AuditService get instance => _instance;

  final List<AuditLogEntry> _logs = [
    AuditLogEntry(
      id: 'AUD-INIT-001',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      actionType: 'LOGIN',
      officerBadge: 'TP-8429',
      officerName: 'Insp. Rajesh Kumar',
      targetIdentifier: 'TP-8429',
      details: 'Officer verified credentials via OTP & started shift A.',
      status: 'SUCCESS',
      location: 'Connaught Place Traffic Division',
    ),
  ];

  final StreamController<List<AuditLogEntry>> _logStreamController =
      StreamController<List<AuditLogEntry>>.broadcast();

  Stream<List<AuditLogEntry>> get auditStream => _logStreamController.stream;

  List<AuditLogEntry> get currentLogs => List.unmodifiable(_logs);
  List<AuditLogEntry> get recentLogs => currentLogs;

  @override
  Future<void> logEntry(AuditLogEntry entry) async {
    _logs.insert(0, entry);
    _logStreamController.add(List.unmodifiable(_logs));
  }

  @override
  Future<void> logSearch({
    required String queryType,
    required String queryValue,
    required bool found,
    required String officerBadge,
    required String officerName,
    String? location,
  }) async {
    final entry = AuditLogEntry(
      id: 'AUD-${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      actionType: '${queryType.toUpperCase()}_SEARCH',
      officerBadge: officerBadge,
      officerName: officerName,
      targetIdentifier: queryValue,
      details: found
          ? '$queryType search matched registry record for $queryValue'
          : '$queryType search returned 0 results for $queryValue',
      status: found ? 'SUCCESS' : 'NOT_FOUND',
      location: location ?? 'Field Unit Mobile App',
    );
    await logEntry(entry);
  }

  @override
  Future<void> logChallanIssued({
    required ChallanModel challan,
    required String officerBadge,
    required String officerName,
  }) async {
    final entry = AuditLogEntry(
      id: 'AUD-${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      actionType: 'CHALLAN_ISSUED',
      officerBadge: officerBadge,
      officerName: officerName,
      targetIdentifier: challan.challanNumber,
      details:
          'Statutory e-Challan of ₹${challan.totalFine.toStringAsFixed(0)} issued for ${challan.vehicleNumber} (${challan.offenses.length} offenses).',
      status: 'VIOLATION_RECORDED',
      location: challan.location,
    );
    await logEntry(entry);
  }

  @override
  Future<void> logPayment({
    required String challanNumber,
    required double amount,
    required String paymentMode,
    required String officerBadge,
    required String officerName,
  }) async {
    final entry = AuditLogEntry(
      id: 'AUD-${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      actionType: 'CHALLAN_PAID',
      officerBadge: officerBadge,
      officerName: officerName,
      targetIdentifier: challanNumber,
      details:
          'Payment of ₹${amount.toStringAsFixed(0)} settled via $paymentMode.',
      status: 'SETTLED',
      location: 'Field POS Collection Point',
    );
    await logEntry(entry);
  }

  @override
  Future<void> logImpound({
    required String vehicleNumber,
    required String reason,
    required String officerBadge,
    required String officerName,
  }) async {
    final entry = AuditLogEntry(
      id: 'AUD-${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      actionType: 'VEHICLE_IMPOUND',
      officerBadge: officerBadge,
      officerName: officerName,
      targetIdentifier: vehicleNumber,
      details: 'Impound memo filed for $vehicleNumber. Reason: $reason',
      status: 'ALERT_FLAGGED',
      location: 'Jurisdictional Impound Yard',
    );
    await logEntry(entry);
  }

  @override
  Future<List<AuditLogEntry>> getAuditLogs({int limit = 100}) async {
    return _logs.take(limit).toList();
  }

  /// Reset logs (primarily for testing)
  void resetForTest() {
    _logs.clear();
  }
}
