import 'dart:ui';
import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import '../providers/audio_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AudioPlayerScreen extends StatefulWidget {
  final Map<String, dynamic>? initialSermon;

  const AudioPlayerScreen({Key? key, this.initialSermon}) : super(key: key);

  @override
  _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  bool _isQueueExpanded = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
    
    // Play the sermon if passed and different from current
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audioProvider = Provider.of<AudioProvider>(context, listen: false);
      if (widget.initialSermon != null) {
        final currentUrl = audioProvider.currentSermon?['audio'];
        if (currentUrl != widget.initialSermon!['audio']) {
          audioProvider.playSermon(widget.initialSermon!);
        }
      }
    });
  }

  void _checkFavoriteStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    final audioUrl = audioProvider.currentSermon?['audio'];
    if (audioUrl == null) return;

    final userFavoritesRef = FirebaseFirestore.instance.collection('user_favorites').doc(user.uid);
    DocumentSnapshot userFavoritesDoc = await userFavoritesRef.get();
    List<dynamic> favoriteSermonIds = userFavoritesDoc.exists
        ? (userFavoritesDoc.data() as Map<String, dynamic>)['favorite_sermon_ids'] ?? []
        : [];

    if (mounted) {
      setState(() => _isFavorite = favoriteSermonIds.contains(audioUrl));
    }
  }

  void _toggleFavorite() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login to add favorites')));
      return;
    }

    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    final audioUrl = audioProvider.currentSermon?['audio'];
    if (audioUrl == null) return;

    final userFavoritesRef = FirebaseFirestore.instance.collection('user_favorites').doc(user.uid);
    DocumentSnapshot userFavoritesDoc = await userFavoritesRef.get();
    List<dynamic> favoriteSermonIds = userFavoritesDoc.exists
        ? (userFavoritesDoc.data() as Map<String, dynamic>)['favorite_sermon_ids'] ?? []
        : [];

    if (_isFavorite) {
      favoriteSermonIds.remove(audioUrl);
      await userFavoritesRef.set({'favorite_sermon_ids': favoriteSermonIds});
      setState(() => _isFavorite = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed from Favorites')));
    } else {
      favoriteSermonIds.add(audioUrl);
      await userFavoritesRef.set({'favorite_sermon_ids': favoriteSermonIds});
      setState(() => _isFavorite = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to Favorites')));
    }
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _briefTitle(String title) {
    int maxLength = 40;
    if (title.length > maxLength) {
      return '${title.substring(0, maxLength)}...';
    } else {
      return title;
    }
  }

  void _toggleQueueExpansion() {
    setState(() {
      _isQueueExpanded = !_isQueueExpanded;
    });
    if (_isQueueExpanded) {
      _showQueueExpandedView();
    }
  }

  void _showQueueExpandedView() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Consumer<AudioProvider>(
              builder: (context, audioProvider, child) {
                final sermons = audioProvider.queue;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Sermon Queue',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 30),
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() => _isQueueExpanded = false);
                            },
                          ),
                        ],
                      ),
                    ),
                    if (sermons.isEmpty)
                      const Expanded(
                        child: Center(
                          child: Text('No sermons in queue', style: TextStyle(color: Colors.white54)),
                        ),
                      )
                    else
                      Expanded(
                        child: Scrollbar(
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            itemCount: sermons.length,
                            separatorBuilder: (context, index) => const Divider(color: Colors.white12, height: 1),
                            itemBuilder: (context, index) {
                              final sermon = sermons[index];
                              final isCurrent = audioProvider.currentSermon?['audio'] == sermon['audio'];

                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundImage: sermon['image'].toString().startsWith('http') ? NetworkImage(sermon['image']) : AssetImage(sermon['image']) as ImageProvider,
                                ),
                                title: Text(
                                  _briefTitle(sermon['title']),
                                  style: TextStyle(
                                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                                    color: isCurrent ? Colors.tealAccent : Colors.white,
                                  ),
                                ),
                                subtitle: Text('by ${sermon['speaker']}', style: const TextStyle(color: Colors.white54)),
                                trailing: Icon(
                                  Icons.play_arrow,
                                  color: isCurrent ? Colors.tealAccent : Colors.white24,
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  setState(() => _isQueueExpanded = false);
                                  audioProvider.playSermon(sermon, queue: sermons);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    ).whenComplete(() => setState(() => _isQueueExpanded = false));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF000000) : const Color(0xFFE5E5E5),
      body: Consumer<AudioProvider>(
        builder: (context, audioProvider, child) {
          final currentSermon = audioProvider.currentSermon;
          if (currentSermon == null) {
            return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor));
          }
          
          final imageUrl = currentSermon['image'] ?? 'assets/icon.png';
          final title = currentSermon['title'] ?? 'Unknown';
          final speaker = currentSermon['speaker'] ?? 'Unknown Speaker';

          return Stack(
            children: [
              // Blurred Background
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageUrl.toString().startsWith('http') ? NetworkImage(imageUrl) : AssetImage(imageUrl) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
                    child: Container(
                      color: isDarkMode ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
              
              SafeArea(
                child: Column(
                  children: [
                    // AppBar equivalent
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.keyboard_arrow_down_rounded, color: isDarkMode ? Colors.white : Colors.black87, size: 32),
                            onPressed: () => Navigator.pop(context),
                          ),
                          IconButton(
                            icon: Icon(Icons.queue_music, color: isDarkMode ? Colors.white : Colors.black87),
                            onPressed: _toggleQueueExpansion,
                          ),
                        ],
                      ),
                    ),
                    
                    // Main Image
                    Expanded(
                      child: Center(
                        child: Hero(
                          tag: currentSermon['audio'],
                          child: Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                              image: DecorationImage(
                                image: imageUrl.toString().startsWith('http') ? NetworkImage(imageUrl) : AssetImage(imageUrl) as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Bottom Control Sheet
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF0A0A0A) : Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _briefTitle(title),
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black87,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            speaker,
                            style: TextStyle(
                              color: (isDarkMode ? Colors.white : Colors.black87).withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Seekable Waveform
                          StreamBuilder<Duration>(
                            stream: audioProvider.audioPlayer.positionStream,
                            builder: (context, snapshotPosition) {
                              final position = snapshotPosition.data ?? Duration.zero;
                              return StreamBuilder<Duration?>(
                                stream: audioProvider.audioPlayer.durationStream,
                                builder: (context, snapshotDuration) {
                                  final duration = snapshotDuration.data ?? Duration.zero;
                                  
                                  return Column(
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          _DynamicWaveform(isPlaying: audioProvider.audioPlayer.playing, progress: duration.inMilliseconds > 0 ? position.inMilliseconds / duration.inMilliseconds : 0),
                                          SliderTheme(
                                            data: SliderTheme.of(context).copyWith(
                                              activeTrackColor: Colors.transparent,
                                              inactiveTrackColor: Colors.transparent,
                                              thumbColor: Theme.of(context).primaryColor,
                                              overlayColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                                              trackHeight: 40,
                                            ),
                                            child: Slider(
                                              min: 0,
                                              max: duration.inMilliseconds.toDouble() > 0 ? duration.inMilliseconds.toDouble() : 1.0,
                                              value: position.inMilliseconds.toDouble().clamp(0.0, duration.inMilliseconds.toDouble() > 0 ? duration.inMilliseconds.toDouble() : 1.0),
                                              onChanged: (value) {
                                                audioProvider.seek(Duration(milliseconds: value.toInt()));
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(formatDuration(position), style: TextStyle(color: (isDarkMode ? Colors.white : Colors.black87).withOpacity(0.5), fontSize: 12)),
                                          Text(formatDuration(duration), style: TextStyle(color: (isDarkMode ? Colors.white : Colors.black87).withOpacity(0.5), fontSize: 12)),
                                        ],
                                      ),
                                    ],
                                  );
                                }
                              );
                            }
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Playback Controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.shuffle,
                                  color: audioProvider.isShuffling ? Theme.of(context).primaryColor : (isDarkMode ? Colors.white54 : Colors.black54),
                                ),
                                onPressed: audioProvider.toggleShuffle,
                              ),
                              IconButton(
                                icon: Icon(Icons.skip_previous_rounded, color: isDarkMode ? Colors.white : Colors.black87, size: 36),
                                onPressed: audioProvider.playPrevious,
                              ),
                              
                              GestureDetector(
                                onTap: audioProvider.togglePlayPause,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    audioProvider.audioPlayer.playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              
                              IconButton(
                                icon: Icon(Icons.skip_next_rounded, color: isDarkMode ? Colors.white : Colors.black87, size: 36),
                                onPressed: audioProvider.playNext,
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.repeat_rounded,
                                  color: audioProvider.isLooping ? Theme.of(context).primaryColor : (isDarkMode ? Colors.white54 : Colors.black54),
                                ),
                                onPressed: audioProvider.toggleLoop,
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Bottom Action row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                      color: _isFavorite ? Colors.redAccent : (isDarkMode ? Colors.white54 : Colors.black54),
                                    ),
                                    onPressed: _toggleFavorite,
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(Icons.file_download_outlined, color: isDarkMode ? Colors.white54 : Colors.black54),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sermon is auto-downloading in background.')));
                                },
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 8), // SafeArea padding
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DynamicWaveform extends StatefulWidget {
  final bool isPlaying;
  final double progress;
  
  const _DynamicWaveform({required this.isPlaying, required this.progress});

  @override
  State<_DynamicWaveform> createState() => _DynamicWaveformState();
}

class _DynamicWaveformState extends State<_DynamicWaveform> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final int _barCount = 50;
  final List<double> _heights = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        setState(() {});
      });
      
    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
    
    // Initialize random heights
    for (int i = 0; i < _barCount; i++) {
      double envelope = 1.0 - ((i - (_barCount / 2)).abs() / (_barCount / 2));
      _heights.add(0.3 + (0.7 * envelope * (Math.Random().nextDouble() * 0.5 + 0.5)));
    }
  }

  @override
  void didUpdateWidget(_DynamicWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final activeColor = Theme.of(context).primaryColor;
    final inactiveColor = isDarkMode ? Colors.white24 : Colors.black12;

    return SizedBox(
      height: 50,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(_barCount, (index) {
          double noise = 0.5;
          if (widget.isPlaying) {
            noise = (Math.sin(_controller.value * 2 * Math.pi + index) + 1) / 2;
          }
          
          double height = 5 + (_heights[index] * 45 * noise);
          bool isPlayed = (index / _barCount) <= widget.progress;
          
          return Container(
            width: 3,
            height: height,
            decoration: BoxDecoration(
              color: isPlayed ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}
