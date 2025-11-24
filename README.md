# NHL Data Display Platform Frontend

NHL Data Display Platform Frontend Project

## Overview

This project is a Flutter mobile application designed to display NHL game data in real-time from Google Firestore. The app provides an intuitive interface for viewing today's games, with live score updates and detailed game information. Users can browse games, filter live matches, and view comprehensive game details, all while benefiting from offline capabilities through Firestore's built-in caching.

## Key Features

- **Real-time Data Display**: Connects to Firestore to display today's NHL games with live score updates as data changes.

- **Games List Screen**: Shows a comprehensive list of games with team information, scores, start times, and game status in an easy-to-read format.

- **Game Detail Screen**: Provides full game information including detailed team stats, game timeline, and all relevant match data.

- **Game Filtering**: Allows users to filter games by status (All, Live, Scheduled, Final) with real-time updates.

- **Robust State Management**: Handles loading states, error states, and missing data gracefully to ensure a smooth user experience.

- **Offline Support**: Leverages Firestore caching to enable basic offline functionality, allowing users to view previously loaded data without an active connection.

- **Cross-platform**: Built with Flutter, providing native performance on both iOS and Android platforms.

- **Adaptive UI**: Automatically adapts to display new fields and data structures as the backend schema evolves.

This project demonstrates skills in mobile app development, real-time data synchronization, state management, offline-first architecture, and user experience design, showcasing a practical frontend engineering implementation.

## Setup & Build

### Step 1: Initialize Project and Setup Git Repository

**Initialize Flutter Project**

- Initialize Flutter project with required configuration
- Set up project structure with lib/ directory for source code
- Configure Flutter SDK and Dart environment

**Setup GitHub Remote Repository**

- Initialize git repository
- Connect to GitHub remote repository
- Configure remote origin

**Create and Separate Branches**

- Create main branch for production releases
- Create dev branch for active development work
- Push both branches to remote repository

### Step 2: Configure Firebase Integration

**Create Firebase Project**

- Create a new Firebase project in Firebase Console
- Enable Firestore Database service
- Configure Firestore database settings

**Configure FlutterFire**

- Install FlutterFire CLI
- Run FlutterFire configure command to integrate GCP project configuration
- Generate Firebase options file for Flutter project

**Add Project Dependencies**

- Add firebase_core dependency
- Add cloud_firestore dependency
- Add intl dependency for date and time formatting
- Install dependencies using Flutter package manager

## Data Models

The project uses a structured data model to represent NHL game data from Firestore. All models are located in `lib/models/` directory.

### GameStatus Enum (`lib/models/game_status.dart`)

Defines the possible states of a game:

- `scheduled` - Game is scheduled but not started
- `live` - Game is currently in progress
- `final_` - Game has ended
- `other` - Unknown or other status

Provides utility methods:
- `fromString(String?)` - Convert string status to GameStatus enum
- `value` - Get string representation of the status

### Team Model (`lib/models/team.dart`)

Represents team information with the following fields:

**Required Fields:**
- `abbrev` (String) - Team abbreviation (e.g., "VAN", "TBL")
- `id` (int) - Team ID
- `name` (String) - Team name (e.g., "Canucks", "Lightning")

**Optional Fields:**
- `score` (int?) - Current team score (nullable, may be null for scheduled games)
- `logo` (String?) - Light logo URL
- `darkLogo` (String?) - Dark logo URL
- `placeName` (PlaceName?) - Team location name (receives multi-language data, UI displays English only)
- `placeNameWithPreposition` (PlaceName?) - Location name with preposition (receives multi-language data, UI displays English only)
- `radioLink` (String?) - Radio broadcast link
- `odds` (List<Odds>?) - Betting odds from various providers
- `awaySplitSquad` (bool?) - Away split squad indicator
- `homeSplitSquad` (bool?) - Home split squad indicator

**Methods:**
- `fromFirestore(Map<String, dynamic>?)` - Create Team from Firestore data
- `toFirestore()` - Convert Team to Firestore document format

**Nested Models:**
- `PlaceName` - Place name model that receives multi-language data from NHL API (default: English, fr: optional French). The UI only displays the English name (`name` field).
- `Odds` - Betting odds information (providerId, value)

### Game Model (`lib/models/game.dart`)

