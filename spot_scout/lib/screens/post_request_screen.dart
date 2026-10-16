import 'package:flutter/material.dart';
import '../data.dart';

class PostRequestScreen extends StatefulWidget {
  const PostRequestScreen({super.key});

  @override
  State<PostRequestScreen> createState() => _PostRequestScreenState();
}

// This screen has a form where the user fills in the details for a
// parking request and posts it. Other users ("scouts") can claim it.
class _PostRequestScreenState extends State<PostRequestScreen> {
  // The text field controller watches what the user types in the address field.
  final TextEditingController _addressCtrl = TextEditingController();

  // Date and time selected by the user.
  DateTime _targetDate = DateTime.now().add(const Duration(hours: 5));
  TimeOfDay _targetTime = const TimeOfDay(hour: 12, minute: 0);

  // How far (in miles) the user is willing to walk.
  double _walkDistance = 0.5;

  // Combine the date and time into one DateTime.
  DateTime _combined() {
    return DateTime(_targetDate.year, _targetDate.month, _targetDate.day,
        _targetTime.hour, _targetTime.minute);
  }

  // How many minutes between now and the target time.
  int _minutesAway() {
    Duration diff = _combined().difference(DateTime.now());
    return diff.inMinutes;
  }

  // Is the target between 30 minutes and 4 hours away?
  bool _isLastMinute() {
    int mins = _minutesAway();
    return mins >= 30 && mins < 240;
  }

  // Is the target less than 30 minutes away?
  bool _isTooSoon() {
    int mins = _minutesAway();
    return mins >= 0 && mins < 30;
  }

  // Calculate how many points this request costs.
  int _cost() {
    if (_combined().isBefore(DateTime.now())) {
      return 0;
    }
    int baseCost = 25;
    if (_isLastMinute()) {
      // Last-minute requests cost 30% more.
      return (baseCost * 1.3).round();
    } else {
      return baseCost;
    }
  }

  // Open the date picker.
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  // Open the time picker.
  Future<void> _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _targetTime,
    );
    if (picked != null) {
      setState(() {
        _targetTime = picked;
      });
    }
  }

  // Check the form and post the request if everything is valid.
  void _handlePost() {
    String address = _addressCtrl.text.trim();
    DateTime target = _combined();
    int cost = _cost();

    if (address.isEmpty) {
      _showMessage("Please enter a street address.", Colors.redAccent);
      return;
    }

    if (target.isBefore(DateTime.now())) {
      _showMessage("Target time must be in the future.", Colors.redAccent);
      return;
    }

    AppData data = AppData.instance;
    if (data.points < cost) {
      _showMessage(
          "Not enough points. You have ${data.points}, need $cost.",
          Colors.redAccent);
      return;
    }

    ParkingRequest req = ParkingRequest(
      id: "",
      address: address,
      targetTime: target,
      walkDistance: _walkDistance,
      pointsCost: cost,
      isLastMinute: _isLastMinute(),
      postedAt: DateTime.now(),
    );

    AppData.instance.addRequest(req);
    _addressCtrl.clear();
    if (mounted) {
      setState(() {});
    }
    _showMessage("Request posted for $address! Cost: $cost pts.", Colors.green);
  }

  // Show a small message at the bottom of the screen.
  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppData data = AppData.instance;
    int points = data.points;
    int cost = _cost();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card at the top.
            Card(
              color: Colors.blue.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.blue, size: 36),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Reserve a Parking Spot",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text(
                            "Tell us where and when. A Scout will claim it.",
                            style: TextStyle(
                                fontSize: 13, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Street address input.
            const Text("Street Address",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _addressCtrl,
              decoration: InputDecoration(
                hintText: "e.g. 345 Chambers St",
                prefixIcon: const Icon(Icons.location_on, color: Colors.blue),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),

            // Date and time picker buttons.
            const Text("Date & Time",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(
                      "${_targetDate.month}/${_targetDate.day}/${_targetDate.year}",
                      style: const TextStyle(fontSize: 14),
                    ),
                    onPressed: _pickDate,
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time, size: 18),
                    label: Text(_targetTime.format(context),
                        style: const TextStyle(fontSize: 14)),
                    onPressed: _pickTime,
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Show a colored message about the pricing.
            if (_isTooSoon() && !_combined().isBefore(DateTime.now()))
              _infoCard(Icons.error_outline, Colors.red.shade50, Colors.red,
                  "Must be at least 30 minutes from now.")
            else if (_isLastMinute())
              _infoCard(
                  Icons.warning_amber,
                  Colors.orange.shade50,
                  Colors.orange,
                  "Less than 4 hours away - 30% surcharge. No guarantee.")
            else if (!_combined().isBefore(DateTime.now()))
              _infoCard(Icons.check_circle, Colors.green.shade50, Colors.green,
                  "4+ hours ahead - standard rate."),

            const SizedBox(height: 20),

            // Walking distance slider.
            const Text("Max Walking Distance",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              "${_walkDistance.toStringAsFixed(1)} miles",
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            Slider(
              value: _walkDistance,
              min: 0.1,
              max: 2.0,
              divisions: 19,
              label: "${_walkDistance.toStringAsFixed(1)} mi",
              onChanged: (double value) {
                setState(() {
                  _walkDistance = value;
                });
              },
            ),
            Text(
              "You'll walk up to ${_walkDistance.toStringAsFixed(1)} miles.",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),

            // Cost summary card.
            Card(
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Cost: $cost pts",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text("Balance: $points pts",
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Submit button.
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.send, size: 22),
                label: Text(
                  "Post Request ($cost pts)",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: _handlePost,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // A small card with an icon and a message.
  Widget _infoCard(IconData icon, Color bg, Color fg, String text) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: fg, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
