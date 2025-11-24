# 第三部分 - 球队页面实现计划（基于实际数据结构）

## 目标
在比赛详情页面，点击主队或客队名称打开球队页面，显示球队信息、当前赛季战绩和最近5场比赛。

## 数据结构分析 ✅

根据提供的 Firestore 数据结构：
- **只有一个 `games` collection**
- 每个 game document 包含：
  - `homeTeam` 和 `awayTeam` 对象（包含球队信息：id, name, abbrev, logo等）
  - `season` 字段（如 20252026）
  - `status` 字段（"scheduled", "live", "final"）
  - `homeTeam.score` 和 `awayTeam.score`（用于计算胜负）

## 实现方案

### ✅ 可以实现的功能

1. **球队基本信息**：从任意包含该球队的 game 中提取 `homeTeam` 或 `awayTeam` 对象
2. **当前赛季战绩**：从所有包含该球队的已结束比赛中计算（W-L-OT）
3. **最近5场比赛**：查询包含该球队的比赛，按 `startTime` 降序排列，取前5个

### ⚠️ 需要注意的问题

1. **Firestore 查询限制**：不支持 OR 查询，需要分别查询 `homeTeam.id` 和 `awayTeam.id`，然后在客户端合并
2. **战绩计算**：需要从已结束的比赛（`status == "final"`）中计算胜负
3. **当前赛季**：使用 `season` 字段过滤（如 20252026）

---

## 实现步骤

### 阶段 1: 创建球队战绩模型 📦

#### 1.1 创建 TeamRecord 模型
**文件**: `lib/models/team_record.dart`

```dart
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
      if (game.status != GameStatus.final_) continue;
      if (game.homeTeam.score == null || game.awayTeam.score == null) continue;

      final isHome = game.homeTeam.id == teamId;
      final teamScore = isHome ? game.homeTeam.score! : game.awayTeam.score!;
      final opponentScore = isHome ? game.awayTeam.score! : game.homeTeam.score!;

      if (teamScore > opponentScore) {
        wins++;
      } else if (teamScore < opponentScore) {
        // Check if OT loss
        if (game.gameOutcome?.lastPeriodType == "OT" || 
            game.periodDescriptor?.periodType == "OT") {
          ot++;
        } else {
          losses++;
        }
      }
    }

    final gamesPlayed = wins + losses + ot;
    final points = wins * 2 + ot; // NHL scoring: 2 points for win, 1 for OT loss

    return TeamRecord(
      wins: wins,
      losses: losses,
      ot: ot,
      points: points,
      gamesPlayed: gamesPlayed,
    );
  }
}
```

**预计时间**: 30-45 分钟

---

### 阶段 2: Firestore 服务扩展 🔥

#### 2.1 添加获取球队信息的方法
**文件**: `lib/services/firestore_service.dart`

```dart
/// Get team info from any game containing this team
/// Returns team data from the first game found
Future<Team?> getTeamInfo(int teamId) async {
  // Try to find a game with this team as home team
  final homeQuery = await _firestore
      .collection(_gamesCollection)
      .where('homeTeam.id', isEqualTo: teamId)
      .limit(1)
      .get();

  if (homeQuery.docs.isNotEmpty) {
    final data = homeQuery.docs.first.data();
    final homeTeam = data['homeTeam'] as Map<String, dynamic>?;
    if (homeTeam != null) {
      return Team.fromFirestore(homeTeam);
    }
  }

  // If not found, try away team
  final awayQuery = await _firestore
      .collection(_gamesCollection)
      .where('awayTeam.id', isEqualTo: teamId)
      .limit(1)
      .get();

  if (awayQuery.docs.isNotEmpty) {
    final data = awayQuery.docs.first.data();
    final awayTeam = data['awayTeam'] as Map<String, dynamic>?;
    if (awayTeam != null) {
      return Team.fromFirestore(awayTeam);
    }
  }

  return null;
}
```

