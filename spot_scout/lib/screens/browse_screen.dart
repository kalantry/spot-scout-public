import 'package:flutter/material.dart';
import '../data.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

// USER OPENS BROWSE SCREEN
//
// BrowseScreen starts
//        |
//        ↓
// build() runs
//        |
//        ↓
// Gets all requests from AppData
//
// AppData.instance.requests
//        |
//        ↓
// Separates requests:
//
// status == "open"
//        ↓
// open list
//        ↓
// _buildOpenCards()
//        ↓
// _openCard()
//
//
//
// status == "claimed" or "verified"
//        ↓
// mine list
//        ↓
// _buildClaimedCards()
//        ↓
// _claimedCard()

// Shows open requests (available to claim) and the user's claimed requests.
class _BrowseScreenState extends State<BrowseScreen> {
  @override
  Widget build(BuildContext context) {
    AppData data = AppData.instance;
    List<ParkingRequest> all = data.requests;

    // Separate into open requests and requests this user has claimed.
    List<ParkingRequest> open = [];
    List<ParkingRequest> mine = [];
    for (ParkingRequest r in all) {
      if (r.status == "open") {
        open.add(r);
      } else if ((r.status == "claimed" || r.status == "verified") &&
          r.claimedBy == "local") {
        mine.add(r);
      }
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Open Requests section header.
          Row(
            children: [
              const Icon(Icons.swap_horiz, color: Colors.blue),
              const SizedBox(width: 8),
              Text("Open Requests (${open.length})",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),

          // Show open request cards or an empty message.
          if (open.isEmpty)
            _emptyCard("No open requests right now.")
          else
            ..._buildOpenCards(open),

          const Divider(height: 32),

          // My Claims section header.
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text("My Claims (${mine.length})",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),

          // Show claimed request cards or an empty message.
          if (mine.isEmpty)
            _emptyCard("You haven't claimed any yet.")
          else
            ..._buildClaimedCards(mine),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Build all open request cards.
  List<Widget> _buildOpenCards(List<ParkingRequest> openRequests) {
    List<Widget> cards = [];
    for (ParkingRequest r in openRequests) {
      cards.add(_openCard(r));
    }
    return cards;
  }

  // Build all claimed request cards.
  List<Widget> _buildClaimedCards(List<ParkingRequest> claimedRequests) {
    List<Widget> cards = [];
    for (ParkingRequest r in claimedRequests) {
      cards.add(_claimedCard(r));
    }
    return cards;
  }

  // Claim an open request.
  void _handleClaim(ParkingRequest request) {
    AppData data = AppData.instance;
    if (!data.hasCompleteCarInfo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Complete color, make, model, and plate in Profile first."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String error = data.claimRequest(request.id, data.carInfo);
    if (error.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() {});
    int earned = (request.pointsCost * 0.8).floor();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Claimed! +$earned pts (20% platform fee)."),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Verify a handoff for a claimed request.
  void _handleVerify(ParkingRequest request) {
    AppData.instance.verifyHandoff(request.id);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Handoff verified!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  // A card showing an open request that can be claimed.
  Widget _openCard(ParkingRequest r) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(r.address,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            _infoRow(Icons.access_time, _formatTime(r.targetTime)),
            _infoRow(Icons.directions_walk,
                "Walk up to ${r.walkDistance.toStringAsFixed(1)} mi"),
            _infoRow(Icons.monetization_on, "${r.pointsCost} pts total"),
            _infoRow(
                Icons.percent,
                "You earn ${(r.pointsCost * 0.8).floor()} pts (80% - 20% fee)"),
            if (r.isLastMinute)
              Container(
                margin: const EdgeInsets.only(top: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text("Last-minute",
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold)),
              ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.handshake, size: 20),
                label: const Text("Claim & Earn",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => _handleClaim(r),
              ),
            ),
          ],
        ),
      ),
    );
  }
// When the user presses the "Claim & Earn" button, the app:
// 1. Checks if the user has saved their car information.
// 2. Claims the selected parking request if the information is valid.
// 3. Updates the request from "Open Requests" to "My Claims".
// 4. Refreshes the screen to show the changes.
// 5. Calculates the points earned (80% of the total points).
// 6. Displays a confirmation message with the points earned.
  // A card showing a request the user has claimed.
  Widget _claimedCard(ParkingRequest r) {
    bool isVerified = r.status == "verified";

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isVerified ? Colors.green.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(r.address,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isVerified ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isVerified ? "Verified" : "Claimed",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _infoRow(Icons.access_time, _formatTime(r.targetTime)),
            _infoRow(Icons.monetization_on,
                "+${(r.pointsCost * 0.8).floor()} pts earned"),
            _infoRow(
                Icons.directions_car,
                "Your car: ${AppData.instance.carInfo}"),
            if (r.handoffVerified)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Icon(Icons.verified, color: Colors.green, size: 18),
                    SizedBox(width: 6),
                    Text("Handoff complete",
                        style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            if (!isVerified)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.location_on, size: 20),
                    label: const Text("Verify Handoff",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => _handleVerify(r),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // A row with an icon on the left and text on the right.
  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Text(text,
              style: const TextStyle(fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }

  // A gray card shown when a section is empty.
  Widget _emptyCard(String msg) {
    return Card(
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(msg,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
        ),
      ),
    );
  }

  // Format a DateTime into something like "Wed 2:30 PM".
  String _formatTime(DateTime dt) {
    int hour12 = dt.hour % 12;
    if (hour12 == 0) {
      hour12 = 12;
    }
    String hourString = "$hour12";

    String amPm = "AM";
    if (dt.hour >= 12) {
      amPm = "PM";
    }

    String minuteString = dt.minute.toString().padLeft(2, "0");

    List<String> dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    String dayName = dayNames[dt.weekday % 7];

    return "$dayName $hourString:$minuteString $amPm";
  }
}
// USER OPENS BROWSE SCREEN
//
// BrowseScreen starts
//        |
//        ↓
// build() runs
//        |
//        ↓
// Gets all requests from AppData
//
// AppData.instance.requests
//        |
//        ↓
// Separates requests:
//
// status == "open"
//        ↓
// open list
//        ↓
// _buildOpenCards()
//        ↓
// _openCard()
//
//
//
// status == "claimed" or "verified"
//        ↓
// mine list
//        ↓
// _buildClaimedCards()
//        ↓
// _claimedCard()
