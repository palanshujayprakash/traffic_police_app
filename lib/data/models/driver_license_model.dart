import '../../core/widgets/status_badge.dart';

class DriverLicenseModel {
  final String dlNumber;
  final String holderName;
  final String fatherName;
  final DateTime dateOfBirth;
  final String address;
  final DateTime issueDate;
  final DateTime validUpto;
  final List<String> authorizedClasses; // e.g. ['MCWG', 'LMV']
  final String bloodGroup;
  final BadgeStatus status;
  final String? suspensionReason;
  final int activePenaltyPoints;

  const DriverLicenseModel({
    required this.dlNumber,
    required this.holderName,
    required this.fatherName,
    required this.dateOfBirth,
    required this.address,
    required this.issueDate,
    required this.validUpto,
    required this.authorizedClasses,
    required this.bloodGroup,
    required this.status,
    this.suspensionReason,
    this.activePenaltyPoints = 0,
  });

  bool get isSuspended => status == BadgeStatus.expired || suspensionReason != null;
  bool get isValid => status == BadgeStatus.valid;
}
