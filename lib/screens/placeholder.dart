import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'google_drive_helper.dart';

class AdminAddSermonPage extends StatefulWidget {
  @override
  _AdminAddSermonPageState createState() => _AdminAddSermonPageState();
}

class _AdminAddSermonPageState extends State<AdminAddSermonPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _speakerController =
      TextEditingController(text: "Al-Marhum Sheikh Adamu Tsoho Jos");
  final TextEditingController _audioUrlController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  late GoogleDriveHelper _googleDriveHelper;
  bool _isUploading = false;
  bool _isSubmitting = false;
  double _uploadProgress = 0.0;

  List<Map<String, String>> _categories = [];
  Map<String, String>? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _googleDriveHelper = GoogleDriveHelper();
    _fetchCategories();
  }

  /// Fetches categories from Firestore
  Future<void> _fetchCategories() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('categories').get();
      setState(() {
        _categories = snapshot.docs.map((doc) {
          return (doc.data() as Map<String, dynamic>).map((key, value) {
            return MapEntry(key, value.toString());
          });
        }).toList();
      });
    } catch (error) {
      _showSnackbar('Failed to load categories: $error', isError: true);
    }
  }

  /// Picks and uploads an audio file to Google Drive
  Future<void> _pickAndUploadAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true, // ✅ Allow multiple file selection
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() => _isUploading = true);

      final driveHelper = GoogleDriveHelper();
      final List<String> uploadedUrls = [];

      try {
        for (var file in result.files) {
          final filePath = file.path;
          if (filePath == null) continue;

          final audioFile = File(filePath);
          final fileUrl = await driveHelper.uploadFile(
            audioFile,
            _selectedCategory?['title'] ?? 'Uncategorized',
          );

          if (fileUrl != null) {
            uploadedUrls.add(fileUrl);

            // Store each sermon in Firestore
            await FirebaseFirestore.instance.collection('sermons').add({
              "category": _selectedCategory?['title'] ?? 'Uncategorized',
              "title": file.name, // Use file name as title
              "speaker": _speakerController.text.trim(),
              "audio": fileUrl,
              "image": _selectedCategory?['imageUrl'] ?? '',
              "timestamp": FieldValue.serverTimestamp(),
            });
          }
        }

        _showSnackbar('${uploadedUrls.length} files uploaded successfully!');
      } catch (error) {
        _showSnackbar('Error uploading files: $error');
      } finally {
        setState(() => _isUploading = false);
      }
    } else {
      _showSnackbar('No audio files selected.');
    }
  }

  /// Submits sermon data to Firestore
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final sermonData = {
      "category": _selectedCategory?['title'] ?? 'Uncategorized',
      "title": _titleController.text.trim(),
      "speaker": _speakerController.text.trim(),
      "audio": _audioUrlController.text.trim(),
      "image": _imageUrlController.text.trim(),
      "timestamp": FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('sermons').add(sermonData);
      _showSnackbar('Sermon added successfully!');
      _resetForm();
    } catch (error) {
      _showSnackbar('Failed to add sermon: $error', isError: true);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _titleController.clear();
      _speakerController.text = "Al-Marhum Sheikh Adamu Tsoho Jos";
      _audioUrlController.clear();
      _imageUrlController.clear();
      _selectedCategory = null;
    });
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Sermon'),
        backgroundColor: Colors.teal.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(
                width: double.infinity,
                child: DropdownButtonFormField<Map<String, String>>(
                  value: _selectedCategory,
                  items: _categories.map((category) {
                    return DropdownMenuItem<Map<String, String>>(
                      value: category,
                      child: Text(category['title'] ?? 'Unnamed Category'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                      _imageUrlController.text = value?['imageUrl'] ?? '';
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              SizedBox(height: 16),

              /// Title Input
              TextFormField(
                controller: _titleController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Title (Auto-filled)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              /// Speaker Input
              TextFormField(
                controller: _speakerController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Speaker (Default)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              /// Audio Upload Section
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _audioUrlController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Audio URL (Auto-filled)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  _isUploading
                      ? CircularProgressIndicator() // ✅ Show progress while uploading
                      : ElevatedButton.icon(
                          onPressed: _pickAndUploadAudio,
                          icon: Icon(Icons.upload_file, color: Colors.white),
                          label: Text('Upload Files'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal),
                        ),
                ],
              ),

              SizedBox(height: 16),

              /// Submit Button
              _isSubmitting
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('Add Sermon'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade800,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
