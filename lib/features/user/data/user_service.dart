import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hemelvaartbingo/features/card/models/card_model.dart';

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

  Future<CardModel> updateCellState(String cellId, bool isChecked) async {
    final res = await _dio.put(
      '/users/me/card/cell',
      data: {"cellId": cellId, "isChecked": isChecked},
    );
    return CardModel.fromJson(res.data);
  }

  Future<void> deleteAccount() async {

  }
}
