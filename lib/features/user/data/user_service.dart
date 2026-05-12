import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../data/user_model.dart';

// lib/features/user/data/user_service.dart
class UserService {
  final Dio _dio;

  UserService(this._dio);

  Future<UserModel> getMe() async {
    return safeRequest(() async {
      final res = await _dio.get('/users/me');
      return UserModel.fromJson(res.data);
    });
  }

  Future<void> updateCurrentMatch(String matchId) async {
    await _dio.put('/users/me/current-match', data: {"matchId": matchId});
  }

  Future<void> deleteAccount() async {}

  Future<void> updateProfile(Map<String, dynamic> map) async {
    await _dio.put("/users/me", data: map);
  }

  Future<void> completeTutorial(String s) async {
    // We wrap the field inside a 'tutorials' map to match the backend structure
    final updateData = {
      "tutorials": {s: true},
    };

    return await updateProfile(updateData);
  }

  Future<void> addUserTokens(String token) async {
    final updateData = {
      "fcmTokens" : token,
    };

    return await updateProfile(updateData);
  }
}
