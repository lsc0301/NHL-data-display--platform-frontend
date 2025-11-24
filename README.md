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
