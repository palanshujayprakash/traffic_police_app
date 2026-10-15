import '../../data/models/audit_log_model.dart';
import '../../data/models/challan_model.dart';

abstract class IAuditService {
  /// Record a general audit log entry
  Future<void> logEntry(AuditLogEntry entry);

  /// Record vehicle or driver license search action
  Future<void> logSearch({
    required String queryType,
    required String queryValue,
    required bool found,
    required String officerBadge,
    required String officerName,
    String? location,
  });

  /// Record citation issuance
  Future<void> logChallanIssued({
    required ChallanModel challan,
    required String officerBadge,
    required String officerName,
  });

  /// Record fine payment settlement
  Future<void> logPayment({
    required String challanNumber,
    required double amount,
    required String paymentMode,
    required String officerBadge,
    required String officerName,
  });

  /// Record vehicle seizure or impound memo
  Future<void> logImpound({
    required String vehicleNumber,
    required String reason,
    required String officerBadge,
    required String officerName,
  });

  /// Fetch all historical audit logs
  Future<List<AuditLogEntry>> getAuditLogs({int limit = 100});
}
