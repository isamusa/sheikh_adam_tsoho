import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class DownloadedSermonsScreen extends StatefulWidget {
  const DownloadedSermonsScreen({super.key});

  @override
  _DownloadedSermonsScreenState createState() =>
      _DownloadedSermonsScreenState();
}

class _DownloadedSermonsScreenState extends State<DownloadedSermonsScreen> {
  List<FileSystemEntity> _downloadedFiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDownloadedFiles();
  }

  Future<void> _loadDownloadedFiles() async {
    setState(() {
      _isLoading = true;
    });
    final directory = await getApplicationDocumentsDirectory();
    final sermonsDir = Directory(directory.path);
    if (sermonsDir.existsSync()) {
      List<FileSystemEntity> files = sermonsDir.listSync();
      files = files
          .whereType<File>()
          .where((file) => file.path.endsWith('.mp3'))
          .toList(); // Filter for .mp3 files
      setState(() {
        _downloadedFiles = files;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFE5E5E5);
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Downloads',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            )),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
            ))
          : _downloadedFiles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download_done_rounded, size: 64, color: isDarkMode ? Colors.white24 : Colors.black12),
                      const SizedBox(height: 16),
                      Text(
                        'No sermons downloaded yet.',
                        style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black54, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: _downloadedFiles.length,
                  itemBuilder: (context, index) {
                    final file = _downloadedFiles[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: InkWell(
                        onTap: () {
                          // TODO: Play downloaded file
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Row(
                          children: [
                            // Minimalist Music Note Square
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.audio_file_rounded,
                                color: isDarkMode ? Colors.white54 : Colors.black54,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // Text content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.basename(file.path),
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Downloaded File',
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white54 : Colors.black54,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Trailing icon
                            IconButton(
                              icon: Icon(Icons.more_horiz_rounded, color: isDarkMode ? Colors.white38 : Colors.black38),
                              onPressed: () {
                                // More options
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
