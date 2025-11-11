/// Model for location data that will be sent to the Vibe Tracker API
class LocationData {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? speed;
  final int timestamp;
  final String session;
  final int? heartRate;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.speed,
    required this.timestamp,
    required this.session,
    this.heartRate,
  });

  /// Convert to GeoJSON Feature format for API
  Map<String, dynamic> toGeoJson() {
    return {
      'type': 'Feature',
      'geometry': {
        'type': 'Point',
        'coordinates': [
          longitude,
          latitude,
          altitude ?? 0.0,
        ],
      },
      'properties': {
        'timestamp': timestamp,
        if (speed != null) 'speed': speed,
        if (heartRate != null) 'heart_rate': heartRate,
        'session': session,
      },
    };
  }

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lon: $longitude, alt: $altitude, '
        'speed: $speed, session: $session, ts: $timestamp)';
  }
}
