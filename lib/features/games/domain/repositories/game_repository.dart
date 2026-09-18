import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/game_entity.dart';

abstract class GameRepository {
  Future<Either<Failure, List<GameEntity>>> getGames({bool forceRefresh = false});
  Future<Either<Failure, GameEntity>> getGameById(String id);
}
