import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'favorites.dart';
import 'library_screen.dart';
import '../providers/audio_provider.dart';
import 'audio_player_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    ExploreScreen(),
    FavoriteSermonsScreen(),
    LibraryScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.05),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: _screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mini Player Overlay
            Consumer<AudioProvider>(
              builder: (context, audioProvider, child) {
                if (audioProvider.currentSermon == null) {
                  return const SizedBox.shrink();
                }
                
                final isDarkMode = Theme.of(context).brightness == Brightness.dark;
                final sermon = audioProvider.currentSermon!;
                final isPlaying = audioProvider.audioPlayer.playing;
                final imageUrl = sermon['image']?.toString() ?? 'assets/icon.png';

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AudioPlayerScreen()),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: imageUrl.startsWith('http')
                              ? Image.network(imageUrl, width: 48, height: 48, fit: BoxFit.cover)
                              : Image.asset(imageUrl, width: 48, height: 48, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sermon['title'] ?? 'Unknown',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                sermon['speaker'] ?? 'Unknown Speaker',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                          onPressed: () => audioProvider.togglePlayPause(),
                          color: Theme.of(context).primaryColor,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            audioProvider.audioPlayer.stop();
                            // Optional: clear current sermon in provider if you want it to disappear completely on close
                          },
                          color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            // Bottom Navigation Bar
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).bottomNavigationBarTheme.backgroundColor?.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BottomNavigationBar(
                    currentIndex: _currentIndex,
                    onTap: _onTabTapped,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    type: BottomNavigationBarType.fixed,
                    selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
                    unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
                    showSelectedLabels: true,
                    showUnselectedLabels: false,
                    selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home_rounded),
                        label: 'Gida',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.explore_rounded),
                        label: 'Binciko',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.favorite_rounded),
                        label: 'Mafi Soyuwa',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.library_books_rounded),
                        label: 'Laburare',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
