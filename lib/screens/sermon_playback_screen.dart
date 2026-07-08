import 'package:flutter/material.dart';

class SermonPlaybackScreen extends StatelessWidget {
  final String title;
  final String scholar;

  SermonPlaybackScreen({required this.title, required this.scholar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Now Playing'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Display Sermon Title
            Text(
              title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            // Display Scholar's Name
            Text(
              'By $scholar',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            SizedBox(height: 16),
            // Placeholder for Sermon Image or Icon
            Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.mic, size: 100, color: Colors.tealAccent),
            ),
            SizedBox(height: 32),
            // Playback Controls
            Column(
              children: [
                Slider(
                  value: 0.5,
                  onChanged: (value) {},
                  activeColor: Colors.tealAccent,
                  inactiveColor: Colors.white24,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(Icons.replay_10, color: Colors.white),
                      onPressed: () {
                        // Handle rewind
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.play_arrow,
                          color: Colors.tealAccent, size: 36),
                      onPressed: () {
                        // Handle play
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.forward_10, color: Colors.white),
                      onPressed: () {
                        // Handle forward
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
