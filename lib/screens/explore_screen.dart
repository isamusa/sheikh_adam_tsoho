import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'audio_player_screen.dart'; // Import AudioPlayerScreen

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _sermons = [];
  bool _isLoading = false;
  bool _isSearching = false; // Track if in search mode
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchRandomSermons(); // Fetch random sermons on screen load
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRandomSermons() async {
    setState(() {
      _isLoading = true;
      _isSearching = false; // Reset search mode
      _sermons = []; // Clear previous sermons
    });
    try {
      // Fetch a limited number of sermons randomly (e.g., 10)
      QuerySnapshot recentSermonsSnapshot = await _firestore
          .collection('sermons')
          .limit(10)
          .get(); // Adjust limit as needed
      _sermons = recentSermonsSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      _sermons.shuffle(); // Randomize the order
    } catch (e) {
      print('Error fetching random sermons: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchSermons(String query) async {
    if (query.isEmpty) {
      _fetchRandomSermons(); // If query is empty, revert to random sermons
      return;
    }
    setState(() {
      _isLoading = true;
      _isSearching = true;
      _sermons = []; // Clear previous sermons
    });
    try {
      QuerySnapshot allSermonsSnapshot =
          await _firestore.collection('sermons').get();

      List<Map<String, dynamic>> allSermons = allSermonsSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      String lowerQuery = query.toLowerCase();

      // Perform case-insensitive filtering on title and speaker
      _sermons = allSermons.where((sermon) {
        String title = (sermon['title'] as String? ?? '').toLowerCase();
        String speaker = (sermon['speaker'] as String? ?? '').toLowerCase();
        return title.contains(lowerQuery) || speaker.contains(lowerQuery);
      }).toList();
    } catch (e) {
      print('Error searching sermons: $e');
    } finally {
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Header & Search
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Binciko',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search_rounded, color: textColor),
                    onPressed: () {
                      // Optionally toggle search bar visibility
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildSearchField(isDarkMode),
              
              const SizedBox(height: 24),
              
              // Filter chips (mockup style)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Duka', true, isDarkMode),
                    const SizedBox(width: 8),
                    _buildFilterChip('Sabbi', false, isDarkMode),
                    const SizedBox(width: 8),
                    _buildFilterChip('Shahararru', false, isDarkMode),
                    const SizedBox(width: 8),
                    _buildFilterChip("Maudu'i", false, isDarkMode),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // List
              Expanded(
                child: _buildBody(isDarkMode),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? (isDarkMode ? Colors.white : Colors.black87) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Colors.transparent : (isDarkMode ? Colors.white24 : Colors.black12),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? (isDarkMode ? Colors.black : Colors.white) : (isDarkMode ? Colors.white70 : Colors.black54),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildSearchField(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: 'Nemo Karatu...',
          hintStyle: TextStyle(
            color: isDarkMode ? Colors.white54 : Colors.black38,
          ),
          prefixIcon: Icon(Icons.search_rounded, color: isDarkMode ? Colors.white54 : Colors.black38),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: isDarkMode ? Colors.white54 : Colors.black38),
                  onPressed: () {
                    _searchController.clear();
                    _fetchRandomSermons();
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
        onChanged: (val) {
          setState(() {});
        },
        onSubmitted: (query) {
          _searchSermons(query);
        },
      ),
    );
  }

  Widget _buildBody(bool isDarkMode) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
        ),
      );
    }

    if (_sermons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: isDarkMode ? Colors.white24 : Colors.black12),
            const SizedBox(height: 16),
            Text(
              _isSearching
                  ? 'Babu karatu da ya dace da abinda ka nema.'
                  : 'Babu karatu a halin yanzu.',
              style: TextStyle(
                color: isDarkMode ? Colors.white54 : Colors.black54,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100.0), // Padding for bottom nav
      itemCount: _sermons.length,
      itemBuilder: (context, index) {
        final sermon = _sermons[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AudioPlayerScreen(
                    initialSermon: sermon,
                  ),
                ),
              );
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
                    Icons.music_note_rounded,
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
                        sermon['title'],
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'by ${sermon['speaker']}',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white54 : Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

