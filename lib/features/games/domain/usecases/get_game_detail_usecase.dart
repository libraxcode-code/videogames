import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/game_entity.dart';
import '../repositories/game_repository.dart';

class GetGameDetailUseCase implements UseCase<GameEntity, String> {
  final GameRepository repository;

  const GetGameDetailUseCase(this.repository);

  @override
  Future<Either<Failure, GameEntity>> call(String id) async {
    return await repository.getGameById(id);
  }
}
