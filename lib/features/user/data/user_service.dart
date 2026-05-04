import 'package:dio/dio.dart';
import '../../card/data/card_model.dart';
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
      '/cards/cell',
      data: {"cellId": cellId, "isChecked": isChecked},
    );
    return CardModel.fromJson(res.data);
  }

  Future<CardModel> getMyCard() async {
    final res = await _dio.put('/cards/my-card');
    return CardModel.fromJson(res.data);
  }

  Future<void> deleteAccount() async {}

  Future<void> updateProfile(Map<String, dynamic> map) async {
    await _dio.put("/users/me", data: map);
  }
}
