import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/games/game_card.dart';
import '../widgets/common/error_widget.dart';
import '../widgets/common/loading_indicator.dart';
import '../widgets/common/empty_state_widget.dart';
import '../providers/game_filter_provider.dart';

class GamesListScreen extends ConsumerWidget {
  const GamesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(filteredGamesProvider);
    final currentFilter = ref.watch(gameFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Games'),
        actions: [
          PopupMenuButton<GameFilter>(
            icon: const Icon(Icons.filter_list),
            onSelected: (filter) {
              ref.read(gameFilterProvider.notifier).setFilter(filter);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: GameFilter.all,
                child: Text('All Games'),
              ),
              const PopupMenuItem(
                value: GameFilter.live,
                child: Row(
                  children: [
                    Icon(Icons.circle, color: Colors.green, size: 12),
                    SizedBox(width: 8),
                    Text('Live Only'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: GameFilter.scheduled,
                child: Row(
                  children: [
                    Icon(Icons.circle, color: Colors.blue, size: 12),
                    SizedBox(width: 8),
                    Text('Scheduled Only'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: GameFilter.final_,
                child: Row(
                  children: [
                    Icon(Icons.circle, color: Colors.grey, size: 12),
                    SizedBox(width: 8),
                    Text('Final Only'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (currentFilter != GameFilter.all)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  Text(
                    _getFilterLabel(currentFilter),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      ref.read(gameFilterProvider.notifier).setFilter(
                            GameFilter.all,
                          );
                    },
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Clear'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: gamesAsync.when(
              data: (games) {
                if (games.isEmpty) {
                  return EmptyStateWidget(
                    message: _getEmptyMessage(currentFilter),
                  );
                }

                return ListView.builder(
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    return GameCard(game: games[index]);
                  },
                );
              },
              loading: () => const LoadingIndicator(),
              error: (error, stackTrace) =>
                  ErrorDisplayWidget(error: error),
            ),
          ),
        ],
      ),
    );
  }

  String _getFilterLabel(GameFilter filter) {
    switch (filter) {
      case GameFilter.live:
        return 'Showing: Live Games Only';
      case GameFilter.scheduled:
        return 'Showing: Scheduled Games Only';
      case GameFilter.final_:
        return 'Showing: Final Games Only';
      case GameFilter.all:
        return '';
    }
  }

  String _getEmptyMessage(GameFilter filter) {
    switch (filter) {
      case GameFilter.live:
        return 'No live games';
      case GameFilter.scheduled:
        return 'No scheduled games';
      case GameFilter.final_:
        return 'No final games';
      case GameFilter.all:
        return 'No games today';
    }
  }
}
