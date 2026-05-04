import 'package:dio/dio.dart';
import 'match_models.dart';

class MatchService {
  final Dio _dio;

  MatchService(this._dio);

  // Fetch all matches for the current user
  Future<List<MatchModel>> fetchMyMatches() async {
    final response = await _dio.get('/matches');
    return (response.data as List).map((m) => MatchModel.fromJson(m)).toList();
  }

  // Fetch the specific context (Match + Role)
  Future<MatchContext> fetchMatchContext(String matchId) async {
    final response = await _dio.get('/matches/$matchId');
    return MatchContext.fromJson(response.data);
  }

  // Get the current active match context
  Future<MatchContext> fetchCurrentMatchContext() async {
    final response = await _dio.get('/matches/context');
    return MatchContext.fromJson(response.data);
  }

  Future<void> updateMatch(String matchId, Map<String, dynamic> map) async {
    await _dio.put('/matches/$matchId', data: map);
  }

  Future<void> createMatch(Map<String, dynamic> map) async {
    await _dio.post("/matches", data: map);
  }
}