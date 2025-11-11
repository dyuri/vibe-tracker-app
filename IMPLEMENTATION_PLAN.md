# Flutter Location Tracking App - Implementation Plan

## Overview
Build a Flutter app (Android-first) that:
- Tracks device location in the background
- Sends location data to vibe-tracker API (`/api/track`)
- Uses token-based authentication (no login UI needed)
- Supports session-based tracking

## Architecture & Technology Stack

### Flutter App Components:
1. **Location Services** - Background location tracking using `geolocator` or `background_location`
2. **HTTP Client** - API communication with vibe-tracker backend
3. **Local Storage** - Secure token storage using `flutter_secure_storage`
4. **State Management** - Simple state management (Provider/Riverpod)
5. **Background Service** - Persistent tracking using `flutter_background_service`

### Key Features:
- Token configuration screen (one-time setup)
- Start/Stop tracking controls
- Current location display
- Session name input
- Tracking status indicator
- Upload success/failure notifications
- Tracking history (optional)

## Implementation Steps

### Phase 1: Project Setup
- Initialize Flutter project
- Add dependencies (geolocator, http, flutter_secure_storage, flutter_background_service)
- Configure Android permissions (location, foreground service)
- Set up Android manifest for background location

### Phase 2: Core Services
- Token storage service (save/retrieve token securely)
- Location service (request permissions, get current location)
- API service (send location to `/api/track` endpoint)
- Settings service (tracking interval, session name, server URL)

### Phase 3: Background Tracking
- Implement background service for continuous tracking
- Location update listener with configurable interval
- Queue failed uploads for retry
- Battery optimization handling

### Phase 4: UI Components
- Settings screen (token input, server URL, tracking interval)
- Main tracking screen (start/stop button, status, current location)
- Session management (create/select session)
- Simple dashboard (last update time, coordinates)

### Phase 5: API Integration
- Format location data as GeoJSON Feature
- Add required headers (User-Agent, Authorization)
- Handle network errors and retries
- Validate responses

### Phase 6: Android Configuration
- Location permissions (FINE_LOCATION, COARSE_LOCATION)
- Background location permission (Android 10+)
- Foreground service notification
- Battery optimization exclusion prompts

### Phase 7: Testing & Polish
- Test foreground/background tracking
- Test app restart persistence
- Test network failure scenarios
- Optimize battery usage
- Add user feedback (toast messages, notifications)

## Technical Decisions

### Why Flutter?
- ✅ Single codebase for Android/iOS future expansion
- ✅ Good performance for location tracking
- ✅ Rich ecosystem for location services
- ✅ Easy UI development

### API Approach:
- Use POST with GeoJSON format (more structured than GET)
- Bearer token in Authorization header
- Include User-Agent header as required

### Data to Track:
- Latitude, longitude (required)
- Altitude (if available)
- Timestamp (Unix epoch)
- Speed (from location provider)
- Session name (user-configurable)
- Heart rate (optional - would need health sensor integration)

### Background Strategy:
- Use foreground service with notification (required on Android)
- Configurable tracking interval (e.g., every 30s, 1min, 5min)
- Wake locks if needed for precise tracking

## API Endpoint Details

### Endpoint: `/api/track`

**POST Request (GeoJSON):**
```json
{
  "type": "Feature",
  "geometry": {
    "type": "Point",
    "coordinates": [longitude, latitude, altitude]
  },
  "properties": {
    "timestamp": 1672531200,
    "speed": 60,
    "heart_rate": 120,
    "session": "session_name"
  }
}
```

**Required Headers:**
- `Content-Type: application/json`
- `Authorization: Bearer YOUR_ACCESS_TOKEN`
- `User-Agent: VibeTracker-CLI/1.0`
