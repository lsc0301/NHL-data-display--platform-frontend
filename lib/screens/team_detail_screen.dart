import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/team.dart';
import '../models/game.dart';
import '../models/game_status.dart';
import '../models/team_record.dart';
import '../providers/team_provider.dart';
import '../utils/date_utils.dart' as date_utils;
import '../widgets/common/loading_indicator.dart';
import '../widgets/common/error_widget.dart';
import '../widgets/common/empty_state_widget.dart';
import 'game_detail_screen.dart';

class TeamDetailScreen extends ConsumerWidget {
  final int teamId;

  const TeamDetailScreen({super.key, required this.teamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamInfoAsync = ref.watch(teamInfoProvider(teamId));
    final currentSeason = date_utils.DateUtils.getCurrentSeason();
    final recordAsync = ref.watch(
      teamRecordProvider(
        TeamGamesParams(teamId: teamId, season: currentSeason),
      ),
    );
    final recentGamesAsync = ref.watch(teamRecentGamesProvider(teamId));

    return Scaffold(
      appBar: AppBar(
        title: teamInfoAsync.when(
          data: (team) => Text(team?.name ?? 'Team'),
          loading: () => const Text('Team'),
          error: (_, __) => const Text('Team'),
        ),
      ),
      body: teamInfoAsync.when(
        data: (team) {
          if (team == null) {
            return const EmptyStateWidget(message: 'Team not found');
          }
          return _buildTeamContent(context, team, recordAsync, recentGamesAsync);
        },
        loading: () => const LoadingIndicator(),
        error: (error, stackTrace) => ErrorDisplayWidget(error: error),
      ),
    );
  }

  Widget _buildTeamContent(
    BuildContext context,
    Team team,
    AsyncValue<TeamRecord?> recordAsync,
    AsyncValue<List<Game>> recentGamesAsync,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTeamHeader(team),
          const SizedBox(height: 24),
          _buildSeasonRecord(recordAsync),
          const SizedBox(height: 24),
          _buildRecentGames(context, recentGamesAsync),
        ],
      ),
    );
  }

  Widget _buildTeamHeader(Team team) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            if (team.logo != null && team.logo!.isNotEmpty)
              SizedBox(
                width: 80,
                height: 80,
                child: _buildLogo(team.logo!),
              ),
            if (team.logo != null && team.logo!.isNotEmpty)
              const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    team.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (team.abbrev.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      team.abbrev,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonRecord(AsyncValue<TeamRecord?> recordAsync) {
    return recordAsync.when(
      data: (record) {
        if (record == null) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No record data available'),
            ),
          );
        }
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Season Record',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildRecordStat('Wins', record.wins),
                    _buildRecordStat('Losses', record.losses),
                    _buildRecordStat('OT', record.ot),
                    _buildRecordStat('Points', record.points),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Games Played: ${record.gamesPlayed}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Record: ${record.recordString}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: LoadingIndicator(),
        ),
      ),
      error: (error, stackTrace) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ErrorDisplayWidget(error: error),
        ),
      ),
    );
  }

  Widget _buildRecordStat(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentGames(
    BuildContext context,
    AsyncValue<List<Game>> gamesAsync,
  ) {
    return gamesAsync.when(
      data: (games) {
        if (games.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No recent games'),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Games',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...games.map((game) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildGameCard(context, game),
                )),
          ],
        );
      },
      loading: () => const LoadingIndicator(),
      error: (error, stackTrace) => ErrorDisplayWidget(error: error),
    );
  }

  Widget _buildGameCard(BuildContext context, Game game) {
    final isHome = game.homeTeam.id == teamId;
    final opponent = isHome ? game.awayTeam : game.homeTeam;
    final teamScore = isHome ? game.homeTeam.score : game.awayTeam.score;
    final opponentScore = isHome ? game.awayTeam.score : game.homeTeam.score;

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameDetailScreen(gameId: game.gameId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isHome ? 'vs ${opponent.name}' : '@ ${opponent.name}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (game.startTime != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(game.startTime!),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _buildStatusBadge(game.status),
              const SizedBox(width: 12),
              Text(
                '${teamScore ?? "-"} - ${opponentScore ?? "-"}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(GameStatus status) {
    Color color;
    String text;

    switch (status) {
      case GameStatus.scheduled:
        color = Colors.blue;
        text = 'Scheduled';
        break;
      case GameStatus.live:
        color = Colors.green;
        text = 'Live';
        break;
      case GameStatus.final_:
        color = Colors.grey;
        text = 'Final';
        break;
      case GameStatus.other:
        color = Colors.orange;
        text = 'Other';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLogo(String logoUrl) {
    if (logoUrl.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(
        logoUrl,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => const SizedBox.shrink(),
      );
    } else {
      return Image.network(
        logoUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox.shrink();
        },
      );
    }
  }

  String _formatDate(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      final localTime = dateTime.toLocal();
      return DateFormat('MMM d, y • h:mm a').format(localTime);
    } catch (e) {
      return isoString;
    }
  }
}

