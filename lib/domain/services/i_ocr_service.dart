import '../../data/models/plate_scan_result.dart';

/// Abstract service interface for Automatic Number Plate Recognition (ANPR) and OCR processing.
abstract class IOcrService {
  /// Processes an image from local storage or camera capture using OCR.
  Future<PlateScanResult> processImage(String imagePath);

  /// Parses raw OCR string output, cleans noise, resolves heuristics, and formats the plate.
  PlateScanResult parseRawOcrText(String rawText, {String? imagePath});

  /// Normalizes plate string by stripping whitespace, dashes, and invalid characters.
  String normalizePlate(String input);

  /// Formats a normalized registration number with proper spacing (e.g. DL01CA8821 -> DL 01 CA 8821).
  String formatPlate(String normalized);

  /// Validates whether the given string conforms to Indian Motor Vehicle Registration standards.
  bool isValidIndianPlate(String input);

  /// Resolves the 2-letter state code into full State/UT name (e.g. DL -> Delhi).
  String? getStateNameFromCode(String code);

  /// Returns list of all official Indian state and Union Territory RTO prefix codes.
  List<String> get supportedStateCodes;
}
