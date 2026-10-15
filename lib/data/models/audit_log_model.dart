class AuditLogEntry {
  final String id;
  final DateTime timestamp;
  final String actionType; // 'VEHICLE_SEARCH', 'DL_SEARCH', 'CHALLAN_ISSUED', 'CHALLAN_PAID', 'VEHICLE_IMPOUND'
  final String officerBadge;
  final String officerName;
  final String targetIdentifier; // e.g. 'DL 01 CA 8821', 'DL-0420190012345', 'DL-ECH-2024-892104'
  final String details;
  final String status; // 'SUCCESS', 'ALERT_FLAGGED', 'SETTLED'
  final String? location;

  const AuditLogEntry({
    required this.id,
    required this.timestamp,
    required this.actionType,
    required this.officerBadge,
    required this.officerName,
    required this.targetIdentifier,
    required this.details,
    required this.status,
    this.location,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'actionType': actionType,
    'officerBadge': officerBadge,
    'officerName': officerName,
    'targetIdentifier': targetIdentifier,
    'details': details,
    'status': status,
    'location': location,
  };
}
