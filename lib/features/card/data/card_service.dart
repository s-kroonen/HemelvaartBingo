import 'package:dio/dio.dart';
import 'package:hemelvaartbingo/features/card/data/card_model.dart';

class CardService {
  final Dio _dio;

  CardService(this._dio);

  // Fetch all matches for the current user
  Future<List<CardModel>> fetchMyCards() async {
    final response = await _dio.get('/cards');
    return (response.data as List).map((m) => CardModel.fromJson(m)).toList();
  }

  // Fetch the specific context (Match + Role)
  Future<CardModel> fetchMyCard(String matchId) async {
    final response = await _dio.get('/cards/my-card');
    return CardModel.fromJson(response.data);
  }

  Future<CardModel> fetchMyCurrentCard() async {
    final response = await _dio.get('/cards/my-card');
    return CardModel.fromJson(response.data);
  }
}
