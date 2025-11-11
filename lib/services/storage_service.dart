import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/app_settings.dart';

/// Service for securely storing app settings and tokens
class StorageService {
  static const _settingsKey = 'app_settings';
  final _storage = const FlutterSecureStorage();

  /// Save app settings securely
  Future<void> saveSettings(AppSettings settings) async {
    final json = jsonEncode(settings.toJson());
    await _storage.write(key: _settingsKey, value: json);
  }

  /// Load app settings
  Future<AppSettings?> loadSettings() async {
    try {
      final json = await _storage.read(key: _settingsKey);
      if (json == null) return null;

      final map = jsonDecode(json) as Map<String, dynamic>;
      return AppSettings.fromJson(map);
    } catch (e) {
      print('Error loading settings: $e');
      return null;
    }
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Save individual setting
  Future<void> saveValue(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Read individual setting
  Future<String?> readValue(String key) async {
    return await _storage.read(key: key);
  }
}
