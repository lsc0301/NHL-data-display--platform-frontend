import 'package:cloud_firestore/cloud_firestore.dart';
import 'game_status.dart';
import 'team.dart';

/// NHL game model
class Game {
  final int gameId;
  final Team homeTeam;
  final Team awayTeam;
  final GameStatus status;
  final String? startTime;
  final int? season;
  final int? gameType;
  final String? gameScheduleState;
  final GameOutcome? gameOutcome;
  final PeriodDescriptor? periodDescriptor;
  final bool? neutralSite;
  final String? condensedGame;
  final String? condensedGameFr;
  final String? gameCenterLink;
  final String? threeMinRecap;
  final String? threeMinRecapFr;
  final String? ticketsLink;
  final String? ticketsLinkFr;
  final List<TvBroadcast>? tvBroadcasts;
  final Venue? venue;
  final WinningPlayer? winningGoalScorer;
  final WinningPlayer? winningGoalie;
  final String? easternUTCOffset;
  final String? venueTimezone;
  final String? venueUTCOffset;

  Game({
    required this.gameId,
    required this.homeTeam,
    required this.awayTeam,
    required this.status,
    this.startTime,
    this.season,
    this.gameType,
    this.gameScheduleState,
    this.gameOutcome,
    this.periodDescriptor,
    this.neutralSite,
    this.condensedGame,
    this.condensedGameFr,
    this.gameCenterLink,
    this.threeMinRecap,
    this.threeMinRecapFr,
    this.ticketsLink,
    this.ticketsLinkFr,
    this.tvBroadcasts,
    this.venue,
    this.winningGoalScorer,
    this.winningGoalie,
    this.easternUTCOffset,
    this.venueTimezone,
    this.venueUTCOffset,
  });

  /// Create Game from Firestore snapshot
  factory Game.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw ArgumentError('Game document data cannot be null');
    }

    return Game.fromMap(data);
  }

  /// Create Game from Firestore data map
  factory Game.fromMap(Map<String, dynamic> data) {
    return Game(
      gameId: data['gameId'] as int? ?? 0,
      homeTeam: Team.fromFirestore(data['homeTeam'] as Map<String, dynamic>?),
      awayTeam: Team.fromFirestore(data['awayTeam'] as Map<String, dynamic>?),
      status: GameStatus.fromString(data['status'] as String?),
      startTime: data['startTime'] as String?,
      season: data['season'] as int?,
      gameType: data['gameType'] as int?,
      gameScheduleState: data['gameScheduleState'] as String?,
      gameOutcome:
          data['gameOutcome'] != null
              ? GameOutcome.fromFirestore(
                data['gameOutcome'] as Map<String, dynamic>,
              )
              : null,
      periodDescriptor:
          data['periodDescriptor'] != null
              ? PeriodDescriptor.fromFirestore(
                data['periodDescriptor'] as Map<String, dynamic>,
              )
              : null,
      neutralSite: data['neutralSite'] as bool?,
      condensedGame: data['condensedGame'] as String?,
      condensedGameFr: data['condensedGameFr'] as String?,
      gameCenterLink: data['gameCenterLink'] as String?,
      threeMinRecap: data['threeMinRecap'] as String?,
      threeMinRecapFr: data['threeMinRecapFr'] as String?,
      ticketsLink: data['ticketsLink'] as String?,
      ticketsLinkFr: data['ticketsLinkFr'] as String?,
      tvBroadcasts:
          data['tvBroadcasts'] != null
              ? (data['tvBroadcasts'] as List)
                  .map(
                    (e) => TvBroadcast.fromFirestore(e as Map<String, dynamic>),
                  )
                  .toList()
              : null,
      venue:
          data['venue'] != null
              ? Venue.fromFirestore(data['venue'] as Map<String, dynamic>)
              : null,
      winningGoalScorer:
          data['winningGoalScorer'] != null
              ? WinningPlayer.fromFirestore(
                data['winningGoalScorer'] as Map<String, dynamic>,
              )
              : null,
      winningGoalie:
          data['winningGoalie'] != null
              ? WinningPlayer.fromFirestore(
                data['winningGoalie'] as Map<String, dynamic>,
              )
              : null,
      easternUTCOffset: data['easternUTCOffset'] as String?,
      venueTimezone: data['venueTimezone'] as String?,
      venueUTCOffset: data['venueUTCOffset'] as String?,
    );
  }

  /// Convert Game to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'gameId': gameId,
      'homeTeam': homeTeam.toFirestore(),
      'awayTeam': awayTeam.toFirestore(),
      'status': status.value,
      if (startTime != null) 'startTime': startTime,
      if (season != null) 'season': season,
      if (gameType != null) 'gameType': gameType,
      if (gameScheduleState != null) 'gameScheduleState': gameScheduleState,
      if (gameOutcome != null) 'gameOutcome': gameOutcome!.toFirestore(),
      if (periodDescriptor != null)
        'periodDescriptor': periodDescriptor!.toFirestore(),
      if (neutralSite != null) 'neutralSite': neutralSite,
      if (condensedGame != null) 'condensedGame': condensedGame,
      if (condensedGameFr != null) 'condensedGameFr': condensedGameFr,
      if (gameCenterLink != null) 'gameCenterLink': gameCenterLink,
      if (threeMinRecap != null) 'threeMinRecap': threeMinRecap,
      if (threeMinRecapFr != null) 'threeMinRecapFr': threeMinRecapFr,
      if (ticketsLink != null) 'ticketsLink': ticketsLink,
      if (ticketsLinkFr != null) 'ticketsLinkFr': ticketsLinkFr,
      if (tvBroadcasts != null)
        'tvBroadcasts': tvBroadcasts!.map((e) => e.toFirestore()).toList(),
      if (venue != null) 'venue': venue!.toFirestore(),
      if (winningGoalScorer != null)
        'winningGoalScorer': winningGoalScorer!.toFirestore(),
      if (winningGoalie != null) 'winningGoalie': winningGoalie!.toFirestore(),
      if (easternUTCOffset != null) 'easternUTCOffset': easternUTCOffset,
      if (venueTimezone != null) 'venueTimezone': venueTimezone,
      if (venueUTCOffset != null) 'venueUTCOffset': venueUTCOffset,
    };
  }
}

