import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game.dart';
import '../models/game_status.dart';
import '../models/team.dart';
import '../providers/games_provider.dart';
import '../widgets/common/loading_indicator.dart';
import '../widgets/common/error_widget.dart';
import '../widgets/common/empty_state_widget.dart';

class GameDetailScreen extends ConsumerWidget {
  final int gameId;

  const GameDetailScreen({super.key, required this.gameId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameAsync = ref.watch(gameByIdStreamProvider(gameId));

    return Scaffold(
      appBar: AppBar(title: const Text('Game Details')),
      body: gameAsync.when(
        data: (game) {
          if (game == null) {
            return const EmptyStateWidget(message: 'Game not found');
          }

          return _buildGameContent(game);
        },
        loading: () => const LoadingIndicator(),
        error: (error, stackTrace) => ErrorDisplayWidget(error: error),
      ),
    );
  }

  Widget _buildGameContent(Game game) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusBadge(game.status),
          const SizedBox(height: 24),
          _buildTeamsSection(game),
          const SizedBox(height: 24),
          if (game.startTime != null) _buildStartTime(game.startTime!),
          if (game.season != null ||
              game.gameType != null ||
              game.gameScheduleState != null) ...[
            const SizedBox(height: 16),
            _buildGameInfo(game),
          ],
          if (game.venue != null) ...[
            const SizedBox(height: 16),
            _buildVenueInfo(game.venue!, game),
          ],
          if (game.periodDescriptor != null) ...[
            const SizedBox(height: 16),
            _buildPeriodInfo(game.periodDescriptor!),
          ],
          if (game.gameOutcome != null) ...[
            const SizedBox(height: 16),
            _buildGameOutcome(game.gameOutcome!),
          ],
          if (game.tvBroadcasts != null && game.tvBroadcasts!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildTvBroadcasts(game.tvBroadcasts!),
          ],
          if (game.awayTeam.radioLink != null ||
              game.homeTeam.radioLink != null) ...[
            const SizedBox(height: 16),
            _buildRadioLinks(game),
          ],
          if (game.winningGoalScorer != null || game.winningGoalie != null) ...[
            const SizedBox(height: 16),
            _buildWinningPlayers(game),
          ],
          if (game.condensedGame != null || game.threeMinRecap != null) ...[
            const SizedBox(height: 16),
            _buildVideoLinks(game),
          ],
          if (game.ticketsLink != null) ...[
            const SizedBox(height: 16),
            _buildTicketsLink(game.ticketsLink!),
          ],
          if (game.gameCenterLink != null) ...[
            const SizedBox(height: 16),
            _buildGameCenterLink(game.gameCenterLink!),
          ],
        ],
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

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 2),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTeamsSection(Game game) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTeamRow(
              label: 'Away',
              team: game.awayTeam,
              status: game.status,
            ),
            if (game.awayTeam.odds != null &&
                game.awayTeam.odds!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildTeamOdds(game.awayTeam.odds!),
            ],
            const Divider(height: 32),
            _buildTeamRow(
              label: 'Home',
              team: game.homeTeam,
              status: game.status,
            ),
            if (game.homeTeam.odds != null &&
                game.homeTeam.odds!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildTeamOdds(game.homeTeam.odds!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTeamOdds(List<Odds> odds) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Odds:',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children:
                odds
                    .map(
                      (odd) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          'Provider ${odd.providerId}: ${odd.value}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamRow({
    required String label,
    required Team team,
    required GameStatus status,
  }) {
    return Row(
      children: [
        if (team.logo != null && team.logo!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
              width: 60,
              height: 60,
              child: _buildLogo(team.logo!),
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                team.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (team.abbrev.isNotEmpty)
                Text(
                  team.abbrev,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              if (team.id != 0)
                Text(
                  'ID: ${team.id}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              if (team.placeName != null)
                Text(
                  team.placeName!.name,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
        Text(
          _formatScore(team.score, status),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: status == GameStatus.live ? Colors.green : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildStartTime(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      final localTime = dateTime.toLocal();
      final formattedDate = DateFormat('EEEE, MMMM d, y').format(localTime);
      final formattedTime = DateFormat('h:mm a').format(localTime);

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.access_time, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Start Time',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formattedTime,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildGameInfo(Game game) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 12),
                Text(
                  'Game Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (game.season != null)
              _buildInfoRow('Season', game.season.toString()),
            if (game.gameType != null)
              _buildInfoRow('Game Type', game.gameType.toString()),
            if (game.gameScheduleState != null)
              _buildInfoRow('Schedule State', game.gameScheduleState!),
            if (game.neutralSite == true) _buildInfoRow('Neutral Site', 'Yes'),
            if (game.easternUTCOffset != null)
              _buildInfoRow('Eastern UTC Offset', game.easternUTCOffset!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueInfo(Venue venue, Game game) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_on, color: Colors.red),
                SizedBox(width: 12),
                Text(
                  'Venue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (venue.default_ != null) _buildInfoRow('Name', venue.default_!),
            if (venue.venueTimezone != null)
              _buildInfoRow('Timezone', venue.venueTimezone!),
            if (venue.venueUTCOffset != null)
              _buildInfoRow('UTC Offset', venue.venueUTCOffset!),
            if (game.venueUTCOffset != null)
              _buildInfoRow('Game UTC Offset', game.venueUTCOffset!),
            if (game.venueTimezone != null)
              _buildInfoRow('Game Timezone', game.venueTimezone!),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodInfo(PeriodDescriptor period) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.sports_hockey, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Period',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (period.number != null && period.periodType != null)
                    Text(
                      'Period ${period.number} - ${period.periodType}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOutcome(GameOutcome outcome) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Game Outcome',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (outcome.lastPeriodType != null)
                    Text(
                      'Last Period: ${outcome.lastPeriodType}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTvBroadcasts(List<TvBroadcast> broadcasts) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.tv, color: Colors.purple),
                SizedBox(width: 12),
                Text(
                  'TV Broadcasts',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...broadcasts.map(
              (broadcast) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (broadcast.network != null)
                      Text(
                        broadcast.network!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (broadcast.market != null)
                          Expanded(
                            child: Text(
                              'Market: ${broadcast.market!}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        if (broadcast.countryCode != null)
                          Text(
                            'Country: ${broadcast.countryCode!}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                    if (broadcast.id != null ||
                        broadcast.sequenceNumber != null)
                      Text(
                        [
                          if (broadcast.id != null) 'ID: ${broadcast.id}',
                          if (broadcast.sequenceNumber != null)
                            'Sequence: ${broadcast.sequenceNumber}',
                        ].join(' • '),
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWinningPlayers(Game game) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.star, color: Colors.amber),
                SizedBox(width: 12),
                Text(
                  'Winning Players',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (game.winningGoalScorer != null)
              _buildPlayerInfo('Goal Scorer', game.winningGoalScorer!),
            if (game.winningGoalie != null) ...[
              if (game.winningGoalScorer != null) const SizedBox(height: 8),
              _buildPlayerInfo('Goalie', game.winningGoalie!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerInfo(String label, WinningPlayer player) {
    final name = [
      if (player.firstInitial != null) player.firstInitial,
      if (player.lastName != null) player.lastName,
    ].where((e) => e != null).join(' ');

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                name.isNotEmpty ? name : 'N/A',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRadioLinks(Game game) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.radio, color: Colors.orange),
                SizedBox(width: 12),
                Text(
                  'Radio Links',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (game.awayTeam.radioLink != null)
              _buildLinkRow('Away Team', game.awayTeam.radioLink!),
            if (game.homeTeam.radioLink != null) ...[
              if (game.awayTeam.radioLink != null) const SizedBox(height: 8),
              _buildLinkRow('Home Team', game.homeTeam.radioLink!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLinkRow(String label, String link) {
    return InkWell(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  link,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.open_in_new, color: Colors.blue, size: 18),
        ],
      ),
    );
  }

  Widget _buildVideoLinks(Game game) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.video_library, color: Colors.purple),
                SizedBox(width: 12),
                Text(
                  'Video Links',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (game.condensedGame != null)
              _buildLinkRow('Condensed Game', game.condensedGame!),
            if (game.threeMinRecap != null) ...[
              if (game.condensedGame != null) const SizedBox(height: 8),
              _buildLinkRow('3 Min Recap', game.threeMinRecap!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTicketsLink(String link) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: InkWell(
          child: Row(
            children: [
              const Icon(Icons.confirmation_number, color: Colors.green),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Tickets',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward, color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCenterLink(String link) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: InkWell(
          child: Row(
            children: [
              const Icon(Icons.link, color: Colors.blue),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Game Center',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }

  String _formatScore(int? score, GameStatus status) {
    if (status == GameStatus.scheduled) {
      return '-';
    }
    return score?.toString() ?? '-';
  }

  Widget _buildLogo(String logoUrl) {
    if (logoUrl.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(
        logoUrl,
        fit: BoxFit.contain,
        placeholderBuilder:
            (context) => Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
      );
    } else {
      return Image.network(
        logoUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.image_not_supported, color: Colors.grey),
          );
        },
      );
    }
  }
}
