import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/game_entity.dart';

abstract class GameRepository {
  Future<Either<Failure, List<GameEntity>>> getGames({
    int page = 1,
    int pageSize = 20,
    bool forceRefresh = false,
    String? searchQuery,
  });

  Future<Either<Failure, GameEntity>> getGameById(String id);
}
