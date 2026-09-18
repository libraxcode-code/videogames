import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/game_entity.dart';
import '../repositories/game_repository.dart';

class GetGamesParams extends Equatable {
  final int page;
  final int pageSize;
  final bool forceRefresh;
  final String? searchQuery;

  const GetGamesParams({
    this.page = 1,
    this.pageSize = 20,
    this.forceRefresh = false,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [page, pageSize, forceRefresh, searchQuery];
}

class GetGamesUseCase implements UseCase<List<GameEntity>, GetGamesParams> {
  final GameRepository repository;

  const GetGamesUseCase(this.repository);

  @override
  Future<Either<Failure, List<GameEntity>>> call(GetGamesParams params) async {
    return await repository.getGames(
      page: params.page,
      pageSize: params.pageSize,
      forceRefresh: params.forceRefresh,
      searchQuery: params.searchQuery,
    );
  }
}
