import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game.dart';
import '../utils/date_utils.dart';

/// Firestore service for game data operations
class FirestoreService {
  final FirebaseFirestore _firestore;
  static const String _gamesCollection = 'games';

  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get stream of today's games, sorted by start time
  Stream<QuerySnapshot<Map<String, dynamic>>> getTodayGames() {
    final startOfToday = DateUtils.getStartOfTodayUtc();
    return _firestore
        .collection(_gamesCollection)
        .where(
          'startTime',
          isGreaterThanOrEqualTo: startOfToday.toIso8601String(),
        )
        .orderBy('startTime')
        .limit(100)
        .snapshots();
  }

  /// Get game by gameId with real-time updates
  Stream<Game?> getGameById(int gameId) {
    return _firestore
        .collection(_gamesCollection)
        .where('gameId', isEqualTo: gameId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          try {
            return Game.fromFirestore(snapshot.docs.first);
          } catch (e) {
            log('Error parsing game document: $e');
            return null;
          }
        });
  }
}
