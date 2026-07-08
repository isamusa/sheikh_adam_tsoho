import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart' as auth;

class GoogleDriveHelper {
  static const _scopes = [drive.DriveApi.driveFileScope];
  late drive.DriveApi _driveApi;
  String? _sermonFolderId;

  GoogleDriveHelper();

  /// Initializes Google Drive API with Service Account
  Future<void> _initializeDrive() async {
    print("Initializing Google Drive API...");
    final credentials = await _loadServiceAccountCredentials();
    final client = await auth.clientViaServiceAccount(credentials, _scopes);
    _driveApi = drive.DriveApi(client);

    // Manually set the sermon folder ID
    _sermonFolderId = "1xYTcKykrvdcJDtuIq2H2eMC6UhWknuqD";
    print(
        "Google Drive API initialized successfully! Sermon Folder ID: $_sermonFolderId");
  }

  /// Loads Service Account Credentials from JSON file
  Future<auth.ServiceAccountCredentials>
      _loadServiceAccountCredentials() async {
    try {
      print("Loading service account credentials...");
      final jsonString =
          await rootBundle.loadString('assets/service_account.json');
      final credentials = json.decode(jsonString);
      print("Service account credentials loaded successfully!");
      return auth.ServiceAccountCredentials.fromJson(credentials);
    } catch (e) {
      print("Error loading credentials: $e");
      rethrow;
    }
  }

  /// Uploads a file to Google Drive inside the correct category folder
  Future<String?> uploadFile(File file, String category) async {
    try {
      await _initializeDrive();

      if (!file.existsSync()) {
        print("🚨 Error: File does not exist -> ${file.path}");
        return null;
      }

      print("✅ File exists: ${file.path}, Size: ${file.lengthSync()} bytes");

      print("🔎 Fetching folder ID for category: $category");
      String? categoryFolderId = await _getFolderId(category, _sermonFolderId);

      if (categoryFolderId == null) {
        print("🚨 Failed to create or get category folder");
        return null;
      }
      print("📂 Category folder ID: $categoryFolderId");

      final drive.File fileMetadata = drive.File()
        ..name = file.uri.pathSegments.last
        ..parents = [categoryFolderId]
        ..mimeType = 'audio/mpeg';

      print("⏳ Uploading file: ${file.uri.pathSegments.last}...");

      final fileStream = file.openRead();
      final media = drive.Media(fileStream, file.lengthSync());

      final uploadedFile =
          await _driveApi.files.create(fileMetadata, uploadMedia: media);

      if (uploadedFile.id != null) {
        print("🎉 File uploaded successfully! ID: ${uploadedFile.id}");
        final fileId = uploadedFile.id!;
        await _makeFilePublic(uploadedFile.id!);
        print("🌍 File is now public!");

        return 'https://drive.google.com/uc?export=view&id=$fileId';
      } else {
        print("🚨 File upload failed: No file ID returned.");
        return null;
      }
    } catch (e) {
      print('❌ Error uploading file: $e');
      return null;
    }
  }

  /// Gets or creates a folder in Google Drive
  Future<String?> _getFolderId(String folderName, String? parentId) async {
    try {
      print("Checking if folder '$folderName' exists...");
      final query =
          "'${parentId ?? 'root'}' in parents and mimeType='application/vnd.google-apps.folder' and name='$folderName' and trashed=false";
      final response = await _driveApi.files.list(q: query);

      if (response.files!.isNotEmpty) {
        print("Folder '$folderName' found! ID: ${response.files!.first.id}");
        return response.files!.first.id;
      } else {
        print("Folder '$folderName' not found. Creating new one...");
        final folderMetadata = drive.File()
          ..name = folderName
          ..mimeType = 'application/vnd.google-apps.folder'
          ..parents = parentId != null ? [parentId] : null;

        final folder = await _driveApi.files.create(folderMetadata);
        print("Folder '$folderName' created! ID: ${folder.id}");
        return folder.id;
      }
    } catch (e) {
      print("Error getting/creating folder: $e");
      return null;
    }
  }

  /// Makes the uploaded file public for streaming
  Future<void> _makeFilePublic(String fileId) async {
    try {
      print("Making file public...");
      final permission = drive.Permission()
        ..type = 'anyone'
        ..role = 'reader';

      await _driveApi.permissions.create(permission, fileId);
      print("File is now public.");
    } catch (e) {
      print("Error making file public: $e");
    }
  }
}
