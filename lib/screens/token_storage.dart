import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _storage = FlutterSecureStorage();

// Save access token and expiration time
Future<void> saveAccessToken(String token, DateTime expirationTime) async {
  await _storage.write(key: 'accessToken', value: token);
  await _storage.write(
      key: 'expirationTime', value: expirationTime.toIso8601String());
}

// Load access token and expiration time
Future<Map<String, dynamic>> loadAccessToken() async {
  final token = await _storage.read(key: 'accessToken');
  final expirationTimeStr = await _storage.read(key: 'expirationTime');
  final expirationTime =
      expirationTimeStr != null ? DateTime.parse(expirationTimeStr) : null;

  return {
    'accessToken': token,
    'expirationTime': expirationTime,
  };
}

// Check if the token is valid
Future<bool> isTokenValid(String? token) async {
  if (token == null) {
    return false;
  }

  final tokenData = await loadAccessToken();
  final expirationTime = tokenData['expirationTime'] as DateTime?;

  // Token is valid if the current time is before the expiration time
  return expirationTime != null && DateTime.now().isBefore(expirationTime);
}
