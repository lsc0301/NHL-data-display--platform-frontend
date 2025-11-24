import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:async/async.dart';
import '../models/game.dart';
import '../models/team.dart';
import '../utils/date_utils.dart';

/// Firestore service for game data operations
class FirestoreService {
  final FirebaseFirestore _firestore;
  static const String _gamesCollection = 'games';

  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get today's games stream, sorted by start time
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

  /// Get team info from any game containing this team
  Future<Team?> getTeamInfo(int teamId) async {
    final homeQuery =
        await _firestore
            .collection(_gamesCollection)
            .where('homeTeam.id', isEqualTo: teamId)
            .limit(1)
            .get();

    if (homeQuery.docs.isNotEmpty) {
      final data = homeQuery.docs.first.data();
      final homeTeam = data['homeTeam'] as Map<String, dynamic>?;
      if (homeTeam != null) {
        try {
          return Team.fromFirestore(homeTeam);
        } catch (e) {
          log('Error parsing home team: $e');
        }
      }
    }

    final awayQuery =
        await _firestore
            .collection(_gamesCollection)
            .where('awayTeam.id', isEqualTo: teamId)
            .limit(1)
            .get();

    if (awayQuery.docs.isNotEmpty) {
      final data = awayQuery.docs.first.data();
      final awayTeam = data['awayTeam'] as Map<String, dynamic>?;
      if (awayTeam != null) {
        try {
          return Team.fromFirestore(awayTeam);
        } catch (e) {
          log('Error parsing away team: $e');
        }
      }
    }

    return null;
  }

  /// Get all games for a team in current season
  Stream<List<Game>> getTeamGames(int teamId, int? season) {
    final homeGamesStream = _firestore
        .collection(_gamesCollection)
        .where('homeTeam.id', isEqualTo: teamId)
        .snapshots(includeMetadataChanges: true);

    final awayGamesStream = _firestore
        .collection(_gamesCollection)
        .where('awayTeam.id', isEqualTo: teamId)
        .snapshots(includeMetadataChanges: true);

    return StreamZip([homeGamesStream, awayGamesStream]).map((snapshots) {
      final allDocs = <DocumentSnapshot<Map<String, dynamic>>>[];
      allDocs.addAll(snapshots[0].docs);
      allDocs.addAll(snapshots[1].docs);

      final uniqueGames = <int, Game>{};
      for (final doc in allDocs) {
        try {
          final game = Game.fromFirestore(doc);
          if (season == null || game.season == season) {
            uniqueGames[game.gameId] = game;
          }
        } catch (e) {
          log('Error parsing game: $e');
        }
      }

      return uniqueGames.values.toList();
    });
  }

  /// Get recent games for a team (last 5 games)
  Stream<List<Game>> getTeamRecentGames(int teamId) {
    final homeGamesStream = _firestore
        .collection(_gamesCollection)
        .where('homeTeam.id', isEqualTo: teamId)
        .orderBy('startTime', descending: true)
        .limit(5)
        .snapshots(includeMetadataChanges: true);

    final awayGamesStream = _firestore
        .collection(_gamesCollection)
        .where('awayTeam.id', isEqualTo: teamId)
        .orderBy('startTime', descending: true)
        .limit(5)
        .snapshots(includeMetadataChanges: true);

    return StreamZip([homeGamesStream, awayGamesStream]).map((snapshots) {
      final allGames = <Game>[];

      for (final doc in snapshots[0].docs) {
        try {
          allGames.add(Game.fromFirestore(doc));
        } catch (e) {
          log('Error parsing home game: $e');
        }
      }

      for (final doc in snapshots[1].docs) {
        try {
          allGames.add(Game.fromFirestore(doc));
        } catch (e) {
          log('Error parsing away game: $e');
        }
      }

      final uniqueGames = <int, Game>{};
      for (final game in allGames) {
        uniqueGames[game.gameId] = game;
      }

      final sortedGames =
          uniqueGames.values.toList()..sort((a, b) {
            if (a.startTime == null && b.startTime == null) return 0;
            if (a.startTime == null) return 1;
            if (b.startTime == null) return -1;
            return b.startTime!.compareTo(a.startTime!);
          });

      return sortedGames.take(5).toList();
    });
  }
}
