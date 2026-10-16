import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data.dart';
//Table of contents
/*USER OPENS MAP TAB
        |
        ↓
MapScreen starts
        |
        ↓
initState() runs
        |
        ↓
Gets AppData instance
        |
        ↓
build() runs
        |
        ↓
Gets all parking requests:
        
AppData.instance.requests
        
        |
        ↓
Creates the page:
        
 ┌───────────────────────┐
 │ Traffic Alert Banner  │// line 78 
 ├───────────────────────┤
 │       MAP             │// line 100
 │  You Marker           │// line 206
 │  Request Markers      │// line 207
 ├───────────────────────┤
 │ Legend                │// line 119
 ├───────────────────────┤
 │ Request List          │line 135
 └───────────────────────┘
*/
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

// Shows a map with markers and a list of all parking requests below it.
class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    AppData.instance;
  }

  // Return a color for each status.
  Color _colorForStatus(String status) {
    if (status == "open") {
      return Colors.green;
    } else if (status == "claimed") {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get all parking requests as a list.
    List<ParkingRequest> requests = AppData.instance.requests;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Alert banner about traffic.
            Container(
              width: double.infinity,
              color: Colors.amber.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.orange, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Higher traffic than usual near Montefiore Plaza due to Jazz Concert tonight!",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // The map.
            SizedBox(
              height: 260,
              width: double.infinity,
              child: FlutterMap(
                options: const MapOptions(
                  initialCenter: LatLng(40.820, -73.944),
                  initialZoom: 14.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.spotscout.reborn',
                  ),
                  MarkerLayer(markers: _buildMarkers(requests)),
                ],
              ),
            ),
            // Legend row: colored dots with labels.
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  _dot(Colors.blue, "You"),
                  const SizedBox(width: 16),
                  _dot(Colors.green, "Open"),
                  const SizedBox(width: 16),
                  _dot(Colors.orange, "Claimed"),
                  const SizedBox(width: 16),
                  _dot(Colors.grey, "Verified"),
                ],
              ),
            ),
            // "Requests" section header.
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.list, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    "Requests (${requests.length})",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            // List of requests or empty message.
            if (requests.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  "No requests yet.",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                ),
              )
            else
              // Build each request as a card.
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: requests.length,
                itemBuilder: (context, i) {
                  ParkingRequest r = requests[i];
                  Color statusColor = _colorForStatus(r.status);

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Icon(Icons.location_on, color: statusColor),
                      title: Text(r.address,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        "${_formatTime(r.targetTime)}  Walk ${r.walkDistance.toStringAsFixed(1)} mi  ${r.pointsCost} pts",
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(r.status,
                            style: TextStyle(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Build map markers: one "You" marker + one for each request.
  List<Marker> _buildMarkers(List<ParkingRequest> requests) {
    List<Marker> markers = [];

    // "You" marker.
    markers.add(
      Marker(
        point: const LatLng(40.820, -73.944),
        width: 50,
        height: 50,
        child: const Column(
          children: [
            Icon(Icons.navigation, color: Colors.blueAccent, size: 30),
            Text("You",
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );

    // One marker per request.
    for (ParkingRequest r in requests) {
      Color pinColor = _colorForStatus(r.status);

      markers.add(Marker(
        point: const LatLng(40.818, -73.945),
        width: 50,
        height: 55,
        child: Column(
          children: [
            Icon(Icons.location_on, color: pinColor, size: 30),
            Text(r.status,
                style: TextStyle(
                    color: pinColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ));
    }

    return markers;
  }

  // A colored dot with a label (used in the legend).
  Widget _dot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  // Turn a DateTime into "Wed 2:30 PM".
  String _formatTime(DateTime dt) {
    // Convert hour to 12-hour format.
    int hour12 = dt.hour % 12;
    if (hour12 == 0) {
      hour12 = 12;
    }
    String hourString = "$hour12";

    // AM or PM.
    String amPm = "AM";
    if (dt.hour >= 12) {
      amPm = "PM";
    }

    // Always show 2 digits for minutes (e.g. "05" instead of "5").
    String minuteString = dt.minute.toString().padLeft(2, "0");

    // Day name.
    List<String> dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    String dayName = dayNames[dt.weekday % 7];

    return "$dayName $hourString:$minuteString $amPm";
  }
}
