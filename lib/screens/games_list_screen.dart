import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/games/game_card.dart';
import '../widgets/common/error_widget.dart';
import '../widgets/common/loading_indicator.dart';
import '../widgets/common/empty_state_widget.dart';
import '../providers/games_provider.dart';

class GamesListScreen extends ConsumerWidget {
  const GamesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(todayGamesListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Today\'s Games')),
      body: gamesAsync.when(
        data: (games) {
          if (games.isEmpty) {
            return const EmptyStateWidget(message: 'No games today');
          }

          return ListView.builder(
            itemCount: games.length,
            itemBuilder: (context, index) {
              return GameCard(game: games[index]);
            },
          );
        },
        loading: () => const LoadingIndicator(),
        error: (error, stackTrace) => ErrorDisplayWidget(error: error),
      ),
    );
  }
}