/// Game outcome model
class GameOutcome {
  final String? lastPeriodType;

  GameOutcome({this.lastPeriodType});

  factory GameOutcome.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) {
      return GameOutcome();
    }

    return GameOutcome(lastPeriodType: data['lastPeriodType'] as String?);
  }

  Map<String, dynamic> toFirestore() {
    return {if (lastPeriodType != null) 'lastPeriodType': lastPeriodType};
  }
}

/// Period descriptor model
class PeriodDescriptor {
  final int? number;
  final String? periodType;
  final int? maxRegulationPeriods;

  PeriodDescriptor({this.number, this.periodType, this.maxRegulationPeriods});

  factory PeriodDescriptor.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) {
      return PeriodDescriptor();
    }

    return PeriodDescriptor(
      number: data['number'] as int?,
      periodType: data['periodType'] as String?,
      maxRegulationPeriods: data['maxRegulationPeriods'] as int?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (number != null) 'number': number,
      if (periodType != null) 'periodType': periodType,
      if (maxRegulationPeriods != null)
        'maxRegulationPeriods': maxRegulationPeriods,
    };
  }
}

/// TV broadcast model
class TvBroadcast {
  final String? countryCode;
  final int? id;
  final String? market;
  final String? network;
  final int? sequenceNumber;

  TvBroadcast({
    this.countryCode,
    this.id,
    this.market,
    this.network,
    this.sequenceNumber,
  });

  factory TvBroadcast.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) {
      return TvBroadcast();
    }

    return TvBroadcast(
      countryCode: data['countryCode'] as String?,
      id: data['id'] as int?,
      market: data['market'] as String?,
      network: data['network'] as String?,
      sequenceNumber: data['sequenceNumber'] as int?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (countryCode != null) 'countryCode': countryCode,
      if (id != null) 'id': id,
      if (market != null) 'market': market,
      if (network != null) 'network': network,
      if (sequenceNumber != null) 'sequenceNumber': sequenceNumber,
    };
  }
}

/// Venue model
class Venue {
  final String? default_;
  final String? venueTimezone;
  final String? venueUTCOffset;

  Venue({this.default_, this.venueTimezone, this.venueUTCOffset});

  factory Venue.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) {
      return Venue();
    }

    return Venue(
      default_: data['default'] as String?,
      venueTimezone: data['venueTimezone'] as String?,
      venueUTCOffset: data['venueUTCOffset'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (default_ != null) 'default': default_,
      if (venueTimezone != null) 'venueTimezone': venueTimezone,
      if (venueUTCOffset != null) 'venueUTCOffset': venueUTCOffset,
    };
  }
}

/// Winning player model (goal scorer/goalie)
class WinningPlayer {
  final String? firstInitial;
  final String? lastName;
  final int? playerId;

  WinningPlayer({this.firstInitial, this.lastName, this.playerId});

  factory WinningPlayer.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) {
      return WinningPlayer();
    }

    // Handle nested structure: firstInitial and lastName are maps with 'default' key
    final firstInitialData = data['firstInitial'] as Map<String, dynamic>?;
    final lastNameData = data['lastName'] as Map<String, dynamic>?;

    return WinningPlayer(
      firstInitial: firstInitialData?['default'] as String?,
      lastName: lastNameData?['default'] as String?,
      playerId: data['playerId'] as int?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (firstInitial != null) 'firstInitial': {'default': firstInitial},
      if (lastName != null) 'lastName': {'default': lastName},
      if (playerId != null) 'playerId': playerId,
    };
  }
}
