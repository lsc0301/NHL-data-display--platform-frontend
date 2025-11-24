import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/team.dart';
import '../models/game.dart';
import '../models/game_status.dart';
import '../models/team_record.dart';
import '../providers/firestore_provider.dart';

/// Team info provider (from games collection)
final teamInfoProvider = FutureProvider.family<Team?, int>((ref, teamId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getTeamInfo(teamId);
});

/// Parameters for team games query
class TeamGamesParams {
  final int teamId;
  final int? season;

  TeamGamesParams({required this.teamId, this.season});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeamGamesParams &&
          runtimeType == other.runtimeType &&
          teamId == other.teamId &&
          season == other.season;

  @override
  int get hashCode => teamId.hashCode ^ season.hashCode;
}

/// Team games stream provider (for current season)
final teamGamesProvider = StreamProvider.family<List<Game>, TeamGamesParams>((
  ref,
  params,
) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getTeamGames(params.teamId, params.season);
});

/// Team record provider (calculated from games)
final teamRecordProvider =
    Provider.family<AsyncValue<TeamRecord?>, TeamGamesParams>((ref, params) {
      final gamesAsync = ref.watch(teamGamesProvider(params));

      return gamesAsync.when(
        data: (games) {
          final finalGames =
              games.where((g) => g.status == GameStatus.final_).toList();
          final record = TeamRecord.fromGames(finalGames, params.teamId);
          return AsyncValue.data(record);
        },
        loading: () => const AsyncValue.loading(),
        error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
      );
    });

/// Team recent games provider
final teamRecentGamesProvider = StreamProvider.family<List<Game>, int>((
  ref,
  teamId,
) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getTeamRecentGames(teamId);
});
