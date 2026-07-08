import 'package:flutter/material.dart';
import 'sermon_playback_screen.dart';

class CategoryScreen extends StatelessWidget {
  final String category;

  CategoryScreen({required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('$category Sermons'),
        backgroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.grey[850],
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.teal,
                child: Icon(Icons.mic, color: Colors.white),
              ),
              title: Text('Sermon Title ${index + 1}',
                  style: TextStyle(color: Colors.white)),
              subtitle: Text('Scholar Name ${index + 1}',
                  style: TextStyle(color: Colors.white70)),
              trailing: Icon(Icons.play_arrow, color: Colors.tealAccent),
              onTap: () {
                // Navigate to playback screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SermonPlaybackScreen(
                      title: 'Sermon Title ${index + 1}',
                      scholar: 'Scholar Name ${index + 1}',
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
