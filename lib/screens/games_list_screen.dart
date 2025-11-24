import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game.dart';
import '../services/firestore_service.dart';
import '../utils/date_utils.dart' as date_utils;
import '../widgets/games/game_card.dart';
import '../widgets/common/error_widget.dart';
import '../widgets/common/loading_indicator.dart';
import '../widgets/common/empty_state_widget.dart';

class GamesListScreen extends StatelessWidget {
  const GamesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Today\'s Games')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: firestoreService.getTodayGames(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }

          if (snapshot.hasError) {
            return ErrorDisplayWidget(error: snapshot.error!);
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const EmptyStateWidget(message: 'No games today');
          }

          // Convert documents to Game objects and filter to today's games
          final endOfToday = date_utils.DateUtils.getEndOfTodayUtc();
          final games =
              snapshot.data!.docs
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
      ),
    );
  }
}
