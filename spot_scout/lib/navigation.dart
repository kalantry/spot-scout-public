// Import Flutter's Material Design widgets.
import 'package:flutter/material.dart';

// Import our own files.
import 'data.dart';
import 'screens/map_screen.dart';
import 'screens/post_request_screen.dart';
import 'screens/browse_screen.dart';
import 'screens/rewards_screen.dart';
import 'screens/profile_dialog.dart';

// This is the main screen. It has a bottom bar with 4 tabs.
// StatefulWidget means this screen can change while the user uses it.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

// The state for DashboardScreen. Holds variables that can change.
class _DashboardScreenState extends State<DashboardScreen> {
  // Which tab is selected (0 = Map, 1 = Post, 2 = Browse, 3 = Rewards).
  int currentTab = 0;

  // Show the profile pop-up.
  // "async" means this function can pause and wait (for the dialog to close).
  Future<void> _openProfile() async {
    // Show a dialog (pop-up window) on top of the current screen.
    await showDialog(
      context: context,
      builder: (_) => const ProfileDialog(),
    );
    // After the dialog closes, rebuild the screen if it's still visible.
    if (mounted) {
      setState(() {});
    }
  }

  // build() tells Flutter what to draw on the screen.
  @override
  Widget build(BuildContext context) {
    // The four tab screens.
    List<Widget> screens = [
      const MapScreen(),
      const PostRequestScreen(),
      const BrowseScreen(),
      const MyRewardsWidget(),
    ];

    // Get the shared app data (to show points in the bar).
    AppData data = AppData.instance;

    // Scaffold is the standard page layout for Material apps.
    return Scaffold(
      // Top bar with search field and actions.
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        // The title area has a search text field.
        title: SizedBox(
          height: 42,
          child: TextField(
            decoration: InputDecoration(
              hintText: "Where are you driving to?",
              prefixIcon:
                  const Icon(Icons.search, size: 20, color: Colors.blue),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        // Widgets on the right side of the bar.
        actions: [
          // Points chip.
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Chip(
              backgroundColor: Colors.amber.shade400,
              avatar: const Text("🪙"),
              label: Text("${data.points} pts",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          // Profile button.
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            tooltip: "Profile",
            onPressed: _openProfile,
          ),
        ],
      ),
      // The middle area switches between screens based on which tab is active.
      body: IndexedStack(index: currentTab, children: screens),
      // Bottom bar with 4 tabs.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTab,
        selectedItemColor: Colors.blue.shade800,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          setState(() {
            currentTab = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_location), label: "Post Request"),
          BottomNavigationBarItem(
              icon: Icon(Icons.handshake), label: "Browse & Claim"),
          BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard), label: "Rewards"),
        ],
      ),
    );
  }
}
