import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioPlayer get audioPlayer => _audioPlayer;

  Map<String, dynamic>? _currentSermon;
  Map<String, dynamic>? get currentSermon => _currentSermon;

  List<Map<String, dynamic>> _queue = [];
  List<Map<String, dynamic>> get queue => _queue;

  int _currentIndex = -1;

  bool _isDownloadingInBackground = false;
  String? _localFilePath;

  // Playback state
  bool _isShuffling = false;
  bool get isShuffling => _isShuffling;

  bool _isLooping = false;
  bool get isLooping => _isLooping;

  AudioProvider() {
    _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        playNext();
      }
      notifyListeners();
    });
    _audioPlayer.playerStateStream.listen((state) {
      notifyListeners();
    });
    _audioPlayer.positionStream.listen((position) {
      notifyListeners();
    });
    _audioPlayer.durationStream.listen((duration) {
      notifyListeners();
    });
  }

  Future<void> playSermon(Map<String, dynamic> sermon, {List<Map<String, dynamic>>? queue}) async {
    _currentSermon = sermon;
    if (queue != null) {
      _queue = queue;
      _currentIndex = _queue.indexWhere((s) => s['audio'] == sermon['audio']);
    } else {
      _queue = [sermon];
      _currentIndex = 0;
    }
    _localFilePath = null;
    notifyListeners();
    
    // Save to recently played
    _saveToRecentlyPlayed(sermon);
    
    await _checkAndPlayFile(sermon);
  }

  Future<void> _saveToRecentlyPlayed(Map<String, dynamic> sermon) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> recentJsonList = prefs.getStringList('recent_sermons') ?? [];
      
      // Convert current to json
      String currentJson = jsonEncode(sermon);
      
      // Remove if it already exists to move it to the top
      recentJsonList.removeWhere((item) {
        final Map<String, dynamic> decoded = jsonDecode(item);
        return decoded['audio'] == sermon['audio']; // unique identifier
      });
      
      // Add to beginning
      recentJsonList.insert(0, currentJson);
      
      // Keep only last 20
      if (recentJsonList.length > 20) {
        recentJsonList = recentJsonList.sublist(0, 20);
      }
      
      await prefs.setStringList('recent_sermons', recentJsonList);
    } catch (e) {
      debugPrint('Error saving to recently played: $e');
    }
  }

  Future<void> _checkAndPlayFile(Map<String, dynamic> sermon) async {
    final audioUrl = sermon['audio'];
    final title = sermon['title'] ?? 'Unknown Title';
    final speaker = sermon['speaker'] ?? 'Unknown Speaker';
    final category = sermon['category'] ?? 'Sermon';
    final imageUrl = sermon['image'] ?? 'assets/icon.png';

    try {
      final fileName = p.basename(audioUrl);
      final directory = await getApplicationDocumentsDirectory();
      final localPath = '${directory.path}/$fileName';
      final file = File(localPath);

      if (await file.exists()) {
        _localFilePath = localPath;
        await _audioPlayer.setAudioSource(
          AudioSource.uri(
            Uri.file(localPath),
            tag: MediaItem(
              id: localPath,
              album: category,
              title: title,
              artist: speaker,
              artUri: imageUrl.startsWith('http') ? Uri.parse(imageUrl) : Uri.parse('asset:///$imageUrl'),
            ),
          ),
        );
      } else {
        await _audioPlayer.setAudioSource(
          AudioSource.uri(
            Uri.parse(audioUrl),
            tag: MediaItem(
              id: audioUrl,
              album: category,
              title: title,
              artist: speaker,
              artUri: imageUrl.startsWith('http') ? Uri.parse(imageUrl) : Uri.parse('asset:///$imageUrl'),
            ),
          ),
        );
        _startBackgroundDownload(audioUrl);
      }
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error streaming audio: $e');
    }
  }

  Future<void> _startBackgroundDownload(String audioUrl) async {
    if (_isDownloadingInBackground || _localFilePath != null) return;
    _isDownloadingInBackground = true;

    try {
      final response = await http.get(Uri.parse(audioUrl));
      if (response.statusCode == 200) {
        final fileName = p.basename(audioUrl);
        final directory = await getApplicationDocumentsDirectory();
        final localPath = '${directory.path}/$fileName';
        final file = File(localPath);
        await file.writeAsBytes(response.bodyBytes);
        _localFilePath = localPath;
      }
    } catch (e) {
      debugPrint('Background download error: $e');
    } finally {
      _isDownloadingInBackground = false;
    }
  }

  void playNext() {
    if (_queue.isNotEmpty && _currentIndex < _queue.length - 1) {
      _currentIndex++;
      playSermon(_queue[_currentIndex], queue: _queue);
    }
  }

  void playPrevious() {
    if (_queue.isNotEmpty && _currentIndex > 0) {
      _currentIndex--;
      playSermon(_queue[_currentIndex], queue: _queue);
    }
  }

  void toggleShuffle() {
    _isShuffling = !_isShuffling;
    _audioPlayer.setShuffleModeEnabled(_isShuffling);
    notifyListeners();
  }

  void toggleLoop() {
    _isLooping = !_isLooping;
    _audioPlayer.setLoopMode(_isLooping ? LoopMode.one : LoopMode.off);
    notifyListeners();
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  void togglePlayPause() {
    if (_audioPlayer.playing) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
