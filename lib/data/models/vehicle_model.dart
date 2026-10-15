import '../../core/widgets/status_badge.dart';

enum VehicleType {
  car,
  bike,
  truck,
  bus,
  tractor,
}

extension VehicleTypeExtension on VehicleType {
  String get displayName {
    switch (this) {
      case VehicleType.car:
        return 'Motor Car (LMV)';
      case VehicleType.bike:
        return 'Motorcycle (2-Wheeler)';
      case VehicleType.truck:
        return 'Heavy Goods Vehicle (HGV)';
      case VehicleType.bus:
        return 'Passenger Bus (HMV)';
      case VehicleType.tractor:
        return 'Agricultural Tractor';
    }
  }
}

class VehicleDocument {
  final String title;
  final String documentNumber;
  final String issuer;
  final DateTime validFrom;
  final DateTime validUpto;
  final BadgeStatus status;
  final String notes;

  const VehicleDocument({
    required this.title,
    required this.documentNumber,
    required this.issuer,
    required this.validFrom,
    required this.validUpto,
    required this.status,
    this.notes = '',
  });

  bool get isExpired => status == BadgeStatus.expired;
  bool get isExpiringSoon => status == BadgeStatus.warning;
}

class VehicleModel {
  final String registrationNumber;
  final String chassisNumber;
  final String engineNumber;
  final VehicleType type;
  final String makeModel;
  final String ownerName;
  final String ownerPhone;
  final String color;
  final String fuelType;
  final String emissionNorms;
  final String registrationAuthority;
  final DateTime registrationDate;
  final bool isStolen;
  final String? stolenFirDetails;
  final bool isBlacklisted;
  final String? blacklistReason;
  final List<VehicleDocument> documents;
  final int pendingChallanCount;
  final double pendingChallanAmount;

  const VehicleModel({
    required this.registrationNumber,
    required this.chassisNumber,
    required this.engineNumber,
    required this.type,
    required this.makeModel,
    required this.ownerName,
    required this.ownerPhone,
    required this.color,
    required this.fuelType,
    required this.emissionNorms,
    required this.registrationAuthority,
    required this.registrationDate,
    this.isStolen = false,
    this.stolenFirDetails,
    this.isBlacklisted = false,
    this.blacklistReason,
    required this.documents,
    this.pendingChallanCount = 0,
    this.pendingChallanAmount = 0.0,
  });

  bool get hasExpiredDocuments => documents.any((d) => d.status == BadgeStatus.expired);
  bool get hasExpiringDocuments => documents.any((d) => d.status == BadgeStatus.warning);
  bool get hasPendingChallans => pendingChallanCount > 0;
  bool get isCriticalAlert => isStolen || isBlacklisted;
  String get vehicleClass => type.displayName;
  String get rtoOffice => registrationAuthority;

  VehicleModel copyWith({
    String? registrationNumber,
    String? chassisNumber,
    String? engineNumber,
    VehicleType? type,
    String? makeModel,
    String? ownerName,
    String? ownerPhone,
    String? color,
    String? fuelType,
    String? emissionNorms,
    String? registrationAuthority,
    DateTime? registrationDate,
    bool? isStolen,
    String? stolenFirDetails,
    bool? isBlacklisted,
    String? blacklistReason,
    List<VehicleDocument>? documents,
    int? pendingChallanCount,
    double? pendingChallanAmount,
  }) {
    return VehicleModel(
      registrationNumber: registrationNumber ?? this.registrationNumber,
      chassisNumber: chassisNumber ?? this.chassisNumber,
      engineNumber: engineNumber ?? this.engineNumber,
      type: type ?? this.type,
      makeModel: makeModel ?? this.makeModel,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      color: color ?? this.color,
      fuelType: fuelType ?? this.fuelType,
      emissionNorms: emissionNorms ?? this.emissionNorms,
      registrationAuthority: registrationAuthority ?? this.registrationAuthority,
      registrationDate: registrationDate ?? this.registrationDate,
      isStolen: isStolen ?? this.isStolen,
      stolenFirDetails: stolenFirDetails ?? this.stolenFirDetails,
      isBlacklisted: isBlacklisted ?? this.isBlacklisted,
      blacklistReason: blacklistReason ?? this.blacklistReason,
      documents: documents ?? this.documents,
      pendingChallanCount: pendingChallanCount ?? this.pendingChallanCount,
      pendingChallanAmount: pendingChallanAmount ?? this.pendingChallanAmount,
    );
  }
}
