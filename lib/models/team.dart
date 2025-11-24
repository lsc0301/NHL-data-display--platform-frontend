/// Team model
class Team {
  final String abbrev;
  final int id;
  final String name;
  final String? logo;
  final String? darkLogo;
  final int? score;
  final bool? awaySplitSquad;
  final bool? homeSplitSquad;
  final PlaceName? placeName;
  final PlaceName? placeNameWithPreposition;
  final String? radioLink;
  final List<Odds>? odds;

  Team({
    required this.abbrev,
    required this.id,
    required this.name,
    this.logo,
    this.darkLogo,
    this.score,
    this.awaySplitSquad,
    this.homeSplitSquad,
    this.placeName,
    this.placeNameWithPreposition,
    this.radioLink,
    this.odds,
  });

  /// Create Team from Firestore data
  factory Team.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) {
      throw ArgumentError('Team data cannot be null');
    }

    return Team(
      abbrev: data['abbrev'] as String? ?? '',
      id: data['id'] as int? ?? 0,
      name: data['name'] as String? ?? '',
      logo: data['logo'] as String?,
      darkLogo: data['darkLogo'] as String?,
      score:
          data['score'] is int
              ? data['score'] as int
              : data['score'] is num
              ? (data['score'] as num).toInt()
              : null,
      awaySplitSquad: data['awaySplitSquad'] as bool?,
      homeSplitSquad: data['homeSplitSquad'] as bool?,
      placeName:
          data['placeName'] != null
              ? PlaceName.fromFirestore(
                data['placeName'] as Map<String, dynamic>,
              )
              : null,
      placeNameWithPreposition:
          data['placeNameWithPreposition'] != null
              ? PlaceName.fromFirestore(
                data['placeNameWithPreposition'] as Map<String, dynamic>,
              )
              : null,
      radioLink: data['radioLink'] as String?,
      odds:
          data['odds'] != null
              ? (data['odds'] as List)
                  .map((e) => Odds.fromFirestore(e as Map<String, dynamic>))
                  .toList()
              : null,
    );
  }

  /// Convert Team to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'abbrev': abbrev,
      'id': id,
      'name': name,
      if (logo != null) 'logo': logo,
      if (darkLogo != null) 'darkLogo': darkLogo,
      if (score != null) 'score': score,
      if (awaySplitSquad != null) 'awaySplitSquad': awaySplitSquad,
      if (homeSplitSquad != null) 'homeSplitSquad': homeSplitSquad,
      if (placeName != null) 'placeName': placeName!.toFirestore(),
      if (placeNameWithPreposition != null)
        'placeNameWithPreposition': placeNameWithPreposition!.toFirestore(),
      if (radioLink != null) 'radioLink': radioLink,
      if (odds != null) 'odds': odds!.map((e) => e.toFirestore()).toList(),
    };
  }
}

/// Place name model (UI displays English only)
class PlaceName {
  final String name; // English name
  final String? fr; // French name (optional)

  PlaceName({required this.name, this.fr});

  factory PlaceName.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) {
      throw ArgumentError('PlaceName data cannot be null');
    }

    return PlaceName(
      name: data['default'] as String? ?? '',
      fr: data['fr'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'default': name, if (fr != null) 'fr': fr};
  }
}

/// Odds model
class Odds {
  final int providerId;
  final String value;

  Odds({required this.providerId, required this.value});

  factory Odds.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) {
      throw ArgumentError('Odds data cannot be null');
    }

    return Odds(
      providerId: data['providerId'] as int? ?? 0,
      value: data['value'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'providerId': providerId, 'value': value};
  }
}
