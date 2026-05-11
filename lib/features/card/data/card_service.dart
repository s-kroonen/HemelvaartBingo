import 'package:dio/dio.dart';
import 'package:hemelvaartbingo/core/network/api_client.dart';
import 'package:hemelvaartbingo/features/card/data/card_model.dart';

class CardService {
  final Dio _dio;

  CardService(this._dio);

  // Fetch the specific context (Match + Role)
  Future<CardModel> fetchMyCard(String matchId) async {
    return safeRequest(() async {
      final response = await _dio.get('/cards/my-card');
      if (response.data is! Map<String, dynamic>) {
        throw AppError(
          message: "Server returned invalid card data.",
          raw: response.data,
        );
      }
      return CardModel.fromJson(response.data);
    });
  }

  Future<CardModel> fetchMyCurrentCard() async {
    return safeRequest(() async {
      final response = await _dio.get('/cards/my-card');

      if (response.data is! Map<String, dynamic>) {
        throw AppError(
          message: "Server returned invalid card data.",
          raw: response.data,
        );
      }

      return CardModel.fromJson(response.data);
    });
  }

  Future<CardModel> updateCellState(String cellId, bool isChecked) async {
    final res = await _dio.put(
      '/cards/cell',
      data: {"cellId": cellId, "isChecked": isChecked},
    );
    return CardModel.fromJson(res.data);
  }
}
