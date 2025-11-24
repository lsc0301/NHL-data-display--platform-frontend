import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_status.dart';
import '../models/game.dart';
import 'games_provider.dart';

/// Game filter options
enum GameFilter {
  all,
  live,
  scheduled,
  final_,
}

/// Game filter notifier
class GameFilterNotifier extends Notifier<GameFilter> {
  @override
  GameFilter build() => GameFilter.all;

  void setFilter(GameFilter filter) {
    state = filter;
  }
}

/// Game filter provider
final gameFilterProvider =
    NotifierProvider<GameFilterNotifier, GameFilter>(GameFilterNotifier.new);

/// Filtered games provider
final filteredGamesProvider = Provider<AsyncValue<List<Game>>>((ref) {
  final gamesAsync = ref.watch(todayGamesListProvider);
  final filter = ref.watch(gameFilterProvider);

  return gamesAsync.when(
    data: (games) {
      if (filter == GameFilter.all) {
        return AsyncValue.data(games);
      }

      final filtered = games.where((game) {
        switch (filter) {
          case GameFilter.live:
            return game.status == GameStatus.live;
          case GameFilter.scheduled:
            return game.status == GameStatus.scheduled;
          case GameFilter.final_:
            return game.status == GameStatus.final_;
          case GameFilter.all:
            return true;
        }
      }).toList();

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

