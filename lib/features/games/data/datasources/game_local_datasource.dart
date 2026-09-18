import '../models/game_model.dart';

abstract class GameLocalDataSource {
  Future<List<GameModel>> getCachedGames({int page = 1, String? searchQuery});
  Future<void> cacheGames(List<GameModel> games, {int page = 1, String? searchQuery});
  Future<GameModel?> getCachedGameDetail(String id);
  Future<void> cacheGameDetail(GameModel game);
}

class GameLocalDataSourceImpl implements GameLocalDataSource {
  // Query + Page keyed cache
  final Map<String, List<GameModel>> _queryPageCache = {};
  final Map<String, GameModel> _detailCache = {};

  String _buildKey(int page, String? query) {
    final cleanQuery = (query ?? '').trim().toLowerCase();
    return 'page_${page}_q_$cleanQuery';
  }

  @override
  Future<List<GameModel>> getCachedGames({int page = 1, String? searchQuery}) async {
    final key = _buildKey(page, searchQuery);
    return _queryPageCache[key] ?? [];
  }

  @override
  Future<void> cacheGames(List<GameModel> games, {int page = 1, String? searchQuery}) async {
    final key = _buildKey(page, searchQuery);
    _queryPageCache[key] = List<GameModel>.from(games);
    // Also index individual game details for quick offline retrieval
    for (final game in games) {
      _detailCache[game.id] = game;
    }
  }

  @override
  Future<GameModel?> getCachedGameDetail(String id) async {
    return _detailCache[id];
  }

  @override
  Future<void> cacheGameDetail(GameModel game) async {
    _detailCache[game.id] = game;
  }
}
