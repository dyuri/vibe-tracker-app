import 'package:flutter/material.dart';
import 'screens/tracking_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const VibeTrackerApp());
}

class VibeTrackerApp extends StatelessWidget {
  const VibeTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibe Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TrackingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
