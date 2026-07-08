import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'audio_player_screen.dart';

class RecentSermonsScreen extends StatefulWidget {
  const RecentSermonsScreen({Key? key}) : super(key: key);

  @override
  _RecentSermonsScreenState createState() => _RecentSermonsScreenState();
}

class _RecentSermonsScreenState extends State<RecentSermonsScreen> {
  List<Map<String, dynamic>> _recentSermons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentSermons();
  }

  Future<void> _loadRecentSermons() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentJsonList = prefs.getStringList('recent_sermons') ?? [];
      
      setState(() {
        _recentSermons = recentJsonList
            .map((jsonStr) => jsonDecode(jsonStr) as Map<String, dynamic>)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
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
        title: Text('Mafi Sabunta',
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
          : _recentSermons.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.library_music_outlined,
                        size: 80,
                        color: isDarkMode ? Colors.white24 : Colors.black12,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Babu sabbin karatu tukunna',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: _recentSermons.length,
                  itemBuilder: (context, index) {
                    final sermon = _recentSermons[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AudioPlayerScreen(initialSermon: sermon),
                            ),
                          ).then((_) {
                            // Reload when coming back in case a new one was played
                            _loadRecentSermons();
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.music_note_rounded,
                                color: isDarkMode ? Colors.white54 : Colors.black54,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sermon['title'] ?? 'Unknown',
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
                                    'by ${sermon['speaker'] ?? "Unknown Speaker"}',
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white54 : Colors.black54,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Removed trailing icon to clean up UI
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
