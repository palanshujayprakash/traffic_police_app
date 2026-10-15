class ViolationOffense {
  final String id;
  final String section;
  final String title;
  final String description;
  final double statutoryFine;

  const ViolationOffense({
    required this.id,
    required this.section,
    required this.title,
    required this.description,
    required this.statutoryFine,
  });
}

class ChallanModel {
  final String challanNumber;
  final String vehicleNumber;
  final String vehicleModel;
  final String? driverName;
  final String? dlNumber;
  final DateTime issuedAt;
  final String location;
  final List<ViolationOffense> offenses;
  final double totalFine;
  final bool isPaid;
  final String? paymentMode;
  final DateTime? paymentDate;
  final String? transactionId;
  final String officerName;
  final String officerBadge;
  final String? evidencePhotoUrl;
  final double? latitude;
  final double? longitude;

  const ChallanModel({
    required this.challanNumber,
    required this.vehicleNumber,
    required this.vehicleModel,
    this.driverName,
    this.dlNumber,
    required this.issuedAt,
    required this.location,
    required this.offenses,
    required this.totalFine,
    this.isPaid = false,
    this.paymentMode,
    this.paymentDate,
    this.transactionId,
    required this.officerName,
    required this.officerBadge,
    this.evidencePhotoUrl,
    this.latitude,
    this.longitude,
  });

  ChallanModel copyWith({
    String? challanNumber,
    String? vehicleNumber,
    String? vehicleModel,
    String? driverName,
    String? dlNumber,
    DateTime? issuedAt,
    String? location,
    List<ViolationOffense>? offenses,
    double? totalFine,
    bool? isPaid,
    String? paymentMode,
    DateTime? paymentDate,
    String? transactionId,
    String? officerName,
    String? officerBadge,
    String? evidencePhotoUrl,
    double? latitude,
    double? longitude,
  }) {
    return ChallanModel(
      challanNumber: challanNumber ?? this.challanNumber,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      driverName: driverName ?? this.driverName,
      dlNumber: dlNumber ?? this.dlNumber,
      issuedAt: issuedAt ?? this.issuedAt,
      location: location ?? this.location,
      offenses: offenses ?? this.offenses,
      totalFine: totalFine ?? this.totalFine,
      isPaid: isPaid ?? this.isPaid,
      paymentMode: paymentMode ?? this.paymentMode,
      paymentDate: paymentDate ?? this.paymentDate,
      transactionId: transactionId ?? this.transactionId,
      officerName: officerName ?? this.officerName,
      officerBadge: officerBadge ?? this.officerBadge,
      evidencePhotoUrl: evidencePhotoUrl ?? this.evidencePhotoUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  /// Deep link string for UPI QR code generation
  String get upiPaymentUrl {
    final cleanFine = totalFine.toStringAsFixed(2);
    final upiId = 'trafficpolice.delhi@sbi';
    final payeeName = Uri.encodeComponent('Delhi Traffic Police Enforcement');
    final note = Uri.encodeComponent('Challan $challanNumber for $vehicleNumber');
    return 'upi://pay?pa=$upiId&pn=$payeeName&am=$cleanFine&cu=INR&tn=$note';
  }
}
