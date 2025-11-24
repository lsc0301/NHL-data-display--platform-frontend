import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';

/// FirestoreService provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});
