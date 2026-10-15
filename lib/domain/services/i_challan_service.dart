import '../../data/models/challan_model.dart';

abstract class IChallanService {
  /// Retrieve statutory citations for a specific vehicle registration number
  Future<List<ChallanModel>> getChallansForVehicle(String vehicleNumber);

  /// Find citation by unique e-Challan reference number
  Future<ChallanModel?> getChallanByNumber(String challanNumber);

  /// Retrieve all citations with optional payment filter and search text
  Future<List<ChallanModel>> getAllChallans({bool? isPaid, String? searchQuery});

  /// Submit a newly generated e-Challan citation
  Future<ChallanModel> issueChallan(ChallanModel challan);

  /// Settle and mark citation as paid (cash, POS, UPI)
  Future<ChallanModel> markChallanPaid(
    String challanNumber, {
    required String paymentMode,
    required String transactionId,
  });

  /// Compute total fine for selected offenses
  double calculateTotalFine(List<ViolationOffense> offenses);

  /// Get list of statutory offenses under Motor Vehicles Act 2019
  List<ViolationOffense> getStandardOffenses();
}
