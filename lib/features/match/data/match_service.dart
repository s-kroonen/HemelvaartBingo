import 'package:dio/dio.dart';
import 'match_models.dart';

class MatchService {
  final Dio _dio;

  MatchService(this._dio);

  // Fetch all matches for the current user
  Future<List<MatchModel>> fetchMyMatches() async {
    final response = await _dio.get('/users/me/matches');
    return (response.data as List).map((m) => MatchModel.fromJson(m)).toList();
  }

  // Fetch the specific context (Match + Card + Role)
  Future<MatchContext> fetchMatchContext(String matchId) async {
    final response = await _dio.get('/users/me/matches/$matchId');
    return MatchContext.fromJson(response.data);
  }

  // Get the current active match context
  Future<MatchContext> fetchCurrentMatchContext() async {
    final response = await _dio.get('/users/me/current-match');
    return MatchContext.fromJson(response.data);
  }
}