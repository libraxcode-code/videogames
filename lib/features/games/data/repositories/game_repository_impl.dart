import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/game_entity.dart';
import '../../domain/repositories/game_repository.dart';
import '../datasources/game_local_datasource.dart';
import '../datasources/game_remote_datasource.dart';

class GameRepositoryImpl implements GameRepository {
  final GameRemoteDataSource remoteDataSource;
  final GameLocalDataSource localDataSource;

  const GameRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<GameEntity>>> getGames({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final cached = await localDataSource.getCachedGames();
        if (cached.isNotEmpty) {
          return Right(cached);
        }
      }

      final remoteGames = await remoteDataSource.fetchGames();
      await localDataSource.cacheGames(remoteGames);
      return Right(remoteGames);
    } on NetworkException catch (e) {
      final cached = await localDataSource.getCachedGames();
      if (cached.isNotEmpty) {
        return Right(cached);
      }
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, GameEntity>> getGameById(String id) async {
    try {
      final cached = await localDataSource.getCachedGames();
      final fromCache = cached.where((g) => g.id == id);
      if (fromCache.isNotEmpty) {
        return Right(fromCache.first);
      }

      final remoteGames = await remoteDataSource.fetchGames();
      await localDataSource.cacheGames(remoteGames);
      final game = remoteGames.firstWhere(
        (g) => g.id == id,
        orElse: () => throw const ServerException(message: 'Game not found'),
      );
      return Right(game);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
