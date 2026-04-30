// lib/features/auth/data/auth_service.dart

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client_provider.dart';

final authServiceProvider = Provider(
  (ref) => AuthService(ref.watch(dioProvider)),
);

enum RegistrationResult { success, partialSuccess, failure }

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  Future<RegistrationResult> registerUser({
    required String email,
    required String password,
    required String username,
    required bool emailNotifications,
    required bool newsletter,
    required bool testerProgram,
  }) async {
    // 1. Create in Firebase
    try {
      // 1. Create in Firebase - This automatically signs the user in
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      return RegistrationResult.failure;
    }

    // 2. Send metadata to NestJS
    try {
      await _dio.put(
        '/users/me',
        data: {
          "email": email,
          "username": username,
          "settings": {
            "emailNotifications": emailNotifications,
            "newsletter": newsletter,
            "testerProgram": testerProgram,
          },
        },
      );
      return RegistrationResult.success;
    } catch (e) {
      // Firebase worked, but Backend failed
      debugPrint("Backend Sync Error: $e");
      return RegistrationResult.partialSuccess;
    }
  }
}
