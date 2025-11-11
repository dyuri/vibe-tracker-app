# Vibe Tracker Mobile

A Flutter mobile application for tracking location and sending data to the Vibe Tracker backend.

## Features

- Background location tracking
- Token-based authentication
- Session management
- GeoJSON data format
- Configurable tracking intervals

## Setup

1. Configure your Vibe Tracker server URL and access token in the app settings
2. Grant location permissions when prompted
3. Create or select a session name
4. Start tracking

## Permissions

- Location (foreground and background)
- Foreground service (for persistent tracking)

## API Integration

Connects to the Vibe Tracker API endpoint `/api/track` using:
- Bearer token authentication
- GeoJSON Feature format
- POST requests with location data

## Development

Built with Flutter for Android (iOS support coming soon).

See [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) for detailed architecture and implementation details.
