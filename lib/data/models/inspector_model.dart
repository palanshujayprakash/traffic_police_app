class InspectorModel {
  final String id;
  final String name;
  final String rank;
  final String badgeNumber;
  final String station;
  final String beatLocation;
  final String shift;
  final String phone;
  final String email;
  final String avatarInitials;
  final int vehiclesCheckedToday;
  final int challansIssuedToday;
  final double finesCollectedToday;
  final bool isOnDuty;

  const InspectorModel({
    required this.id,
    required this.name,
    required this.rank,
    required this.badgeNumber,
    required this.station,
    required this.beatLocation,
    required this.shift,
    required this.phone,
    required this.email,
    required this.avatarInitials,
    this.vehiclesCheckedToday = 48,
    this.challansIssuedToday = 14,
    this.finesCollectedToday = 18500.0,
    this.isOnDuty = true,
  });
}
