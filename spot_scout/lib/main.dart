// Import Flutter's Material Design library.
// This gives us widgets like Text, Icon, Scaffold, etc.
import 'package:flutter/material.dart';

// Import our own files with the data and the main screen.
import 'data.dart';
import 'navigation.dart';

// This is the starting point of the app.
// When you run the app, Dart looks for main() and runs it first.
void main() {
  // Add 3 sample requests so we have something to look at during testing.
  AppData.instance.initMock();

  // Tell Flutter to finish setting up before we show anything.
  WidgetsFlutterBinding.ensureInitialized();

  // Show the SpotScoutApp on the screen.
  runApp(const SpotScoutApp());
}

// SpotScoutApp is the root widget of the whole app.
// "StatelessWidget" means it cannot change after it is built.
class SpotScoutApp extends StatelessWidget {
  const SpotScoutApp({super.key});

  // build() returns the widget tree that Flutter draws on screen.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // The name shown in the phone's app switcher.
      title: "SpotScout",

      // The theme sets colors and fonts for the whole app.
      theme: ThemeData(
        // Pick a blue color scheme.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        // Use the newer Material 3 rounded design.
        useMaterial3: true,
      ),

      // The first screen users see.
      home: const DashboardScreen(),

      // Remove the "Debug" banner in the corner.
      debugShowCheckedModeBanner: false,
    );
  }
}
