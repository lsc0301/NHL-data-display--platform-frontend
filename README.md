# NHL Data Display Platform Frontend

NHL Data Display Platform Frontend Project

## Overview

This project is a Flutter mobile application designed to display NHL game data in real-time from Google Firestore. The app provides an intuitive interface for viewing today's games, with live score updates and detailed game information. Users can browse games, filter live matches, and view comprehensive game details, all while benefiting from offline capabilities through Firestore's built-in caching.

## Key Features

- **Real-time Data Display**: Connects to Firestore to display today's NHL games with live score updates as data changes.

- **Games List Screen**: Shows a comprehensive list of games with team information, scores, start times, and game status in an easy-to-read format.

- **Game Detail Screen**: Provides full game information including detailed team stats, game timeline, and all relevant match data.

- **Live Game Filter**: Allows users to filter and focus on games that are currently in progress.

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
