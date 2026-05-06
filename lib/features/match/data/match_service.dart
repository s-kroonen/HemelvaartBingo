import 'package:dio/dio.dart';
import '../../invites/data/invite_model.dart';
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

  // Add to MatchService class
  Future<List<InviteModel>> fetchInvites(String matchId) async {
    final res = await _dio.get('/matches/$matchId/invites');
    return (res.data as List).map((i) => InviteModel.fromJson(i)).toList();
  }

  Future<void> createInvite(String matchId, Map<String, dynamic> data) async {
    await _dio.post('/matches/$matchId/invites', data: data);
  }

  Future<void> updateInvite(
    String matchId,
    String inviteId,
    Map<String, dynamic> data,
  ) async {
    await _dio.put('/matches/$matchId/invites/$inviteId', data: data);
  }

  Future<void> deleteInvite(String matchId, String inviteId) async {
    await _dio.delete('/matches/$matchId/invites/$inviteId');
  }

  Future<BingoResultDto> callBingo(String cardId, String matchId) async {
    final res = await _dio.post(
      '/cards/$cardId/bingo',
      data: {'matchId': matchId},
    );
    return BingoResultDto.fromJson(res.data);
  }
}
