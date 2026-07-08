import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, String>>> fetchFeaturedSermons() async {
    final snapshot = await _db.collection('featuredSermons').get();

    return snapshot.docs.map((doc) {
      // Cast values to String to satisfy the return type
      final data = doc.data();
      return {
        'title': data['title']?.toString() ?? '',
        'image': data['imageUrl']?.toString() ?? '',
      };
    }).toList();
  }

  Future<List<Map<String, String>>> fetchCategories() async {
    final snapshot = await _db.collection('categories').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();

      return {
        'title': data['title']?.toString() ?? '',
        'image': data['imageUrl']?.toString() ?? '',
      };
    }).toList();
  }

  Future<List<Map<String, String>>> fetchRecentSermons() async {
    final snapshot = await _db.collection('recentSermons').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'title': data['title']?.toString() ?? '',
        'speaker': data['speaker']?.toString() ?? '',
        'image': data['imageUrl']?.toString() ?? '',
      };
    }).toList();
  }
}
