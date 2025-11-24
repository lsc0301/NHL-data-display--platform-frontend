import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game.dart';
import '../providers/firestore_provider.dart';
import '../utils/date_utils.dart';

/// Provider for today's games stream
final todayGamesStreamProvider =
    StreamProvider<QuerySnapshot<Map<String, dynamic>>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getTodayGames();
});

/// Provider for a specific game by gameId
final gameByIdStreamProvider =
    StreamProvider.family<Game?, int>((ref, gameId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getGameById(gameId);
});

/// Provider for processed today's games list
final todayGamesListProvider = Provider<AsyncValue<List<Game>>>((ref) {
  final gamesStream = ref.watch(todayGamesStreamProvider);

  return gamesStream.when(
    data: (snapshot) {
      if (snapshot.docs.isEmpty) {
        return const AsyncValue.data([]);
      }

      final endOfToday = DateUtils.getEndOfTodayUtc();
      final games = snapshot.docs
          .map((doc) {
            try {
              return Game.fromFirestore(doc);
            } catch (e) {
              return null;
            }
          })
          .where((game) {
            if (game == null) return false;
            if (game.startTime != null) {
              final startTime = DateTime.parse(game.startTime!).toUtc();
              return !startTime.isAfter(endOfToday);
            }
            return true;
          })
          .whereType<Game>()
          .toList();

      return AsyncValue.data(games);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

