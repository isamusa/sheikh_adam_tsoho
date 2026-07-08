import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import 'audio_player_screen.dart';
import 'Category_Sermons_Screen.dart';
import 'biography_page.dart';
import 'recent_sermons_screen.dart';
import 'all_categories_screen.dart';
import 'bankwana_video_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Map<String, dynamic>> featuredSermons = [
    {'title': '', 'image': 'assets/1.jpg'},
    {'title': '', 'image': 'assets/2.jpg'},
    {'title': 'Tarihin Rayuwar Sheikh', 'image': 'assets/3.jpg'},
    {
      'title': 'Al-Marhum Sheikh Adamu Tsoho Jos (رحمه الله)',
      'image': 'assets/4.jpg'
    },
  ];
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> recentSermons = [];
  bool _isLoading = true;
  Map<String, dynamic>? _currentAudio;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      QuerySnapshot categoriesSnapshot =
          await _firestore.collection('categories').orderBy('title').get();
      categories = categoriesSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // Load Mafi Sabunta from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final recentJsonList = prefs.getStringList('recent_sermons') ?? [];
      recentSermons = recentJsonList.take(5).map((jsonStr) => jsonDecode(jsonStr) as Map<String, dynamic>).toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Barka Da Safiya';
    if (hour < 18) return 'Barka Da Rana';
    return 'Barka Da Yamma';
  }

  void _playAudio(Map<String, dynamic> audioData) {
    setState(() {
      _currentAudio = audioData;
      _isPlaying = true;
    });
  }

  Widget _buildSkeletonLoader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 150, height: 24, color: Colors.grey.withOpacity(0.2)),
          const SizedBox(height: 16),
          Container(width: double.infinity, height: 200, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(16))),
          const SizedBox(height: 24),
          Container(width: 120, height: 24, color: Colors.grey.withOpacity(0.2)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Container(height: 100, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(16)))),
              const SizedBox(width: 16),
              Expanded(child: Container(height: 100, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(16)))),
            ],
          ),
          const SizedBox(height: 24),
          Container(width: 180, height: 24, color: Colors.grey.withOpacity(0.2)),
          const SizedBox(height: 16),
          Container(width: double.infinity, height: 80, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(12))),
          const SizedBox(height: 12),
          Container(width: double.infinity, height: 80, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(12))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Theme.of(context).scaffoldBackgroundColor : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: _isLoading
          ? _buildSkeletonLoader()
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildContentArea(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              child: Image.asset(
                'assets/4.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1A1A1A).withOpacity(0.1),
                    const Color(0xFF1A1A1A).withOpacity(0.6),
                    const Color(0xFF1A1A1A).withOpacity(0.95),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.3, 0.6, 1.0],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top icons removed
                  const SizedBox(height: 48), // Spacer
                  
                  // Title and Verified Icon
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Sheikh Adamu Tsoho',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  // Subtitle
                  const Text(
                    'Da`irar Jos',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  const Text(
                    'Wannan manhaja ta kunshi karatuttukan Al-Marhum Sheikh Adamu Tsoho Jos (رحمه الله)',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                             Navigator.push(context, MaterialPageRoute(builder: (context) => SheikhBiographyScreen()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyanAccent[400],
                            foregroundColor: Colors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text('Tarihin Mallam', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                             Navigator.push(context, MaterialPageRoute(builder: (context) => const BankwanaVideoScreen()));
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text('Bankwana', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentArea() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 120.0),
      child: Column(
        children: [
          if (categories.isNotEmpty)
            _buildHorizontalList('Rukunin Darussa', categories, isCategory: true),
          const SizedBox(height: 32),
          if (recentSermons.isNotEmpty)
            _buildVerticalList('Mafi Sabunta', recentSermons),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(String title, List<Map<String, dynamic>> items, {bool isRecent = false, bool isCategory = false}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDarkMode ? Colors.white : const Color(0xFF1E3A8A),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllCategoriesScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    'Duba Duka',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.cyanAccent[400] : const Color(0xFF1E3A8A),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return GestureDetector(
                onTap: () {
                  if (isRecent) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AudioPlayerScreen(initialSermon: item),
                      ),
                    );
                  } else if (isCategory) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategorySermonsScreen(
                          categoryTitle: item['title'],
                          categoryImage: item['imageUrl'] ?? 'assets/3.jpg',
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: AssetImage(isCategory ? item['imageUrl'] : item['image']),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (isRecent && item['speaker'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            item['speaker'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalList(String title, List<Map<String, dynamic>> items) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDarkMode ? Colors.white : const Color(0xFF1E3A8A),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecentSermonsScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    'Duba Duka',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.cyanAccent[400] : const Color(0xFF1E3A8A),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AudioPlayerScreen(initialSermon: item),
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
                            item['title'],
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
                            'by ${item['speaker'] ?? "Unknown"}',
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
        ),
      ],
    );
  }
}

