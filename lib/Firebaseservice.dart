import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Add anime to the user's watchlist
  static Future<void> addAnimeToWatchlist(int malId, {String status = "Watching"}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception("User not logged in");

    await _db
        .collection('users')
        .doc(userId)
        .collection('watchlist')
        .doc(malId.toString())
        .set({
      'malId': malId,
      'userwatchliststatus': status,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Update the userwatchliststatus field of a specific anime
  static Future<void> updateWatchlistStatus(int malId, String status) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception("User not logged in");

    await _db
        .collection('users')
        .doc(userId)
        .collection('watchlist')
        .doc(malId.toString())
        .update({'userwatchliststatus': status});
  }

  /// Delete an anime from the user's watchlist
  static Future<void> deleteAnimeFromWatchlist(int malId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    await _db
        .collection('users')
        .doc(uid)
        .collection('watchlist')
        .doc(malId.toString())
        .delete();
  }

  /// Get the user's watchlist status for a specific anime
  static Future<String?> getWatchlistStatus(int malId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('watchlist')
        .doc(malId.toString())
        .get();

    if (doc.exists) {
      final data = doc.data();
      return data != null ? data['userwatchliststatus'] as String? : null;
    }
    return null;
  }

  /// Get list of all anime malIds in the user's watchlist
  static Future<List<int>> getWatchlistAnimeIds() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('watchlist')
        .get();

    return snapshot.docs.map((doc) => int.parse(doc.id)).toList();
  }

  /// Get all watchlist entries including userwatchliststatus
  static Future<List<Map<String, dynamic>>> getWatchlistEntries() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('watchlist')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Clear all anime from the user's watchlist
  static Future<void> clearWatchlist() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('watchlist')
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
