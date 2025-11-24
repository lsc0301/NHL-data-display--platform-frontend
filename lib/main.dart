import 'package:flutter/material.dart';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'screens/games_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  log('Initializing Firebase...');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  log('Firebase initialized successfully');

  // Firestore offline cache enabled by default (Android/iOS)
  log('Firestore configured - offline cache enabled by default');

  log('Running app...');
  runApp(const ProviderScope(child: MyApp()));
  log('App running successfully');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NHL Games',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const GamesListScreen(),
    );
  }
}
