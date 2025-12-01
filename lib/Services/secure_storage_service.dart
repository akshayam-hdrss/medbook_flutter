import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  // Save token
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  // Read token
  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  // Delete token
  Future<void> deleteToken() async {
    await _storage.delete(key: 'jwt_token');
  }

  Future<void> saveUserDetails(String userJson) async {
    await _storage.write(key: 'user_details', value: userJson);
  }

  Future<Map<String, dynamic>?> getUserDetails() async {
    final jsonString = await _storage.read(key: 'user_details');
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  // Optional: clear all
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Save selected district
  Future<void> saveSelectedDistrict(String district) async {
    await _storage.write(key: 'selected_district', value: district);
  }

  // Get selected district
  Future<String?> getSelectedDistrict() async {
    return await _storage.read(key: 'selected_district');
  }

  // Save selected area
  Future<void> saveSelectedArea(String area) async {
    await _storage.write(key: 'selected_area', value: area);
  }

  // Get selected area
  Future<String?> getSelectedArea() async {
    return await _storage.read(key: 'selected_area');
  }
}