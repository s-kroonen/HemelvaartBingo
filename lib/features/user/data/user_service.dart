import 'package:dio/dio.dart';

import '../data/user_model.dart';

// lib/features/user/data/user_service.dart
class UserService {
  final Dio _dio;
  UserService(this._dio);

  Future<UserModel> getMe() async {
    final res = await _dio.get('/users/me');
    return UserModel.fromJson(res.data);
  }

  Future<void> updateCurrentMatch(String matchId) async {
    await _dio.put('/users/me/current-match', data: {"matchId": matchId});
  }
}