Represents a complete NHL game with all associated data:

**Required Fields:**
- `gameId` (int) - Unique game identifier
- `homeTeam` (Team) - Home team information
- `awayTeam` (Team) - Away team information
- `status` (GameStatus) - Current game status

**Optional Fields:**
- `startTime` (String?) - Game start time in ISO 8601 format
- `season` (int?) - Season identifier (e.g., 20252026)
- `gameType` (int?) - Type of game
- `gameScheduleState` (String?) - Schedule state
- `gameOutcome` (GameOutcome?) - Game outcome information
- `periodDescriptor` (PeriodDescriptor?) - Current period information
- `neutralSite` (bool?) - Whether game is at neutral site
- `venue` (Venue?) - Venue information
- `tvBroadcasts` (List<TvBroadcast>?) - TV broadcast information
- `winningGoalScorer` (WinningPlayer?) - Player who scored winning goal
- `winningGoalie` (WinningPlayer?) - Winning goalie information
- `condensedGame` (String?) - Condensed game video link
- `gameCenterLink` (String?) - Game center link
- `ticketsLink` (String?) - Tickets purchase link
- Various timezone and offset fields

**Methods:**
- `fromFirestore(DocumentSnapshot)` - Create Game from Firestore document snapshot
- `fromMap(Map<String, dynamic>)` - Create Game from data map
- `toFirestore()` - Convert Game to Firestore document format

**Nested Models:**
- `GameOutcome` - Game result information
- `PeriodDescriptor` - Period number, type, and regulation periods
- `TvBroadcast` - TV broadcast details (country, network, market)
- `Venue` - Venue name and timezone information
- `WinningPlayer` - Player information (first initial, last name, player ID)

### Key Features

- **Type Safety**: All fields have explicit type definitions
- **Null Safety**: Optional fields use nullable types (`?`) to safely handle missing data
- **Firestore Integration**: Complete serialization/deserialization methods for Firestore
- **Score Handling**: Score field safely handles null values (games may not have scores yet)
- **Multi-language Data Support**: The data model can receive and store multi-language data from Firestore (English and French), but the UI only displays English names. This ensures data completeness while maintaining a simple English-only interface.

## Services & Utilities

### Firestore Service (`lib/services/firestore_service.dart`)

Service class that encapsulates all Firestore database operations for game data.

**Methods:**
- `getTodayGames()` - Returns a stream of today's games with real-time updates, sorted by start time
  - Uses `Stream<QuerySnapshot>` for real-time listening
  - Queries games where `startTime >= start of today` (in local timezone, converted to UTC)
  - Automatically sorted by `startTime`
  - Limits results to 100 games
- `getGameById(int gameId)` - Returns a stream of a single game by gameId with real-time updates
  - Handles data parsing errors gracefully
  - Returns `null` if game not found or parsing fails

**Features:**
- Real-time data synchronization using Firestore streams
- **Offline Support**: Automatically uses cached data when network is unavailable
  - Firestore persistence is enabled by default on Android and iOS
  - Users can view previously loaded game data even when offline
  - Cache is automatically updated when network connection is restored
- Automatic error handling for data parsing
- Type-safe Game object conversion
- Includes metadata changes to detect cache vs server data

### Date Utilities (`lib/utils/date_utils.dart`)

Utility class for date and time operations, with timezone support.

**Methods:**
- `getTodayDateString()` - Get today's date string in YYYY-MM-DD format (local timezone)
- `extractDateFromIsoString(String?)` - Extract date string from ISO 8601 timestamp (local timezone)
- `isToday(String?)` - Check if an ISO 8601 timestamp string is today (local timezone)
- `getStartOfTodayUtc()` - Get start of today in local timezone, converted to UTC for Firestore queries
- `getEndOfTodayUtc()` - Get end of today in local timezone, converted to UTC for Firestore queries

**Features:**
- Uses local timezone for "today" calculations (supports all timezones including EST, PST, etc.)
- Converts to UTC for Firestore queries (since Firestore stores times in UTC)
- Handles timezone conversions automatically

## Screens

### Games List Screen (`lib/screens/games_list_screen.dart`)

Main screen displaying today's NHL games in a list format.

