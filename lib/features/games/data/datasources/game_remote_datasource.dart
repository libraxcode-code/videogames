import '../../../../core/network/dio_api_client.dart';
import '../models/game_model.dart';

abstract class GameRemoteDataSource {
  Future<List<GameModel>> fetchGames({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
  });

  Future<GameModel> fetchGameDetail(String id);
}

class GameRemoteDataSourceImpl implements GameRemoteDataSource {
  final DioApiClient client;

  GameRemoteDataSourceImpl({required this.client});

  @override
  Future<List<GameModel>> fetchGames({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
  }) async {
    // Dynamic 1-year window query calculation
    final now = DateTime.now();
    final oneYearAgo = DateTime(now.year - 1, now.month, now.day);
    final todayFormatted = '${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)}';
    final oneYearAgoFormatted = '${oneYearAgo.year}-${_twoDigits(oneYearAgo.month)}-${_twoDigits(oneYearAgo.day)}';

    final Map<String, dynamic> params = {
      'page': page,
      'page_size': pageSize,
      'platforms': 187, // PlayStation 5
      'ordering': '-released', // Latest released first
      'dates': '$oneYearAgoFormatted,$todayFormatted',
    };

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      params['search'] = searchQuery.trim();
    }

    final data = await client.get('/games', queryParameters: params);

    if (data is Map<String, dynamic> && data['results'] is List) {
      final results = data['results'] as List;
      return results
          .map((item) => GameModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  @override
  Future<GameModel> fetchGameDetail(String id) async {
    final data = await client.get('/games/$id');
    return GameModel.fromJson(data as Map<String, dynamic>);
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}
