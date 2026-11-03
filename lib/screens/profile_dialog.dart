import 'package:flutter/material.dart';
import '../data.dart';

// A pop-up window showing the user's stats and car info form.
class ProfileDialog extends StatefulWidget {
  const ProfileDialog({super.key});

  @override
  State<ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<ProfileDialog> {
  // Controllers for the four text fields.
  final TextEditingController _makeCtrl = TextEditingController();
  final TextEditingController _modelCtrl = TextEditingController();
  final TextEditingController _plateCtrl = TextEditingController();
  final TextEditingController _colorCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    AppData data = AppData.instance;
    // Fill the text fields with the current saved values.
    _colorCtrl.text = data.carColor;
    _makeCtrl.text = data.carMake;
    _modelCtrl.text = data.carModel;
    _plateCtrl.text = data.carLicensePlate;
  }

  // Save the car info back to AppData.
  void _save() {
    AppData data = AppData.instance;
    data.carColor = _colorCtrl.text.trim();
    data.carMake = _makeCtrl.text.trim();
    data.carModel = _modelCtrl.text.trim();
    data.carLicensePlate = _plateCtrl.text.trim();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Car info saved!"), backgroundColor: Colors.green),
    );
  }

  @override
  void dispose() {
    // Clean up controllers when the dialog closes.
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _plateCtrl.dispose();
    _colorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppData data = AppData.instance;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row with close button.
              Row(
                children: [
                  const Icon(Icons.person, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text("My Profile",
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Stats section.
              const Text("Stats",
                  style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _statBox("${data.points}", "Points"),
                  const SizedBox(width: 12),
                  _statBox("${data.claimedCount}", "Claimed"),
                ],
              ),
              const SizedBox(height: 20),

              // Car info section.
              const Text("My Car Info",
                  style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              const Text(
                "Shown to other users when you claim a request.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),

              // Color field.
              TextField(
                controller: _colorCtrl,
                decoration: InputDecoration(
                  labelText: "Color",
                  hintText: "e.g. Silver",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),

              // Make and Model fields side by side.
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _makeCtrl,
                      decoration: InputDecoration(
                        labelText: "Make",
                        hintText: "e.g. Toyota",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _modelCtrl,
                      decoration: InputDecoration(
                        labelText: "Model",
                        hintText: "e.g. Camry",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // License plate field.
              TextField(
                controller: _plateCtrl,
                decoration: InputDecoration(
                  labelText: "License Plate",
                  hintText: "e.g. ABC-1234",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 16),

              // Save button.
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.save, size: 20),
                  label: const Text("Save Car Info",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // A small box showing a number and a label.
  Widget _statBox(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
