import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_games_usecase.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final GetGamesUseCase getGamesUseCase;

  GameBloc({required this.getGamesUseCase}) : super(const GameInitialState()) {
    on<FetchGamesEvent>(_onFetchGames);
  }

  Future<void> _onFetchGames(
    FetchGamesEvent event,
    Emitter<GameState> emit,
  ) async {
    if (state is! GameLoadedState) {
      emit(const GameLoadingState());
    }

    final result = await getGamesUseCase(
      GetGamesParams(forceRefresh: event.forceRefresh),
    );

    result.fold(
      (failure) => emit(GameErrorState(failure.message)),
      (games) => emit(GameLoadedState(games: games)),
    );
  }
}
