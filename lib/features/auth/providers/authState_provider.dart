import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/authState_model.dart';

final authStateProvider = StreamProvider<AuthState>((ref) {
  return FirebaseAuth.instance.authStateChanges().map((user) {
    return AuthState(
      isLoggedIn: user != null,
      userId: user?.uid,
    );
  });
});
