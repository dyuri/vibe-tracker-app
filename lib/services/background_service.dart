import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/widgets.dart';
import '../models/location_data.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// Background service for continuous location tracking
class BackgroundTrackingService {
  static final BackgroundTrackingService _instance = BackgroundTrackingService._internal();
  factory BackgroundTrackingService() => _instance;
  BackgroundTrackingService._internal();

  final service = FlutterBackgroundService();

  /// Initialize the background service
  Future<void> initializeService() async {
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'vibe_tracker_channel',
        initialNotificationTitle: 'Vibe Tracker',
        initialNotificationContent: 'Location tracking initialized',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  /// Start the tracking service
  Future<void> startTracking() async {
    await service.startService();
  }

  /// Stop the tracking service
  Future<void> stopTracking() async {
    service.invoke('stop');
  }

  /// Check if service is running
  Future<bool> isRunning() async {
    return await service.isRunning();
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    Timer? locationTimer;

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stop').listen((event) {
      locationTimer?.cancel();
      service.stopSelf();
    });

    // Load settings
    final storageService = StorageService();
    final settings = await storageService.loadSettings();

    if (settings == null || !settings.isConfigured) {
      print('Service stopped: Settings not configured');
      service.stopSelf();
      return;
    }

    final apiService = ApiService(
      baseUrl: settings.serverUrl,
      accessToken: settings.accessToken!,
    );

    locationTimer = Timer.periodic(Duration(seconds: settings.trackingIntervalSeconds), (timer) async {
      try {
        // Get current position
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        // Create location data
        final locationData = LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
          altitude: position.altitude,
          speed: position.speed,
          timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          session: settings.currentSession ?? 'default',
        );

        // Send to API
        final success = await apiService.sendLocation(locationData);

        // Update notification
        if (service is AndroidServiceInstance) {
          await service.setForegroundNotificationInfo(
            title: 'Vibe Tracker',
            content: success
                ? 'Last update: ${DateTime.now().toString().substring(11, 19)}\n'
                  'Lat: ${position.latitude.toStringAsFixed(6)}, '
                  'Lon: ${position.longitude.toStringAsFixed(6)}'
                : 'Failed to send location. Retrying...',
          );
        }

        print('Location update: ${success ? "Success" : "Failed"} - $locationData');
      } catch (e) {
        print('Error in background service: $e');

        if (service is AndroidServiceInstance) {
          await service.setForegroundNotificationInfo(
            title: 'Vibe Tracker',
            content: 'Error: $e',
          );
        }
      }
    });
  }
}