**Features:**
- **Real-time Updates**: Uses Riverpod's `StreamProvider` to listen to Firestore data stream, automatically updates when data changes
- **Game Cards**: Each game displayed as a card showing:
  - Home team name and score
  - Away team name and score
  - Game status badge with color coding:
    - Scheduled (blue)
    - Live (green)
    - Final (grey)
    - Other (orange)
  - Start time formatted in local timezone
- **Score Display Logic**:
  - Scheduled games: Display "-" (scores are null)
  - Live games: Display score (should have score)
  - Final games: Display score (should have score)
- **State Management** (using Riverpod):
  - Uses `ConsumerWidget` with `ref.watch(filteredGamesProvider)` to access filtered game data
  - Uses `AsyncValue.when()` to handle different states:
    - Loading state: Shows `LoadingIndicator`
    - Error state: Shows `ErrorDisplayWidget` with user-friendly error messages
    - Empty state: Shows `EmptyStateWidget` with context-aware messages based on filter
- **Game Filtering**: Filter games by status using the filter button in AppBar:
  - All Games (default)
  - Live Only (games in progress)
  - Scheduled Only (upcoming games)
  - Final Only (completed games)
  - Filter indicator bar shows current filter with clear option
  - Empty state messages adapt to selected filter
- **Data Filtering**: Filters games to only show today's games (based on local timezone)
- **Sorting**: Games are automatically sorted by start time (handled by Firestore query)

**Components:**
- `GamesListScreen` - Main screen widget
- `GameCard` - Reusable card widget for displaying individual game information

### Game Detail Screen (`lib/screens/game_detail_screen.dart`)

Detailed view screen that displays comprehensive information about a selected game.

**Features:**
- **Navigation**: Accessible by tapping on any game card from the list screen
- **Real-time Updates**: Uses Riverpod's `StreamProvider.family` to listen to individual game data stream
- **Comprehensive Data Display**: Shows all game fields including:
  - Game status badge
  - Home and away team information (name, score, logo, ID, place name)
  - Start time (formatted date and time)
  - Game information (season, game type, schedule state, neutral site)
  - Venue information (name, timezone, UTC offset)
  - Period information (current period number and type)
  - Game outcome
  - TV broadcasts (network, market, country)
  - Radio links (for both teams)
  - Winning players (goal scorer and goalie)
  - Video links (condensed game, 3-min recap)
  - Tickets link
  - Game Center link
  - Team odds (if available)
- **State Management** (using Riverpod):
  - Uses `ConsumerWidget` with `ref.watch(gameByIdStreamProvider(gameId))` to access data
  - Uses `AsyncValue.when()` to handle different states:
    - Loading state: Shows `LoadingIndicator`
    - Error state: Shows `ErrorDisplayWidget` with error message
    - Empty state: Shows `EmptyStateWidget` when game not found
- **Logo Display**: Supports both SVG and image formats with proper error handling

**Components:**
- `GameDetailScreen` - Main detail screen widget
- Various helper methods for building different sections of game information

## State Management

The project uses Riverpod for state management, providing reactive data streams and efficient state updates.

### Providers (`lib/providers/`)

**Firestore Provider** (`firestore_provider.dart`)
- `firestoreServiceProvider` - Provides FirestoreService instance
- `firestoreProvider` - Provides FirebaseFirestore instance

**Games Provider** (`games_provider.dart`)
- `todayGamesStreamProvider` - Stream of today's games from Firestore
- `gameByIdStreamProvider` - Stream of a specific game by ID (family provider)
- `todayGamesListProvider` - Processed list of today's games with filtering

**Game Filter Provider** (`game_filter_provider.dart`)
- `GameFilter` enum - Filter options (all, live, scheduled, final_)
- `gameFilterProvider` - NotifierProvider managing current filter state
- `filteredGamesProvider` - Provider that applies selected filter to game list
- Real-time filtering: Updates automatically when filter changes or game status updates

## Part 3 - Team Detail Page

Team detail page implementation to display team information, season record, and recent games.

### Team Record Model (`lib/models/team_record.dart`)

**Fields:**
- `wins` (int) - Number of wins
- `losses` (int) - Number of regulation losses
- `ot` (int) - Number of overtime/shootout losses
- `points` (int) - Total points (wins * 2 + ot, following NHL scoring rules)
- `gamesPlayed` (int) - Total games played