#### 2.2 添加获取球队所有比赛的方法（用于计算战绩）
```dart
/// Get all games for a team in current season
/// Returns stream of games where team is either home or away
Stream<List<Game>> getTeamGames(int teamId, int? season) {
  // Query home games
  final homeGamesStream = _firestore
      .collection(_gamesCollection)
      .where('homeTeam.id', isEqualTo: teamId)
      .snapshots(includeMetadataChanges: true);

  // Query away games
  final awayGamesStream = _firestore
      .collection(_gamesCollection)
      .where('awayTeam.id', isEqualTo: teamId)
      .snapshots(includeMetadataChanges: true);

  // Combine and filter streams
  return StreamZip([homeGamesStream, awayGamesStream]).map((snapshots) {
    final allDocs = <DocumentSnapshot<Map<String, dynamic>>>[];
    
    // Add home games
    allDocs.addAll(snapshots[0].docs);
    // Add away games
    allDocs.addAll(snapshots[1].docs);

    // Remove duplicates (same gameId)
    final uniqueGames = <int, Game>{};
    for (final doc in allDocs) {
      try {
        final game = Game.fromFirestore(doc);
        // Filter by season if provided
        if (season == null || game.season == season) {
          uniqueGames[game.gameId] = game;
        }
      } catch (e) {
        log('Error parsing game: $e');
      }
    }

    return uniqueGames.values.toList();
  });
}
```

#### 2.3 添加获取球队最近比赛的方法
```dart
/// Get recent games for a team (last 5 games)
Stream<List<Game>> getTeamRecentGames(int teamId) {
  // Query home games
  final homeGamesStream = _firestore
      .collection(_gamesCollection)
      .where('homeTeam.id', isEqualTo: teamId)
      .orderBy('startTime', descending: true)
      .limit(5)
      .snapshots(includeMetadataChanges: true);

  // Query away games
  final awayGamesStream = _firestore
      .collection(_gamesCollection)
      .where('awayTeam.id', isEqualTo: teamId)
      .orderBy('startTime', descending: true)
      .limit(5)
      .snapshots(includeMetadataChanges: true);

  // Combine, deduplicate, sort, and take top 5
  return StreamZip([homeGamesStream, awayGamesStream]).map((snapshots) {
    final allGames = <Game>[];
    
    for (final doc in snapshots[0].docs) {
      try {
        allGames.add(Game.fromFirestore(doc));
      } catch (e) {
        log('Error parsing home game: $e');
      }
    }
    
    for (final doc in snapshots[1].docs) {
      try {
        allGames.add(Game.fromFirestore(doc));
      } catch (e) {
        log('Error parsing away game: $e');
      }
    }

    // Remove duplicates by gameId
    final uniqueGames = <int, Game>{};
    for (final game in allGames) {
      uniqueGames[game.gameId] = game;
    }

    // Sort by startTime descending and take top 5
    final sortedGames = uniqueGames.values.toList()
      ..sort((a, b) {
        if (a.startTime == null && b.startTime == null) return 0;
        if (a.startTime == null) return 1;
        if (b.startTime == null) return -1;
        return b.startTime!.compareTo(a.startTime!);
      });

    return sortedGames.take(5).toList();
  });
}
```

**注意**: 需要添加 `stream_transform` 依赖来使用 `StreamZip`

**预计时间**: 1.5-2 小时

---

### 阶段 3: Riverpod Providers 创建 🎯

#### 3.1 创建球队 Provider
**文件**: `lib/providers/team_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_transform/stream_transform.dart';
import '../models/team.dart';
import '../models/game.dart';
import '../models/team_record.dart';
import '../providers/firestore_provider.dart';
import '../services/firestore_service.dart';

/// Team info provider (from games collection)
final teamInfoProvider = FutureProvider.family<Team?, int>((ref, teamId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getTeamInfo(teamId);
});

/// Team games stream provider (for current season)
final teamGamesProvider = StreamProvider.family<List<Game>, TeamGamesParams>((ref, params) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getTeamGames(params.teamId, params.season);
});

/// Team record provider (calculated from games)
final teamRecordProvider = StreamProvider.family<TeamRecord?, TeamGamesParams>((ref, params) {
  final gamesStream = ref.watch(teamGamesProvider(params));
  
  return gamesStream.map((gamesAsync) {
    return gamesAsync.when(
      data: (games) {
        // Filter only final games for record calculation
        final finalGames = games.where((g) => g.status == GameStatus.final_).toList();
        return TeamRecord.fromGames(finalGames, params.teamId);
      },
      loading: () => null,
      error: (_, __) => null,
    );
  });
});

/// Team recent games provider
final teamRecentGamesProvider = StreamProvider.family<List<Game>, int>((ref, teamId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getTeamRecentGames(teamId);
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
```

**预计时间**: 45-60 分钟

---

### 阶段 4: 球队详情页面 UI 🎨

#### 4.1 创建球队详情页面
**文件**: `lib/screens/team_detail_screen.dart`

