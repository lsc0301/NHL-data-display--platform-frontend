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

  /// Get today's games stream, sorted by start time
  /// Uses offline cache when network unavailable
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
        .snapshots(includeMetadataChanges: true);
  }

  /// Get game by gameId with real-time updates
  /// Uses offline cache when network unavailable
  Stream<Game?> getGameById(int gameId) {
    return _firestore
        .collection(_gamesCollection)
        .where('gameId', isEqualTo: gameId)
        .limit(1)
        .snapshots(includeMetadataChanges: true)
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
