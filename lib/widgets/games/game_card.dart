import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/game.dart';
import '../../models/game_status.dart';
import '../../screens/game_detail_screen.dart';

class GameCard extends StatelessWidget {
  final Game game;

  const GameCard({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusBadge(game.status),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildTeamInfo(
                      game.awayTeam.name,
                      game.awayTeam.score,
                      game.status,
                      logo: game.awayTeam.logo,
                      label: 'Away',
                    ),
                  ),
                  const Text('VS', style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: _buildTeamInfo(
                      game.homeTeam.name,
                      game.homeTeam.score,
                      game.status,
                      logo: game.homeTeam.logo,
                      isHome: true,
                      label: 'Home',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (game.startTime != null)
                Row(
                  children: [
                    Text(
                      'Start time: ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatStartTime(game.startTime!),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
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

  Widget _buildTeamInfo(
    String teamName,
    int? score,
    GameStatus status, {
    bool isHome = false,
    String? label,
    String? logo,
  }) {
    return Column(
      crossAxisAlignment:
          isHome ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        if (label != null) const SizedBox(height: 2),
        if (logo != null && logo.isNotEmpty)
          Align(
            alignment: isHome ? Alignment.centerRight : Alignment.centerLeft,
            child: SizedBox(
              width: 60,
              height: 60,
              child: _buildLogo(logo),
            ),
          ),
        if (logo != null && logo.isNotEmpty) const SizedBox(height: 4),
        Text(
          teamName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          _formatScore(score, status),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: status == GameStatus.live ? Colors.green : Colors.black,
          ),
        ),
      ],
    );
  }

  String _formatScore(int? score, GameStatus status) {
    if (status == GameStatus.scheduled) {
      return '-';
    }
    return score?.toString() ?? '-';
  }

  String _formatStartTime(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      final localTime = dateTime.toLocal();
      return DateFormat('MMM d, y • h:mm a').format(localTime);
    } catch (e) {
      return isoString;
    }
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
}

