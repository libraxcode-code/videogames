import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:videogames/core/error/failures.dart';
import 'package:videogames/features/games/domain/entities/game_entity.dart';
import 'package:videogames/features/games/domain/usecases/get_games_usecase.dart';
import 'package:videogames/features/games/presentation/bloc/game_bloc.dart';
import 'package:videogames/features/games/presentation/bloc/game_event.dart';
import 'package:videogames/features/games/presentation/bloc/game_state.dart';

class FakeGetGamesUseCase extends Fake implements GetGamesUseCase {
  final Future<Either<Failure, List<GameEntity>>> Function(GetGamesParams params) onCall;
  FakeGetGamesUseCase(this.onCall);

  @override
  Future<Either<Failure, List<GameEntity>>> call(GetGamesParams params) {
    return onCall(params);
  }
}

void main() {
  const tGame = GameEntity(
    id: '437049',
    title: 'FIFA 21',
    genre: 'Sports',
    rating: 3.5,
    metacritic: 72,
    releaseDate: '2020-10-09',
    description: 'EA Sports FIFA 21 on PlayStation 5',
    imageUrl: 'https://example.com/fifa21.jpg',
  );

  group('GameBloc Unit Tests', () {
    test('initial state should be GameInitialState', () {
      final fakeUseCase = FakeGetGamesUseCase((params) async => const Right([tGame]));
      final bloc = GameBloc(getGamesUseCase: fakeUseCase);
      expect(bloc.state, const GameInitialState());
      bloc.close();
    });

    test('should emit [GameLoadingState, GameLoadedState] when fetch games succeeds', () async {
      final fakeUseCase = FakeGetGamesUseCase((params) async => const Right([tGame]));
      final bloc = GameBloc(getGamesUseCase: fakeUseCase);

      expectLater(
        bloc.stream,
        emitsInOrder([
          const GameLoadingState(isSearching: false),
          const GameLoadedState(
            games: [tGame],
            activeQuery: '',
            currentPage: 1,
            hasReachedMax: true,
          ),
        ]),
      );

      bloc.add(const FetchGamesEvent());
      await Future.delayed(const Duration(milliseconds: 50));
      bloc.close();
    });

    test('should emit [GameLoadingState, GameErrorState] when fetch games fails', () async {
      final fakeUseCase = FakeGetGamesUseCase(
        (params) async => const Left(ServerFailure(message: 'API connection timeout')),
      );
      final bloc = GameBloc(getGamesUseCase: fakeUseCase);

      expectLater(
        bloc.stream,
        emitsInOrder([
          const GameLoadingState(isSearching: false),
          const GameErrorState('API connection timeout', activeQuery: ''),
        ]),
      );

      bloc.add(const FetchGamesEvent());
      await Future.delayed(const Duration(milliseconds: 50));
      bloc.close();
    });
  });
}
