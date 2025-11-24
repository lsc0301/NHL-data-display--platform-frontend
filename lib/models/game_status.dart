/// Game status enumeration
enum GameStatus {
  scheduled,
  live,
  final_,
  other;

  /// Create GameStatus from string value
  static GameStatus fromString(String? status) {
    if (status == null) return GameStatus.other;

    switch (status.toLowerCase()) {
      case 'scheduled':
        return GameStatus.scheduled;
      case 'live':
      case 'in progress':
        return GameStatus.live;
      case 'final':
        return GameStatus.final_;
      default:
        return GameStatus.other;
    }
  }

  /// Convert GameStatus to string
  String get value {
    switch (this) {
      case GameStatus.scheduled:
        return 'scheduled';
      case GameStatus.live:
        return 'live';
      case GameStatus.final_:
        return 'final';
      case GameStatus.other:
        return 'other';
    }
  }
}
