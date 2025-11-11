import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/app_settings.dart';
import '../services/background_service.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';
import 'settings_screen.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final _locationService = LocationService();
  final _backgroundService = BackgroundTrackingService();
  final _storageService = StorageService();

  bool _isTracking = false;
  bool _isLoading = true;
  AppSettings? _settings;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => _isLoading = true);

    // Initialize background service
    await _backgroundService.initializeService();

    // Load settings
    _settings = await _storageService.loadSettings();

    // Check if service is already running
    _isTracking = await _backgroundService.isRunning();

    // Get current location if permissions granted
    final hasPermission = await _checkPermissions();
    if (hasPermission) {
      _currentPosition = await _locationService.getCurrentLocation();
    }

    setState(() => _isLoading = false);
  }

  Future<bool> _checkPermissions() async {
    final permission = await _locationService.checkPermission();
    return permission == LocationPermission.always ||
           permission == LocationPermission.whileInUse;
  }

  Future<void> _requestPermissions() async {
    final granted = await _locationService.requestPermissions();

    if (!granted) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Location Permission Required'),
            content: const Text(
              'This app needs location permission to track your location. '
              'Please enable location permission in settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _locationService.openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
      }
    } else {
      _currentPosition = await _locationService.getCurrentLocation();
      setState(() {});
    }
  }

  Future<void> _toggleTracking() async {
    if (_settings == null || !_settings!.isConfigured) {
      _showSettingsRequired();
      return;
    }

    if (!await _checkPermissions()) {
      await _requestPermissions();
      return;
    }

    setState(() => _isLoading = true);

    if (_isTracking) {
      await _backgroundService.stopTracking();
      setState(() => _isTracking = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tracking stopped')),
        );
      }
    } else {
      await _backgroundService.startTracking();
      setState(() => _isTracking = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tracking started')),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  void _showSettingsRequired() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings Required'),
        content: const Text(
          'Please configure your server URL and access token in settings first.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToSettings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );

    if (result == true) {
      _settings = await _storageService.loadSettings();
      setState(() {});
    }
  }

  Future<void> _refreshLocation() async {
    if (!await _checkPermissions()) {
      await _requestPermissions();
      return;
    }

    setState(() => _isLoading = true);
    _currentPosition = await _locationService.getCurrentLocation();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vibe Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettings,
          ),
        ],
      ),
      body: _isLoading && _settings == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            _isTracking ? Icons.gps_fixed : Icons.gps_off,
                            size: 64,
                            color: _isTracking ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isTracking ? 'Tracking Active' : 'Tracking Inactive',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          if (_isTracking && _settings != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Session: ${_settings!.currentSession ?? "default"}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              'Interval: ${_settings!.trackingIntervalSeconds}s',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Location Info Card
                  if (_currentPosition != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Current Location',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: _refreshLocation,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildLocationRow('Latitude', _currentPosition!.latitude.toStringAsFixed(6)),
                            _buildLocationRow('Longitude', _currentPosition!.longitude.toStringAsFixed(6)),
                            _buildLocationRow('Altitude', '${_currentPosition!.altitude.toStringAsFixed(1)} m'),
                            if (_currentPosition!.speed > 0)
                              _buildLocationRow('Speed', '${(_currentPosition!.speed * 3.6).toStringAsFixed(1)} km/h'),
                            _buildLocationRow('Accuracy', '${_currentPosition!.accuracy.toStringAsFixed(1)} m'),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Start/Stop Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _toggleTracking,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      backgroundColor: _isTracking ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _isTracking ? 'Stop Tracking' : 'Start Tracking',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),

                  // Configuration Status
                  if (_settings == null || !_settings!.isConfigured) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        border: Border.all(color: Colors.orange),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Please configure settings before tracking',
                              style: TextStyle(color: Colors.orange.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildLocationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