**Methods:**
- `fromGames(List<Game> games, int teamId)` - Factory method that calculates team record from a list of games
  - Only counts final games (`status == final_`)
  - Compares scores to determine wins/losses
  - Identifies OT losses using `gameOutcome.lastPeriodType` or `periodDescriptor.periodType`
  - Calculates points according to NHL rules (2 points for win, 1 point for OT loss)
- `recordString` - Returns formatted record string (e.g., "30-20-5")
- `winPercentage` - Calculates win percentage

**Features:**
- Handles null scores gracefully
- Identifies overtime and shootout losses correctly
- Follows NHL scoring system (2-1-0 point system)

### Firestore Service Extension (`lib/services/firestore_service.dart`)

Extended Firestore service to support team-related queries. Since Firestore doesn't support OR queries, the implementation uses a **dual-query merge strategy**.

#### Methods Added:

**1. `getTeamInfo(int teamId)` - Get Team Information**
- **Logic**: Queries games collection twice (homeTeam.id and awayTeam.id)
- **Fallback Strategy**: First tries homeTeam query, if not found, tries awayTeam query
- **Returns**: `Future<Team?>` - Team data from first matching game
- **Use Case**: Extract team name, logo, and other info from any game containing the team

**2. `getTeamGames(int teamId, int? season)` - Get All Team Games**
- **Core Challenge**: Firestore doesn't support `WHERE homeTeam.id = X OR awayTeam.id = X`
- **Solution**: 
  1. Query home games: `where('homeTeam.id', isEqualTo: teamId)`
  2. Query away games: `where('awayTeam.id', isEqualTo: teamId)`
  3. **Merge streams** using `StreamZip` from `async` package
  4. **Deduplicate** by `gameId` (same game appears in both queries)
  5. **Filter by season** if provided
- **Returns**: `Stream<List<Game>>` - Real-time stream of all team games
- **Use Case**: Calculate season record from all final games

**3. `getTeamRecentGames(int teamId)` - Get Recent 5 Games**
- **Logic**:
  1. Query home games (limit 5, sorted by startTime desc)
  2. Query away games (limit 5, sorted by startTime desc)
  3. **Merge streams** using `StreamZip`
  4. **Deduplicate** by `gameId`
  5. **Re-sort** merged results by `startTime` descending
  6. **Take top 5** from merged and sorted list
- **Why Re-sort**: Each query returns top 5, but merged list may have different ordering
- **Returns**: `Stream<List<Game>>` - Real-time stream of last 5 games
- **Use Case**: Display recent games list on team page

#### Key Implementation Details:

**Stream Merging Pattern:**
```dart
StreamZip([homeGamesStream, awayGamesStream]).map((snapshots) {
  // Merge documents from both queries
  // Deduplicate by gameId
  // Apply additional filtering/sorting
})
```

**Deduplication Strategy:**
- Uses `Map<int, Game>` with `gameId` as key
- Automatically handles duplicates (last occurrence wins)
- Ensures each game appears only once in result

**Real-time Updates:**
- All methods use `snapshots(includeMetadataChanges: true)`
- Supports offline cache (Firestore default behavior)
- Automatically updates when data changes in Firestore

**Error Handling:**
- Try-catch blocks around game parsing
- Logs errors without crashing
- Returns empty list or null on errors

### Team Providers (`lib/providers/team_provider.dart`)

Riverpod providers for team-related data, implementing reactive data extraction and transformation logic.

#### Providers:

**1. `teamInfoProvider` - Team Information**
- **Type**: `FutureProvider.family<Team?, int>`
- **Data Extraction Logic**:
  1. Watches `firestoreServiceProvider` to get service instance
  2. Calls `getTeamInfo(teamId)` which queries games collection
  3. Extracts team data from first matching game (homeTeam or awayTeam)
- **Returns**: `Future<Team?>` - Team info or null if not found
- **Use Case**: Display team name and logo on team detail page

**2. `teamGamesProvider` - All Team Games**
- **Type**: `StreamProvider.family<List<Game>, TeamGamesParams>`
- **Parameters**: `TeamGamesParams` (teamId + optional season)
- **Data Extraction Logic**:
  1. Watches `firestoreServiceProvider`
  2. Calls `getTeamGames(teamId, season)` which:
     - Queries home games and away games separately
     - Merges streams using `StreamZip`
     - Deduplicates by `gameId`
     - Filters by season if provided
  3. Returns real-time stream of all team games
