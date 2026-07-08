import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class BankwanaVideoScreen extends StatefulWidget {
  const BankwanaVideoScreen({Key? key}) : super(key: key);

  @override
  _BankwanaVideoScreenState createState() => _BankwanaVideoScreenState();
}

class _BankwanaVideoScreenState extends State<BankwanaVideoScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  
  // Default placeholder if Firestore is empty
  final String _fallbackYoutubeUrl = 'https://youtu.be/jNQXAC9IVRw'; // Placeholder

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      // 1. Fetch URL from Firestore
      String youtubeUrl = _fallbackYoutubeUrl;
      try {
        final doc = await FirebaseFirestore.instance.collection('settings').doc('video_settings').get();
        if (doc.exists && doc.data() != null) {
          youtubeUrl = doc.data()!['bankwana_url'] ?? _fallbackYoutubeUrl;
        }
      } catch (e) {
        debugPrint('Failed to fetch YouTube URL from Firestore, using fallback. $e');
      }

      // 2. Extract Video ID to check local file
      final yt = YoutubeExplode();
      final videoId = VideoId.parseVideoId(youtubeUrl);
      if (videoId == null) {
        throw Exception("Invalid YouTube URL");
      }

      final directory = await getApplicationDocumentsDirectory();
      final localFilePath = '${directory.path}/bankwana_$videoId.mp4';
      final file = File(localFilePath);

      // 3. Play Local or Stream + Download
      if (await file.exists()) {
        debugPrint('Playing local offline video: $localFilePath');
        _videoPlayerController = VideoPlayerController.file(file);
      } else {
        debugPrint('Local video not found. Extracting stream URL for $videoId');
        final manifest = await yt.videos.streamsClient.getManifest(videoId);
        final streamInfo = manifest.muxed.withHighestBitrate();
        
        final streamUrl = streamInfo.url.toString();
        
        _videoPlayerController = VideoPlayerController.network(streamUrl);
        
        // Start background download
        _downloadVideoInBackground(streamUrl, localFilePath);
      }
      
      yt.close();

      // 4. Initialize Player
      await _videoPlayerController.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: true,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        placeholder: const Center(
          child: CircularProgressIndicator(color: Colors.cyanAccent),
        ),
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.cyanAccent,
          handleColor: Colors.cyan,
          backgroundColor: Colors.white24,
          bufferedColor: Colors.white54,
        ),
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading video: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _downloadVideoInBackground(String streamUrl, String localPath) async {
    try {
      debugPrint('Starting background download to $localPath');
      final response = await http.get(Uri.parse(streamUrl));
      if (response.statusCode == 200) {
        final file = File(localPath);
        await file.writeAsBytes(response.bodyBytes);
        debugPrint('Background download complete: $localPath');
      }
    } catch (e) {
      debugPrint('Background video download failed: $e');
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark cinematic background for reel view
      body: Stack(
        children: [
          Center(
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.cyanAccent)
                : _hasError
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.white54, size: 48),
                          const SizedBox(height: 16),
                          const Text(
                            'An sami matsala wajen kunna bidiyon.',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(color: Colors.white38, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLoading = true;
                                _hasError = false;
                              });
                              _initVideo();
                            },
                            child: const Text('Sake Gwada', style: TextStyle(color: Colors.cyanAccent)),
                          ),
                        ],
                      )
                    : _chewieController != null
                        ? AspectRatio(
                            aspectRatio: _videoPlayerController.value.aspectRatio,
                            child: Chewie(
                              controller: _chewieController!,
                            ),
                          )
                        : const SizedBox(),
          ),
          
          // Back Button Overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
