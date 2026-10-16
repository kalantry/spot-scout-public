// ---- DATA MODELS ----
// These classes describe what information our app works with.

/// A parking request — someone posts this when they need a spot.
class ParkingRequest {
  String id;            // unique ID for this request
  final String address; // street address
  final DateTime targetTime;  // when they need the spot
  final double walkDistance;  // how far (in miles) they will walk
  final int pointsCost;       // how many points it costs to post this
  final bool isLastMinute;    // true = less than 4 hours away
  final DateTime postedAt;    // when it was created
  String status;              // "open", "claimed", or "verified"
  String? claimedBy;          // who claimed it (null if not yet claimed)
  String? scoutCarInfo;       // the scout's car description
  bool handoffVerified;       // has the requester confirmed the handoff?

  // Constructor — builds a new ParkingRequest.
  // "required" means you must provide that value.
  // "= ..." means it has a default if you don't supply it.
  ParkingRequest({
    required this.id,
    required this.address,
    required this.targetTime,
    required this.walkDistance,
    required this.pointsCost,
    required this.isLastMinute,
    required this.postedAt,
    this.status = "open",
    this.claimedBy,
    this.scoutCarInfo,
    this.handoffVerified = false,
  });
}

/// A reward the user can buy with points.
class Reward {
  final String id;
  final String title;
  final int pointsCost;     // points needed to buy it
  final String iconEmoji;   // emoji icon like "🎟️"

  const Reward({
    required this.id,
    required this.title,
    required this.pointsCost,
    required this.iconEmoji,
  });
}

/// A bundle of points you can buy with real money.
class PointPackage {
  final String label;
  final double usdPrice;
  final int points;

  const PointPackage(this.label, this.usdPrice, this.points);
}

// All available rewards.
const List<Reward> availableRewards = [
  Reward(id: "r1", title: "Plaza Concert Ticket", pointsCost: 500, iconEmoji: "🎟️"),
  Reward(id: "r2", title: "Farmers Market Voucher", pointsCost: 300, iconEmoji: "🎡"),
  Reward(id: "r3", title: "Weekly Sweepstakes Entry", pointsCost: 100, iconEmoji: "🎁"),
];

// All point packages you can buy.
const List<PointPackage> pointPackages = [
  PointPackage("Starter Pack", 1.00, 10),
  PointPackage("Value Pack", 5.00, 55),
  PointPackage("Bonus Pack", 10.00, 120),
  PointPackage("Premium Pack", 25.00, 320),
];

// ---- APP DATA ----
// There is only ONE AppData for the whole app.
// Any screen can get it by writing: AppData.instance
class AppData {
  // "static" means this belongs to the class itself, not to an object.
  static final AppData instance = AppData._();

  // Private constructor — nobody can call "new AppData()" from outside.
  AppData._();

  // -- User info --
  int points = 450;           // current point balance
  int platformPool = 0;       // fees collected by the platform
  int claimedCount = 0;       // how many requests the user has claimed

  String carMake = "";
  String carModel = "";
  String carLicensePlate = "";
  String carColor = "";
  int lifetimePurchasedPoints = 0;

  // Combine car fields into one string like "Silver Toyota Camry · ABC-1234".
  String get carInfo {
    List<String> vehicle = [
      carColor.trim(),
      carMake.trim(),
      carModel.trim(),
    ].where((part) => part.isNotEmpty).toList();
    String plate = carLicensePlate.trim();

    if (vehicle.isEmpty || plate.isEmpty) {
      return "";
    }

    return "${vehicle.join(" ")} · $plate";
  }

  bool get hasCompleteCarInfo {
    return carColor.trim().isNotEmpty &&
        carMake.trim().isNotEmpty &&
        carModel.trim().isNotEmpty &&
        carLicensePlate.trim().isNotEmpty;
  }

  // -- Parking requests --
  final List<ParkingRequest> _requests = [];

  // Return a copy of the list so outside code cannot change the original.
  List<ParkingRequest> get requests {
    return List.from(_requests);
  }

  // Fill with 3 sample requests for testing.
  void initMock() {
    _requests.clear();
    _requests.add(ParkingRequest(
      id: "1",
      address: "345 Chambers St",
      targetTime: DateTime.now().add(const Duration(hours: 2)),
      walkDistance: 0.3,
      pointsCost: 25,
      isLastMinute: false,
      postedAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ));
    _requests.add(ParkingRequest(
      id: "2",
      address: "100 Broadway",
      targetTime: DateTime.now().add(const Duration(hours: 5)),
      walkDistance: 0.7,
      pointsCost: 25,
      isLastMinute: false,
      postedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ));
    _requests.add(ParkingRequest(
      id: "3",
      address: "50 W 125th St",
      targetTime: DateTime.now().add(const Duration(hours: 1)),
      walkDistance: 0.2,
      pointsCost: 33,
      isLastMinute: true,
      postedAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ));
  }

  // Add a new request. Deducts the cost from the user's points.
  void addRequest(ParkingRequest req) {
    // Use the current time in milliseconds as a unique ID.
    req.id = DateTime.now().millisecondsSinceEpoch.toString();
    _requests.insert(0, req);
    points = points - req.pointsCost;
  }

  // Try to claim a request for this user.
  // Returns an error message, or empty string "" if successful.
  // The scout earns 80% of the cost. The other 20% is a platform fee.
  String claimRequest(String requestId, String scoutCarInfo) {
    // Find the request with the matching id.
    int index = -1;
    for (int i = 0; i < _requests.length; i++) {
      if (_requests[i].id == requestId) {
        index = i;
        break;
      }
    }

    if (index == -1) {
      return "Request not found.";
    }

    if (_requests[index].status != "open") {
      return "Already claimed.";
    }

    int cost = _requests[index].pointsCost;
    int scoutEarns = (cost * 0.8).floor();
    int platformFee = cost - scoutEarns;

    _requests[index].status = "claimed";
    _requests[index].claimedBy = "local";
    _requests[index].scoutCarInfo = scoutCarInfo;
    points = points + scoutEarns;
    claimedCount = claimedCount + 1;
    platformPool = platformPool + platformFee;

    return "";
  }

  // Mark a handoff as verified (the requester got the spot).
  void verifyHandoff(String requestId) {
    for (int i = 0; i < _requests.length; i++) {
      if (_requests[i].id == requestId && _requests[i].status == "claimed") {
        _requests[i].handoffVerified = true;
        _requests[i].status = "verified";
        break;
      }
    }
  }

  // Add points after buying them.
  void buyPoints(int amount) {
    points = points + amount;
    lifetimePurchasedPoints = lifetimePurchasedPoints + amount;
  }

  // Remove points after spending them.
  void deductPoints(int amount) {
    points = points - amount;
  }
}
