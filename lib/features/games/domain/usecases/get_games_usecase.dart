import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/game_entity.dart';
import '../repositories/game_repository.dart';

class GetGamesParams extends Equatable {
  final bool forceRefresh;

  const GetGamesParams({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class GetGamesUseCase implements UseCase<List<GameEntity>, GetGamesParams> {
  final GameRepository repository;

  const GetGamesUseCase(this.repository);

  @override
  Future<Either<Failure, List<GameEntity>>> call(GetGamesParams params) async {
    return await repository.getGames(forceRefresh: params.forceRefresh);
  }
}
