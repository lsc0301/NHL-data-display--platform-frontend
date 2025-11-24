import 'game.dart';
import 'game_status.dart';

/// Team season record model
class TeamRecord {
  final int wins;
  final int losses;
  final int ot; // Overtime losses
  final int points; // Calculated: wins * 2 + ot
  final int gamesPlayed;

  TeamRecord({
    required this.wins,
    required this.losses,
    required this.ot,
    required this.points,
    required this.gamesPlayed,
  });

  /// Calculate record from list of games
  factory TeamRecord.fromGames(List<Game> games, int teamId) {
    int wins = 0;
    int losses = 0;
    int ot = 0;

    for (final game in games) {
      // Only count final games
      if (game.status != GameStatus.final_) continue;

      // Skip games without scores
      if (game.homeTeam.score == null || game.awayTeam.score == null) continue;

      final isHome = game.homeTeam.id == teamId;
      final teamScore = isHome ? game.homeTeam.score! : game.awayTeam.score!;
      final opponentScore =
          isHome ? game.awayTeam.score! : game.homeTeam.score!;

      if (teamScore > opponentScore) {
        // Team won
        wins++;
      } else if (teamScore < opponentScore) {
        // Team lost - check if it's an OT loss
        final isOtLoss =
            game.gameOutcome?.lastPeriodType == "OT" ||
            game.periodDescriptor?.periodType == "OT" ||
            game.periodDescriptor?.periodType ==
                "SO"; // Shootout is also OT loss

        if (isOtLoss) {
          ot++;
        } else {
          losses++;
        }
      }
      // If scores are equal, skip (shouldn't happen in final games, but handle gracefully)
    }

    final gamesPlayed = wins + losses + ot;
    final points =
        wins * 2 + ot; // NHL scoring: 2 points for win, 1 for OT loss

    return TeamRecord(
      wins: wins,
      losses: losses,
      ot: ot,
      points: points,
      gamesPlayed: gamesPlayed,
    );
  }

  /// Get record as formatted string (e.g., "30-20-5")
  String get recordString => '$wins-$losses-$ot';

  /// Get win percentage
  double get winPercentage {
    if (gamesPlayed == 0) return 0.0;
    return wins / gamesPlayed;
  }
}
