import 'vehicle_model.dart';

/// Represents the extracted and analyzed result from an ANPR (Automatic Number Plate Recognition) scan.
class PlateScanResult {
  final String rawText;
  final String? detectedPlate;
  final String? normalizedPlate;
  final double confidence;
  final String? stateCode;
  final String? stateName;
  final bool isHsrp;
  final String? vehicleClassHint;
  final DateTime scannedAt;
  final String? imagePath;
  final VehicleModel? matchedVehicle;

  const PlateScanResult({
    required this.rawText,
    this.detectedPlate,
    this.normalizedPlate,
    this.confidence = 0.0,
    this.stateCode,
    this.stateName,
    this.isHsrp = false,
    this.vehicleClassHint,
    required this.scannedAt,
    this.imagePath,
    this.matchedVehicle,
  });

  /// True if a valid Indian license plate was successfully identified
  bool get hasValidPlate => detectedPlate != null && detectedPlate!.isNotEmpty;

  /// True if optical confidence meets the auto-search threshold (95%+)
  bool get isHighConfidence => confidence >= 0.95;

  /// Check if the scanned vehicle has a stolen/wanted BOLO alert
  bool get isStolenAlert => matchedVehicle?.isStolen == true;

  PlateScanResult copyWith({
    String? rawText,
    String? detectedPlate,
    String? normalizedPlate,
    double? confidence,
    String? stateCode,
    String? stateName,
    bool? isHsrp,
    String? vehicleClassHint,
    DateTime? scannedAt,
    String? imagePath,
    VehicleModel? matchedVehicle,
  }) {
    return PlateScanResult(
      rawText: rawText ?? this.rawText,
      detectedPlate: detectedPlate ?? this.detectedPlate,
      normalizedPlate: normalizedPlate ?? this.normalizedPlate,
      confidence: confidence ?? this.confidence,
      stateCode: stateCode ?? this.stateCode,
      stateName: stateName ?? this.stateName,
      isHsrp: isHsrp ?? this.isHsrp,
      vehicleClassHint: vehicleClassHint ?? this.vehicleClassHint,
      scannedAt: scannedAt ?? this.scannedAt,
      imagePath: imagePath ?? this.imagePath,
      matchedVehicle: matchedVehicle ?? this.matchedVehicle,
    );
  }
}
