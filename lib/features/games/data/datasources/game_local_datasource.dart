import '../models/game_model.dart';

abstract class GameLocalDataSource {
  Future<List<GameModel>> getCachedGames();
  Future<void> cacheGames(List<GameModel> games);
}

class GameLocalDataSourceImpl implements GameLocalDataSource {
  List<GameModel> _memoryCache = [];

  @override
  Future<List<GameModel>> getCachedGames() async {
    return _memoryCache;
  }

  @override
  Future<void> cacheGames(List<GameModel> games) async {
    _memoryCache = List<GameModel>.from(games);
  }
}