- **Returns**: `Stream<List<Game>>` - Real-time updates when games change
- **Use Case**: Base data for calculating team record

**3. `teamRecordProvider` - Team Season Record**
- **Type**: `Provider.family<AsyncValue<TeamRecord?>, TeamGamesParams>`
- **Data Transformation Logic**:
  1. **Dependency**: Watches `teamGamesProvider(params)` to get all games
  2. **Filtering**: Extracts only final games (`status == final_`)
  3. **Calculation**: Calls `TeamRecord.fromGames(finalGames, teamId)` to:
     - Compare scores to determine wins/losses
     - Identify OT losses from `gameOutcome` or `periodDescriptor`
     - Calculate points (wins * 2 + ot)
  4. **State Management**: Wraps result in `AsyncValue` to handle loading/error states
- **Returns**: `AsyncValue<TeamRecord?>` - Record with loading/error/data states
- **Key Feature**: **Derived data** - automatically recalculates when games update
- **Use Case**: Display season record on team detail page

**4. `teamRecentGamesProvider` - Recent 5 Games**
- **Type**: `StreamProvider.family<List<Game>, int>`
- **Data Extraction Logic**:
  1. Watches `firestoreServiceProvider`
  2. Calls `getTeamRecentGames(teamId)` which:
     - Queries home games (limit 5, sorted desc)
     - Queries away games (limit 5, sorted desc)
     - Merges and deduplicates
     - Re-sorts and takes top 5
  3. Returns real-time stream of recent games
- **Returns**: `Stream<List<Game>>` - Real-time updates
- **Use Case**: Display recent games list on team detail page

#### Key Implementation Patterns:

**Provider Dependency Chain:**
```
teamGamesProvider (raw games)
    ↓
teamRecordProvider (derived: filters + calculates)
```

**Data Flow for Team Record:**
1. `teamGamesProvider` → Returns all games (scheduled, live, final)
2. `teamRecordProvider` watches `teamGamesProvider`
3. Filters: `games.where((g) => g.status == GameStatus.final_)`
4. Transforms: `TeamRecord.fromGames(finalGames, teamId)`
5. Wraps: `AsyncValue.data(record)` for UI consumption

**AsyncValue State Handling:**
- Uses `AsyncValue.when()` to handle three states:
  - `data`: Transform and return calculated record
  - `loading`: Return `AsyncValue.loading()`
  - `error`: Propagate error state
- Ensures UI always receives consistent state structure

**Parameter Class (`TeamGamesParams`):**
- Encapsulates `teamId` and optional `season` in single object
- Implements `==` and `hashCode` for proper Riverpod caching
- Allows Riverpod to correctly cache and invalidate providers based on parameters

**Real-time Updates:**
- All `StreamProvider` instances automatically update when Firestore data changes
- `teamRecordProvider` automatically recalculates when `teamGamesProvider` updates
- No manual refresh needed - reactive data flow

### Team Detail Screen (`lib/screens/team_detail_screen.dart`)

Team detail page UI displaying team information, current season record, and recent games.

#### Data Consumption Logic:

**Team Information:**
- Watches `teamInfoProvider(teamId)` to get team name, logo, and abbreviation from games collection
- Displays in header card with logo and team name

**Current Season Record:**
- Uses `DateUtils.getCurrentSeason()` to determine current NHL season (October-based logic)
- Watches `teamRecordProvider(TeamGamesParams(teamId, season))` which:
  - Gets all team games from `teamGamesProvider`
  - Filters to final games only
  - Calculates wins, losses, OT losses, and points using `TeamRecord.fromGames()`
- Displays record statistics in card format

**Recent Games:**
- Watches `teamRecentGamesProvider(teamId)` to get last 5 games
- For each game, determines if team is home or away
- Displays opponent name (with "vs" or "@" prefix), date, status, and score
- Game cards are clickable to navigate to `GameDetailScreen`

#### Key Features:
- Real-time updates via Firestore streams
- Season-aware record calculation (automatically filters by current season)
- Context-aware game display (shows team's perspective)
- Comprehensive error handling (loading, error, empty states)
