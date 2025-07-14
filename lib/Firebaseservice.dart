import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> addAnimeToWatchlist(int malId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    await _db
        .collection('users')
        .doc(uid)
        .collection('watchlist')
        .doc(malId.toString())
        .set({'malId': malId});
  }

  static Future<List<int>> getWatchlistAnimeIds() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('watchlist')
        .get();

    return snapshot.docs
        .map((doc) => doc.data()['malId'] as int?)
        .whereType<int>()
        .toList();
  }
  static Future<void> clearWatchlist() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    final snapshot = await _db.collection('users').doc(uid).collection('watchlist').get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

}
