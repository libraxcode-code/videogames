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
  Future<Either<Failure, List<GameEntity>>> getGames({
    int page = 1,
    int pageSize = 20,
    bool forceRefresh = false,
    String? searchQuery,
  }) async {
    try {
      if (!forceRefresh) {
        final cached = await localDataSource.getCachedGames(
          page: page,
          searchQuery: searchQuery,
        );
        if (cached.isNotEmpty) {
          return Right(cached);
        }
      }

      final remoteGames = await remoteDataSource.fetchGames(
        page: page,
        pageSize: pageSize,
        searchQuery: searchQuery,
      );

      await localDataSource.cacheGames(
        remoteGames,
        page: page,
        searchQuery: searchQuery,
      );

      return Right(remoteGames);
    } on NetworkException catch (e) {
      final cached = await localDataSource.getCachedGames(
        page: page,
        searchQuery: searchQuery,
      );
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
      final cached = await localDataSource.getCachedGameDetail(id);
      if (cached != null && cached.description.isNotEmpty && cached.description.length > 120) {
        return Right(cached);
      }

      final remoteGame = await remoteDataSource.fetchGameDetail(id);
      await localDataSource.cacheGameDetail(remoteGame);
      return Right(remoteGame);
    } on NetworkException catch (e) {
      final cached = await localDataSource.getCachedGameDetail(id);
      if (cached != null) {
        return Right(cached);
      }
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
