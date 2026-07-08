import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_storage.dart'; // Import token storage utility

final clientId = 'bot3nm4jrwct0lu';
final clientSecret = 's4nkh210qw1ix17';
final refreshToken =
    'paD0M5l68tsAAAAAAAAAAX4Ff8FLRUFWr63rLYDPYmYAxxG5rJlu-DhM4DWW_Q9c';

// Refresh the access token using Dropbox API
Future<Map<String, dynamic>> refreshAccessToken() async {
  final url = Uri.parse('https://api.dropbox.com/oauth2/token');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken,
      'client_id': clientId,
      'client_secret': clientSecret,
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final accessToken = data['access_token'];
    final expiresIn = data['expires_in']; // Time in seconds
    final expirationTime = DateTime.now().add(Duration(seconds: expiresIn));

    // Save the access token with its expiration time
    await saveAccessToken(accessToken, expirationTime);

    return {
      'accessToken': accessToken,
      'expirationTime': expirationTime,
    };
  } else {
    throw Exception('Failed to refresh access token: ${response.body}');
  }
}

// Validate and refresh the access token if necessary
Future<String> getValidAccessToken({
  required String? currentAccessToken,
  required Future<bool> Function(String? token) isTokenValid,
  required Future<void> Function(String token, DateTime expirationTime)
      saveAccessToken,
}) async {
  // Check if the current token is valid
  if (currentAccessToken != null && await isTokenValid(currentAccessToken)) {
    return currentAccessToken;
  }

  // Refresh the access token if it's expired or invalid
  final tokenData = await refreshAccessToken();
  return tokenData['accessToken'];
}

// Get a temporary link for the file from Dropbox
Future<String> getDropboxTemporaryLink(
  String filePath, {
  required String? currentAccessToken,
  required Future<bool> Function(String? token) isTokenValid,
  required Future<void> Function(String token, DateTime expirationTime)
      saveAccessToken,
}) async {
  // Get a valid access token
  final accessToken = await getValidAccessToken(
    currentAccessToken: currentAccessToken,
    isTokenValid: isTokenValid,
    saveAccessToken: saveAccessToken,
  );

  final url =
      Uri.parse('https://api.dropboxapi.com/2/files/get_temporary_link');

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'path': filePath,
    }),
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    return jsonResponse['link']; // Return the temporary link
  } else {
    throw Exception('Failed to get temporary link: ${response.body}');
  }
}
