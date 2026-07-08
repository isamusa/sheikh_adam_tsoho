import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'audio_player_screen.dart'; // Import AudioPlayerScreen

class FavoriteSermonsScreen extends StatefulWidget {
  const FavoriteSermonsScreen({super.key}); // Add const constructor

  @override
  _FavoriteSermonsScreenState createState() => _FavoriteSermonsScreenState();
}

class _FavoriteSermonsScreenState extends State<FavoriteSermonsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> _getFavoriteSermons() {
    String userId = _auth.currentUser?.uid ?? "";
    if (userId.isEmpty) return Stream.value([]);

    return _firestore
        .collection('favorites')
        .doc(userId)
        .snapshots()
        .asyncMap((doc) async {
      if (!doc.exists) return [];

      List<String> sermonIds = doc.data()?.keys.toList() ?? [];
      List<Map<String, dynamic>> favoriteSermons = [];

      for (String sermonId in sermonIds) {
        final sermonDoc =
            await _firestore.collection('sermons').doc(sermonId).get();
        if (sermonDoc.exists) {
          favoriteSermons.add({"id": sermonId, ...sermonDoc.data()!});
        }
      }

      return favoriteSermons;
    });
  }

  Future<void> _removeFromFavorites(String sermonId) async {
    String userId = _auth.currentUser?.uid ?? "";
    if (userId.isEmpty) return;

    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Remove from Favorites?",
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
        content: Text(
            "Are you sure you want to remove this sermon from your favorites?",
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
        backgroundColor: Theme.of(context).cardColor,
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel",
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Remove", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmDelete == true) {
      await _firestore.collection('favorites').doc(userId).update({
        sermonId: FieldValue.delete(),
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Removed from favorites',
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
        backgroundColor: Colors.red,
      ));
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
        title: Text('Mafi Soyuwa',
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
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getFavoriteSermons(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.secondary)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border_rounded, size: 64, color: isDarkMode ? Colors.white24 : Colors.black12),
                const SizedBox(height: 16),
                Text("Babu wani karatu a Mafi Soyuwa tukunna.",
                    style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.white54 : Colors.black54)),
              ],
            ));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            itemBuilder: (context, index) {
              final sermon = snapshot.data![index];

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
                      
                      // Trailing more/favorite icon
                      IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.redAccent),
                        onPressed: () => _removeFromFavorites(sermon['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
