import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_providers.dart';

final currentHouseholdIdProvider = StreamProvider<String?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final fs = ref.watch(firestoreProvider);

  return auth.authStateChanges().asyncExpand((user) {
    if (user == null) return Stream.value(null);
    return fs.collection('users').doc(user.uid).snapshots().map((doc) {
      final data = doc.data();
      return data?['currentHouseholdId'] as String?;
    });
  });
});