**页面结构**:
```dart
class TeamDetailScreen extends ConsumerWidget {
  final int teamId;
  
  const TeamDetailScreen({super.key, required this.teamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamInfoAsync = ref.watch(teamInfoProvider(teamId));
    final currentSeason = _getCurrentSeason(); // Helper method
    final recordAsync = ref.watch(teamRecordProvider(
      TeamGamesParams(teamId: teamId, season: currentSeason),
    ));
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
          return _buildTeamContent(team, recordAsync, recentGamesAsync);
        },
        loading: () => const LoadingIndicator(),
        error: (error, stackTrace) => ErrorDisplayWidget(error: error),
      ),
    );
  }

  Widget _buildTeamContent(
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
          _buildRecentGames(recentGamesAsync),
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
                  if (team.abbrev.isNotEmpty)
                    Text(
                      team.abbrev,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
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

  Widget _buildRecentGames(AsyncValue<List<Game>> gamesAsync) {
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
              child: _buildGameCard(game),
            )),
          ],
        );
      },
      loading: () => const LoadingIndicator(),
      error: (error, stackTrace) => ErrorDisplayWidget(error: error),
    );
  }

  Widget _buildGameCard(Game game) {
    // Simplified game card for team page
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
                    if (game.startTime != null)
                      Text(
                        _formatDate(game.startTime!),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
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

  // Helper methods for logo, status badge, date formatting...
}
```

**预计时间**: 2-3 小时

---

### 阶段 5: 导航集成 🧭

#### 5.1 修改比赛详情页面
**文件**: `lib/screens/game_detail_screen.dart`

修改 `_buildTeamRow` 方法，让球队名称可点击：

```dart
Widget _buildTeamRow({
  required String label,
  required Team team,
  required GameStatus status,
}) {
  return Row(
    children: [
      // ... logo ...
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
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TeamDetailScreen(teamId: team.id),
                  ),
                );
              },
              child: Text(
                team.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  color: Colors.blue,
                ),
              ),
            ),
            // ... other team info ...
          ],
        ),
      ),
      // ... score ...
    ],
  );
}
```

**预计时间**: 30-45 分钟

---

### 阶段 6: 依赖和工具方法 📦

#### 6.1 添加 stream_transform 依赖
**文件**: `pubspec.yaml`

```yaml
dependencies:
  stream_transform: ^2.0.0
```

#### 6.2 添加工具方法
**文件**: `lib/utils/date_utils.dart` 或新建 `lib/utils/season_utils.dart`

```dart
/// Get current season (e.g., 20252026)
/// This could be calculated from current date or use a fixed value
static int? getCurrentSeason() {
  final now = DateTime.now();
  final year = now.year;
  // NHL season typically runs from October to June
  // If current month is before October, use previous season
  if (now.month < 10) {
    return (year - 1) * 10000 + year;
  } else {
    return year * 10000 + (year + 1);
  }
}
```

**预计时间**: 15-30 分钟

---

### 阶段 7: 错误处理和空状态 🛡️

#### 7.1 处理各种状态
- 球队不存在的情况
- 没有战绩数据的情况（赛季刚开始）
- 没有最近比赛的情况
- 加载和错误状态

**预计时间**: 30-45 分钟

---

## 文件清单

### 需要创建的文件
- `lib/models/team_record.dart` - 球队战绩模型
- `lib/providers/team_provider.dart` - 球队相关 Providers
- `lib/screens/team_detail_screen.dart` - 球队详情页面
- `lib/utils/season_utils.dart` (可选) - 赛季工具方法

### 需要修改的文件
- `lib/services/firestore_service.dart` - 添加球队相关查询方法
- `lib/screens/game_detail_screen.dart` - 添加点击导航
- `pubspec.yaml` - 添加 `stream_transform` 依赖

---

## 预计总时间

- **核心功能**: 5-7 小时
- **完善功能**: 1-1.5 小时
- **总计**: 6-8.5 小时

---

## 关键实现点

1. ✅ **球队信息获取**：从 games collection 中任意一个包含该球队的比赛提取
2. ✅ **战绩计算**：从所有已结束的比赛（`status == "final"`）中计算 W-L-OT
3. ✅ **最近比赛**：合并 homeTeam 和 awayTeam 查询，去重后按时间排序取前5
4. ✅ **赛季过滤**：使用 `season` 字段过滤当前赛季的比赛

---

## 注意事项

1. **性能考虑**：查询所有球队比赛可能返回大量数据，考虑添加分页或限制
2. **实时更新**：使用 Stream 确保数据实时更新
3. **离线支持**：使用 `includeMetadataChanges: true` 支持离线缓存
4. **战绩计算准确性**：确保正确识别加时负场（OT loss）
