import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class DropboxHelper {
  final String accessToken;

  DropboxHelper(this.accessToken);

  Future<String?> uploadFile(File file, String dropboxPath) async {
    final url = Uri.parse('https://content.dropboxapi.com/2/files/upload');
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/octet-stream',
      'Dropbox-API-Arg': jsonEncode({
        'path': dropboxPath,
        'mode': 'add',
        'autorename': true,
        'mute': false,
      }),
    };

    try {
      final response = await http.post(url,
          headers: headers, body: await file.readAsBytes());
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['path_display'];
      } else {
        print('Error uploading file: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception during upload: $e');
      return null;
    }
  }
}
